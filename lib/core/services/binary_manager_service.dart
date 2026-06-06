import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../utils/file_utils.dart';

/// Progress callback for binary download operations.
typedef DownloadProgressCallback = void Function(String message, double progress);

/// Manages the lifecycle of yt-dlp and FFmpeg binaries.
///
/// Responsibilities:
/// - Detect OS and select the correct binary variant
/// - Download and verify yt-dlp from GitHub releases
/// - Download and verify FFmpeg
/// - Store binaries in the application support directory
/// - Persist installation state in [SharedPreferences]
/// - Provide paths to both binaries at runtime
class BinaryManagerService {
  BinaryManagerService({
    required SharedPreferences prefs,
    required Dio dio,
    required Logger logger,
  })  : _prefs = prefs,
        _dio = dio,
        _logger = logger;

  final SharedPreferences _prefs;
  final Dio _dio;
  final Logger _logger;

  /// Cached path to the yt-dlp binary.
  String? _ytDlpPath;

  /// Cached path to the ffmpeg binary.
  String? _ffmpegPath;

  // ─── Public API ─────────────────────────────────────────────────────────────

  /// Returns the path to the yt-dlp binary, or null if not installed.
  String? get ytDlpPath => _ytDlpPath ?? _prefs.getString(AppConstants.keyYtDlpPath);

  /// Returns the path to the ffmpeg binary, or null if not installed.
  String? get ffmpegPath => _ffmpegPath ?? _prefs.getString(AppConstants.keyFfmpegPath);

  /// Whether setup has been completed at least once.
  bool get isSetupComplete => _prefs.getBool(AppConstants.keySetupComplete) ?? false;

  /// Performs the full first-time or update setup.
  ///
  /// [onProgress] is called with a human-readable [message] and [progress]
  /// in the range 0.0–1.0.
  Future<void> setup({DownloadProgressCallback? onProgress}) async {
    _logger.i('BinaryManagerService: Starting setup');

    onProgress?.call('Checking installation directory…', 0.0);
    final binDir = await FileUtils.getBinariesDirectory();

    // ── yt-dlp ───────────────────────────────────────────────────────────────
    onProgress?.call('Fetching latest yt-dlp version…', 0.05);
    final latestVersion = await _fetchLatestYtDlpVersion();
    final installedVersion = _prefs.getString(AppConstants.keyYtDlpVersion);

    if (installedVersion == null || installedVersion != latestVersion) {
      onProgress?.call('Downloading yt-dlp $latestVersion…', 0.1);
      await _downloadYtDlp(binDir, latestVersion, onProgress: (p) {
        onProgress?.call('Downloading yt-dlp… ${(p * 100).toInt()}%', 0.1 + p * 0.45);
      });
      await _prefs.setString(AppConstants.keyYtDlpVersion, latestVersion);
      _logger.i('yt-dlp $latestVersion installed');
    } else {
      _logger.i('yt-dlp $installedVersion already up to date');
    }

    onProgress?.call('Verifying yt-dlp…', 0.55);
    await _verifyYtDlp(binDir);

    // ── FFmpeg ───────────────────────────────────────────────────────────────
    final ffmpegInstalled = await _isFfmpegAvailable(binDir);
    if (!ffmpegInstalled) {
      onProgress?.call('Downloading FFmpeg…', 0.6);
      await _downloadFfmpeg(binDir, onProgress: (p) {
        onProgress?.call('Downloading FFmpeg… ${(p * 100).toInt()}%', 0.6 + p * 0.35);
      });
    }

    onProgress?.call('Verifying FFmpeg…', 0.95);
    await _verifyFfmpeg(binDir);

    await _prefs.setBool(AppConstants.keySetupComplete, true);
    onProgress?.call('Setup complete!', 1.0);
    _logger.i('BinaryManagerService: Setup complete');
  }

  // ─── Private: yt-dlp ────────────────────────────────────────────────────────

