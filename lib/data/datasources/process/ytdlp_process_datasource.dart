import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/utils/size_formatter.dart';
import '../../../domain/entities/download_enums.dart';
import '../../../domain/entities/download_item.dart';

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

    // Parse stdout line by line
    process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(
      (line) {
        _logger.t('[yt-dlp stdout] $line');
        final updated = _parseLine(line, current);
        if (updated != null) {
          current = updated;
          if (!controller.isClosed) controller.add(current);
        }
      },
      cancelOnError: false,
    );

    // Log stderr (yt-dlp writes progress info to stderr too)
    final stderrBuffer = StringBuffer();
    process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen(
      (line) {
        _logger.w('[yt-dlp stderr] $line');
        stderrBuffer.writeln(line);
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
      '--no-playlist',
      '--newline',
      '--progress',
      '--progress-template',
      'download:%(progress._percent_str)s|%(progress._speed_str)s|%(progress._eta_str)s|%(progress.downloaded_bytes)s|%(progress.total_bytes)s|%(progress.filename)s',
      '--print', 'after_filter:%(title)s|%(webpage_url_domain)s|%(thumbnail)s',
      '--no-simulate',
      '--no-warnings',
    ];

    // FFmpeg location
    final ffmpegPath = _ffmpegPath;
    if (ffmpegPath != null) {
      args.addAll(['--ffmpeg-location', ffmpegPath]);
    }

    // Output template
    args.addAll([
      '-o',
      '${item.outputDirectory}/%(title)s.%(ext)s',
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
      if (item.subtitleLanguage != null) {
        args.addAll(['--sub-lang', item.subtitleLanguage!]);
      }
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

  /// Parses a single stdout line from yt-dlp into a state update.
  DownloadItem? _parseLine(String line, DownloadItem current) {
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
        // Detect conversion/merging phases
        DownloadStatus status = current.status;
        if (line.toLowerCase().contains('convert')) status = DownloadStatus.converting;
        if (line.toLowerCase().contains('merg')) status = DownloadStatus.merging;
        if (status == DownloadStatus.preparing && percent > 0) status = DownloadStatus.downloading;

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

    // Detect conversion/merging from log lines
    if (line.contains('[ffmpeg]') || line.contains('Converting')) {
      return current.copyWith(status: DownloadStatus.converting);
    }
    if (line.contains('Merging')) {
      return current.copyWith(status: DownloadStatus.merging);
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
