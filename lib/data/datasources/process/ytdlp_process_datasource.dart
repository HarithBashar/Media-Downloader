import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/utils/size_formatter.dart';
import '../../../domain/entities/download_enums.dart';
import '../../../domain/entities/download_item.dart';
import '../../../domain/entities/playlist_video_info.dart';

/// Raw yt-dlp process wrapper that manages subprocess lifecycle.
///
/// Parses yt-dlp's `--progress-template` output into [DownloadItem]
/// state updates, handling all process I/O on a dedicated stream.
class YtDlpProcessDatasource {
  YtDlpProcessDatasource({
    required String ytDlpPath,
    required Logger logger,
    String? ffmpegPath,
  })  : _ytDlpPath = ytDlpPath,
        _ffmpegPath = ffmpegPath,
        _logger = logger;

  final String _ytDlpPath;
  final String? _ffmpegPath;
  final Logger _logger;

  /// Active processes keyed by download ID.
  final Map<String, Process> _processes = {};

  // ─── Public API ─────────────────────────────────────────────────────────────

  /// Starts the yt-dlp download for [item] and emits state updates.
  ///
  /// The stream completes when the download finishes, fails, or is cancelled.
  Stream<DownloadItem> download(DownloadItem item) {
    final controller = StreamController<DownloadItem>.broadcast();

    _startProcess(item, controller).catchError((Object err) {
      final msg = err is AppException ? err.message : err.toString();
      controller.add(item.copyWith(
        status: DownloadStatus.failed,
        errorMessage: msg,
      ));
      controller.close();
    });

    return controller.stream;
  }

  /// Terminates the process for the given download [id].
  Future<void> cancel(String id) async {
    final process = _processes.remove(id);
    process?.kill(ProcessSignal.sigterm);
  }

  /// Pauses a download by sending SIGSTOP (Unix only).
  Future<void> pause(String id) async {
    final process = _processes[id];
    if (process != null && !Platform.isWindows) {
      process.kill(ProcessSignal.sigstop);
    }
  }

  /// Resumes a paused download by sending SIGCONT (Unix only).
  Future<void> resume(String id) async {
    final process = _processes[id];
    if (process != null && !Platform.isWindows) {
      process.kill(ProcessSignal.sigcont);
    }
  }

  /// Active playlist fetch process (only one at a time).
  Process? _playlistFetchProcess;

  /// Fetches metadata for all videos in a playlist without downloading.
  ///
  /// Runs `yt-dlp --dump-json --flat-playlist <url>` and emits a
  /// [PlaylistVideoInfo] for each video as it's parsed.
  Stream<PlaylistVideoInfo> fetchPlaylistInfo(String url) {
    final controller = StreamController<PlaylistVideoInfo>.broadcast();

    _runPlaylistFetch(url, controller).catchError((Object err) {
      if (!controller.isClosed) {
        controller.addError(err);
        controller.close();
      }
    });

    return controller.stream;
  }

  /// Cancels an active playlist fetch.
  void cancelPlaylistFetch() {
    _playlistFetchProcess?.kill(ProcessSignal.sigterm);
    _playlistFetchProcess = null;
  }