  Future<String> _fetchLatestYtDlpVersion() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConstants.ytDlpReleasesApi,
        options: Options(
          headers: {'Accept': 'application/vnd.github+json'},
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final tag = response.data?['tag_name'] as String?;
      if (tag == null) throw const BinarySetupException('Could not parse yt-dlp release tag.');
      return tag;
    } on DioException catch (e) {
      throw BinarySetupException('Failed to fetch yt-dlp release info.', cause: e);
    }
  }

  Future<void> _downloadYtDlp(
    Directory binDir,
    String version, {
    void Function(double)? onProgress,
  }) async {
    final binaryName = _ytDlpBinaryName;
    final downloadUrl = 'https://github.com/yt-dlp/yt-dlp/releases/download/$version/$binaryName';
    final destPath = p.join(binDir.path, Platform.isWindows ? 'yt-dlp.exe' : 'yt-dlp');

    try {
      await _dio.download(
        downloadUrl,
        destPath,
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress?.call(received / total);
        },
      );
      await FileUtils.makeExecutable(destPath);
      _ytDlpPath = destPath;
      await _prefs.setString(AppConstants.keyYtDlpPath, destPath);
    } on DioException catch (e) {
      throw BinarySetupException('Failed to download yt-dlp.', cause: e);
    }
  }

  Future<void> _verifyYtDlp(Directory binDir) async {
    final path = ytDlpPath;
    if (path == null) throw const BinarySetupException('yt-dlp path not set after download.');

    try {
      final result = await Process.run(path, ['--version']);
      if (result.exitCode != 0) {
        throw BinarySetupException('yt-dlp verification failed: ${result.stderr}');
      }
      _logger.d('yt-dlp version: ${result.stdout.toString().trim()}');
    } on ProcessException catch (e) {
      throw BinarySetupException('Could not run yt-dlp.', cause: e);
    }
  }

  // ─── Private: FFmpeg ─────────────────────────────────────────────────────────

  Future<bool> _isFfmpegAvailable(Directory binDir) async {
    // Check app-local copy first
    final localPath = p.join(binDir.path, Platform.isWindows ? 'ffmpeg.exe' : 'ffmpeg');
    if (await File(localPath).exists()) {
      _ffmpegPath = localPath;
      await _prefs.setString(AppConstants.keyFfmpegPath, localPath);
      return true;
    }
    // Check system PATH
    try {
      final result = await Process.run(
        Platform.isWindows ? 'where' : 'which',
        ['ffmpeg'],
      );
      if (result.exitCode == 0) {
        final systemPath = result.stdout.toString().trim().split('\n').first;
        _ffmpegPath = systemPath;
        await _prefs.setString(AppConstants.keyFfmpegPath, systemPath);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> _downloadFfmpeg(
    Directory binDir, {
    void Function(double)? onProgress,
  }) async {
    // macOS: download static ffmpeg binary from evermeet.cx
    // Windows: download from BtbN FFmpeg builds (zip)
    // For simplicity, on macOS we try brew first, then direct download
    if (Platform.isMacOS) {
      await _downloadFfmpegMacOS(binDir, onProgress: onProgress);
    } else if (Platform.isWindows) {
      await _downloadFfmpegWindows(binDir, onProgress: onProgress);
    } else {
      throw const BinarySetupException('FFmpeg auto-download not supported on this platform. Please install FFmpeg manually.');
    }
  }

  Future<void> _downloadFfmpegMacOS(
    Directory binDir, {
    void Function(double)? onProgress,
  }) async {
    // Try homebrew first (silent check)
    try {
      final brew = await Process.run('brew', ['--prefix', 'ffmpeg']);
      if (brew.exitCode == 0) {
        // brew ffmpeg exists, find the binary
        final result = await Process.run('which', ['ffmpeg']);
        if (result.exitCode == 0) {
          final systemPath = result.stdout.toString().trim();
          _ffmpegPath = systemPath;
          await _prefs.setString(AppConstants.keyFfmpegPath, systemPath);
          return;
        }
      }
    } catch (_) {}

    // Direct download from evermeet.cx
    final zipPath = p.join(binDir.path, 'ffmpeg.zip');
    try {
      await _dio.download(
        AppConstants.ffmpegMacOSUrl,
        zipPath,
        onReceiveProgress: (r, t) {
          if (t > 0) onProgress?.call(r / t * 0.8);
        },
      );
      onProgress?.call(0.9);
      await Process.run('unzip', ['-o', zipPath, '-d', binDir.path]);
      final destPath = p.join(binDir.path, 'ffmpeg');
      await FileUtils.makeExecutable(destPath);
      _ffmpegPath = destPath;
      await _prefs.setString(AppConstants.keyFfmpegPath, destPath);
      await File(zipPath).delete();
      onProgress?.call(1.0);
    } on DioException catch (e) {
      throw BinarySetupException('Failed to download FFmpeg.', cause: e);
    }
  }

  Future<void> _downloadFfmpegWindows(
    Directory binDir, {
    void Function(double)? onProgress,
  }) async {
    final zipPath = p.join(binDir.path, 'ffmpeg.zip');
    try {
      await _dio.download(
        AppConstants.ffmpegWindowsUrl,
        zipPath,
        onReceiveProgress: (r, t) {
          if (t > 0) onProgress?.call(r / t * 0.8);
        },
      );
      onProgress?.call(0.85);
      // Extract using PowerShell
      await Process.run('powershell', [
        '-Command',
        'Expand-Archive -Path "$zipPath" -DestinationPath "${binDir.path}" -Force',
      ]);
      // Find the extracted ffmpeg.exe
      final extracted = binDir.listSync(recursive: true).whereType<File>().firstWhere(
            (f) => f.path.endsWith('ffmpeg.exe'),
            orElse: () => throw const BinarySetupException('ffmpeg.exe not found after extraction.'),
          );
      final destPath = p.join(binDir.path, 'ffmpeg.exe');
      await extracted.copy(destPath);
      _ffmpegPath = destPath;
      await _prefs.setString(AppConstants.keyFfmpegPath, destPath);
      await File(zipPath).delete();
      onProgress?.call(1.0);
    } on DioException catch (e) {
      throw BinarySetupException('Failed to download FFmpeg.', cause: e);
    }
  }

  Future<void> _verifyFfmpeg(Directory binDir) async {
    final path = ffmpegPath;
    if (path == null) throw const BinarySetupException('FFmpeg path not set.');
    try {
      final result = await Process.run(path, ['-version']);
      if (result.exitCode != 0) {
        throw BinarySetupException('FFmpeg verification failed: ${result.stderr}');
      }
      _logger.d('FFmpeg: ${result.stdout.toString().split('\n').first}');
    } on ProcessException catch (e) {
      throw BinarySetupException('Could not run FFmpeg.', cause: e);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String get _ytDlpBinaryName {
    if (Platform.isMacOS) return AppConstants.ytDlpMacOSBinary;
    if (Platform.isWindows) return AppConstants.ytDlpWindowsBinary;
    return AppConstants.ytDlpLinuxBinary;
  }
}