  Future<void> _runPlaylistFetch(
    String url,
    StreamController<PlaylistVideoInfo> controller,
  ) async {
    final args = [
      '--dump-json',
      '--flat-playlist',
      '--no-warnings',
      url,
    ];

    _logger.d('[yt-dlp] Fetching playlist: $_ytDlpPath ${args.join(' ')}');

    late Process process;
    try {
      process = await Process.start(_ytDlpPath, args);
    } on ProcessException catch (e) {
      throw YtDlpException('Failed to start yt-dlp for playlist fetch.', cause: e);
    }
    _playlistFetchProcess = process;

    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.startsWith('{')) return;
        try {
          final json = jsonDecode(trimmed) as Map<String, dynamic>;
          final video = PlaylistVideoInfo.fromJson(json);
          if (!controller.isClosed) controller.add(video);
        } catch (e) {
          _logger.w('[yt-dlp playlist] Failed to parse JSON line: $e');
        }
      },
      cancelOnError: false,
    );

    final stderrBuffer = StringBuffer();
    process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen(
      (line) {
        _logger.w('[yt-dlp playlist stderr] $line');
        stderrBuffer.writeln(line);
      },
      cancelOnError: false,
    );

    final exitCode = await process.exitCode;
    _playlistFetchProcess = null;

    if (controller.isClosed) return;

    if (exitCode != 0) {
      final stderr = stderrBuffer.toString().trim();
      final msg = stderr.contains('is not a valid URL')
          ? 'Invalid playlist URL.'
          : stderr.contains('not a playlist')
              ? 'This URL does not appear to be a playlist.'
              : 'Failed to fetch playlist info.';
      controller.addError(YtDlpException(msg));
    }
    controller.close();
  }

  // ─── Private ─────────────────────────────────────────────────────────────────

  Future<void> _startProcess(
    DownloadItem item,
    StreamController<DownloadItem> controller,
  ) async {
    final args = _buildArgs(item);
    _logger.d('[yt-dlp] Running: $_ytDlpPath ${args.join(' ')}');

    controller.add(item.copyWith(status: DownloadStatus.preparing));

    late Process process;
    try {
      process = await Process.start(_ytDlpPath, args);
    } on ProcessException catch (e) {
      throw YtDlpException('Failed to start yt-dlp process.', cause: e);
    }

    _processes[item.id] = process;

    DownloadItem current = item.copyWith(status: DownloadStatus.downloading);

    // Phase tracking: yt-dlp downloads video and audio as separate files
    // for formats like bestvideo+bestaudio. We track phases to merge
    // them into a single progress row.
    int currentPhase = 1;
    double lastPercentage = 0;
    int accumulatedBytes = 0; // bytes from completed phases
    int accumulatedTotal = 0; // total bytes from completed phases

    // Parse stdout line by line
    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(
      (line) {
        _logger.t('[yt-dlp stdout] $line');
        final updated = _parseLine(line, current);
        if (updated != null) {
          // Detect new download phase: percentage drops significantly
          final newPct = updated.progress?.percentage ?? 0;
          if (lastPercentage > 90 && newPct < 10 && currentPhase >= 1) {
            // Save the completed phase bytes
            accumulatedBytes += current.progress?.totalBytes ?? current.progress?.downloadedBytes ?? 0;
            accumulatedTotal += current.progress?.totalBytes ?? 0;
            currentPhase++;
          }
          lastPercentage = newPct;

          // Merge progress across phases
          if (currentPhase > 1 && updated.progress != null) {
            final phaseDownloaded = updated.progress!.downloadedBytes ?? 0;
            final phaseTotal = updated.progress!.totalBytes ?? 0;
            final totalDownloaded = accumulatedBytes + phaseDownloaded;
            final totalSize = accumulatedTotal + phaseTotal;
            final mergedPercentage = totalSize > 0
                ? (totalDownloaded / totalSize * 100).clamp(0.0, 99.9)
                : newPct;
            current = updated.copyWith(
              progress: updated.progress!.copyWith(
                percentage: mergedPercentage,
                downloadedBytes: totalDownloaded,
                totalBytes: totalSize > 0 ? totalSize : null,
              ),
            );
          } else {
            current = updated;
          }
          if (!controller.isClosed) controller.add(current);
        }
      },
      cancelOnError: false,
    );

    // Log stderr (yt-dlp may write post-processing status here too).
    final stderrBuffer = StringBuffer();
    process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen(
      (line) {
        _logger.w('[yt-dlp stderr] $line');
        stderrBuffer.writeln(line);

        // Surface post-processing (merge/convert/embed) so the row doesn't
        // appear stuck at 100% while yt-dlp finishes up.
        final pp = _detectPostProcessing(line, current);
        if (pp != null && current.status != pp && !controller.isClosed) {
          current = current.copyWith(status: pp);
          controller.add(current);
        }
      },
      cancelOnError: false,
    );

    final exitCode = await process.exitCode;
    _processes.remove(item.id);

    if (controller.isClosed) return;

    if (exitCode == 0) {
      controller.add(current.copyWith(
        status: DownloadStatus.completed,
        progress: current.progress?.copyWith(percentage: 100.0) ?? const DownloadProgress(percentage: 100.0),
      ));
      controller.close();
    } else if (exitCode == 1 && stderrBuffer.toString().contains('Interrupt')) {
      // User cancelled
      controller.add(current.copyWith(status: DownloadStatus.cancelled));
      controller.close();
    } else {
      final stderr = stderrBuffer.toString().trim();
      throw YtDlpException(
        _extractErrorMessage(stderr),
        exitCode: exitCode,
        stderr: stderr,
      );
    }
  }

  /// Builds the yt-dlp argument list from [item] configuration.
  List<String> _buildArgs(DownloadItem item) {
    final args = <String>[
      // Playlist mode control
      if (item.isPlaylist) '--yes-playlist' else '--no-playlist',
      '--newline',
      '--progress',
      '--progress-template',
      'download:%(progress._percent_str)s|%(progress._speed_str)s|%(progress._eta_str)s|%(progress.downloaded_bytes)s|%(progress.total_bytes)s|%(progress.filename)s',
      // Post-processing progress (merge / convert / embed). Lets the UI leave
      // the "downloading" state once the bytes are done and yt-dlp is busy
      // merging or converting, instead of appearing stuck at 100%.
      '--progress-template',
      'postprocess:__PP__|%(progress.status)s',
      '--print', 'after_filter:%(title)s|%(webpage_url_domain)s|%(thumbnail)s',
      // Final output path, printed after the file has been moved to its final
      // location (post-processing complete). Used for "open folder" / "play".
      '--print', 'after_move:__FILE__%(filepath)s',
      '--no-simulate',
      '--no-warnings',

      // ── Speed & reliability ──────────────────────────────────────────────
      // Download fragments in parallel. This is the single biggest speedup for
      // fragmented DASH/HLS streams (most YouTube videos) on fast connections.
      // Users can override this by passing their own value in Custom yt-dlp
      // arguments (the later value wins).
      '--concurrent-fragments', '4',
      // Retry transient network failures instead of giving up immediately.
      '--retries', '10',
      '--fragment-retries', '10',
    ];

    // FFmpeg location
    final ffmpegPath = _ffmpegPath;
    if (ffmpegPath != null) {
      args.addAll(['--ffmpeg-location', ffmpegPath]);
    }

    // Output template — use custom filename if provided
    final filenameTemplate = (item.customFilename != null && item.customFilename!.trim().isNotEmpty)
        ? item.customFilename!.trim()
        : '%(title)s';
    args.addAll([
      '-o',
      '${item.outputDirectory}/$filenameTemplate.%(ext)s',
    ]);

    // Download type specific args
    if (item.type == DownloadType.audio) {
      args.addAll(['-x', '--audio-format', 'mp3']);
      if (item.audioQuality != AudioQuality.original) {
        args.addAll(['--audio-quality', item.audioQuality.bitrateArg]);
      }
    } else {
      final formatStr = item.videoQuality.formatString;
      if (formatStr.isNotEmpty) {
        args.addAll(['-f', formatStr]);
      }
      args.addAll(['--merge-output-format', 'mp4']);
    }

    // Subtitles
    if (item.downloadSubtitles) {
      args.add('--write-subs');
      args.add('--write-auto-subs');
      // Always specify a subtitle language to avoid failures
      final subLang = (item.subtitleLanguage != null && item.subtitleLanguage!.isNotEmpty)
          ? item.subtitleLanguage!
          : 'en';
      args.addAll(['--sub-lang', subLang]);
      if (item.embedSubtitles) args.add('--embed-subs');
    }

    // Thumbnail
    if (item.downloadThumbnail || item.embedThumbnail) {
      args.add('--write-thumbnail');
      if (item.embedThumbnail) args.add('--embed-thumbnail');
    }

    // Metadata
    if (item.embedMetadata) args.add('--embed-metadata');

    // SponsorBlock
    if (item.sponsorBlock) {
      args.addAll(['--sponsorblock-remove', 'sponsor,intro,outro,selfpromo']);
    }

    // Custom args (parsed and appended)
    if (item.customArgs != null && item.customArgs!.trim().isNotEmpty) {
      args.addAll(item.customArgs!.trim().split(RegExp(r'\s+')));
    }

    args.add(item.url);
    return args;
  }

  /// Parses a single output line from yt-dlp into a state update.
  DownloadItem? _parseLine(String line, DownloadItem current) {
    // Final output path marker emitted by `--print after_move:__FILE__...`.
    if (line.startsWith('__FILE__')) {
      final path = line.substring('__FILE__'.length).trim();
      return path.isNotEmpty ? current.copyWith(outputPath: path) : null;
    }

    // Post-processing marker emitted by the `postprocess:` progress template.
    if (line.toLowerCase().startsWith('__pp__|')) {
      final status = _detectPostProcessing(line, current);
      return status != null ? current.copyWith(status: status) : null;
    }

    // Progress line: percent|speed|eta|downloaded|total|filename
    final parts = line.split('|');
    if (parts.length >= 5 && parts[0].contains('%')) {
      final percentStr = parts[0].trim().replaceAll('%', '').trim();
      final percent = double.tryParse(percentStr);
      final speed = SizeFormatter.parseYtDlpSpeed(parts[1].trim());
      final eta = DurationFormatter.parseEta(parts[2].trim());
      final downloaded = SizeFormatter.parseYtDlpSize(parts[3].trim());
      final total = SizeFormatter.parseYtDlpSize(parts[4].trim());
      final filename = parts.length > 5 ? parts[5].trim() : null;

      if (percent != null) {
        DownloadStatus status = current.status;
        // A fresh progress line means we're actively downloading bytes again
        // (handles the audio phase that follows the video phase).
        if (status == DownloadStatus.preparing ||
            status == DownloadStatus.merging ||
            status == DownloadStatus.converting) {
          status = DownloadStatus.downloading;
        }

        return current.copyWith(
          status: status,
          progress: DownloadProgress(
            percentage: percent,
            speed: speed,
            eta: eta,
            downloadedBytes: downloaded,
            totalBytes: total,
            filename: filename,
          ),
        );
      }
    }

    // Metadata line: title|domain|thumbnail
    if (parts.length == 3 && !parts[0].contains('%')) {
      final title = parts[0].trim();
      final domain = parts[1].trim();
      final thumbnail = parts[2].trim();
      if (title.isNotEmpty) {
        return current.copyWith(
          title: title,
          websiteName: domain,
          thumbnailUrl: thumbnail.isNotEmpty ? thumbnail : null,
        );
      }
    }

    // Fallback: detect post-processing from yt-dlp's own log lines.
    final pp = _detectPostProcessing(line, current);
    if (pp != null) return current.copyWith(status: pp);

    return null;
  }

  /// Detects whether [line] indicates a post-processing phase (merging audio
  /// and video, extracting/converting audio, embedding metadata/thumbnails,
  /// SponsorBlock, etc.), returning the status to show or null if it doesn't.
  DownloadStatus? _detectPostProcessing(String line, DownloadItem current) {
    final lower = line.toLowerCase();

    // Marker from `postprocess:__PP__|%(progress.status)s`.
    if (lower.startsWith('__pp__|')) {
      final status = lower.split('|').elementAtOrNull(1)?.trim();
      // 'finished' means the process is about to exit → let exit code complete it.
      if (status == 'finished') return null;
      return current.type == DownloadType.video
          ? DownloadStatus.merging
          : DownloadStatus.converting;
    }

    // yt-dlp postprocessor log lines (fallback when the template is not shown).
    if (lower.startsWith('[merger]') || lower.contains('merging formats')) {
      return DownloadStatus.merging;
    }
    if (lower.startsWith('[extractaudio]') ||
        lower.startsWith('[videoconvertor]') ||
        lower.startsWith('[videoremuxer]') ||
        lower.startsWith('[fixup') ||
        lower.startsWith('[embedthumbnail]') ||
        lower.startsWith('[metadata]') ||
        lower.startsWith('[sponsorblock]') ||
        lower.startsWith('[movefiles]') ||
        lower.startsWith('[ffmpeg]') ||
        lower.contains('converting')) {
      return DownloadStatus.converting;
    }

    return null;
  }

  String _extractErrorMessage(String stderr) {
    if (stderr.contains('is not a valid URL')) return 'The provided URL is not valid or unsupported.';
    if (stderr.contains('Video unavailable')) return 'Video is unavailable or private.';
    if (stderr.contains('Sign in')) return 'This video requires authentication.';
    if (stderr.contains('429')) return 'Rate limited by server. Please wait before retrying.';
    if (stderr.contains('network')) return 'Network error. Check your internet connection.';
    final lines = stderr.split('\n');
    final errorLine = lines.where((l) => l.contains('ERROR')).firstOrNull;
    return errorLine?.replaceAll('ERROR:', '').trim() ?? 'yt-dlp encountered an error.';
  }
}
