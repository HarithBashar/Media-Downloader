/// Application-wide constants for Media Downloader.
///
/// Centralizes all string literals, numeric limits, and configuration values
/// to avoid magic numbers/strings scattered throughout the codebase.
library;

class AppConstants {
  AppConstants._();

  // ─── App metadata ───────────────────────────────────────────────────────────
  static const String appName = 'Media Downloader';
  static const String appVersion = '1.0.0';
  static const String githubRepo = 'https://github.com/yt-dlp/yt-dlp';

  // ─── yt-dlp GitHub release API ──────────────────────────────────────────────
  static const String ytDlpReleasesApi =
      'https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest';
  static const String ytDlpMacOSBinary = 'yt-dlp_macos';
  static const String ytDlpWindowsBinary = 'yt-dlp.exe';
  static const String ytDlpLinuxBinary = 'yt-dlp';

  // ─── FFmpeg download sources ─────────────────────────────────────────────────
  static const String ffmpegMacOSUrl =
      'https://evermeet.cx/ffmpeg/getrelease/ffmpeg/zip';
  static const String ffmpegWindowsUrl =
      'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/'
      'ffmpeg-master-latest-win64-gpl.zip';

  // ─── Storage keys ────────────────────────────────────────────────────────────
  static const String keyYtDlpVersion = 'ytdlp_version';
  static const String keyYtDlpPath = 'ytdlp_path';
  static const String keyFfmpegPath = 'ffmpeg_path';
  static const String keySetupComplete = 'setup_complete';
  static const String keyDownloadHistory = 'download_history';
  static const String keySettings = 'app_settings';

  // ─── Directory names ─────────────────────────────────────────────────────────
  static const String binariesDir = 'binaries';
  static const String logsDir = 'logs';
  static const String archiveDir = 'archive';

  // ─── Download limits ────────────────────────────────────────────────────────
  static const int defaultMaxConcurrentDownloads = 3;
  static const int defaultRetryCount = 3;
  static const int progressUpdateIntervalSeconds = 2;
  static const int maxHistoryItems = 1000;

  // ─── Supported video formats ─────────────────────────────────────────────────
  static const List<String> videoFormats = ['mp4', 'mkv', 'webm', 'avi', 'mov'];
  static const List<String> audioFormats = ['mp3', 'aac', 'flac', 'wav', 'm4a', 'ogg', 'opus'];

  // ─── Subtitle languages ──────────────────────────────────────────────────────
  static const List<Map<String, String>> subtitleLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'ar', 'name': 'Arabic'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'it', 'name': 'Italian'},
    {'code': 'ja', 'name': 'Japanese'},
    {'code': 'ko', 'name': 'Korean'},
    {'code': 'pt', 'name': 'Portuguese'},
    {'code': 'ru', 'name': 'Russian'},
    {'code': 'zh', 'name': 'Chinese'},
  ];

  // ─── Window constraints ──────────────────────────────────────────────────────
  static const double minWindowWidth = 900;
  static const double minWindowHeight = 600;
  static const double defaultWindowWidth = 1200;
  static const double defaultWindowHeight = 800;

  // ─── UI dimensions ───────────────────────────────────────────────────────────
  static const double sidebarWidth = 220;
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double inputBorderRadius = 10.0;

  // ─── Animation durations ─────────────────────────────────────────────────────
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 600);
}

/// Route path constants used by go_router.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String setup = '/setup';
  static const String home = '/';
  static const String queue = '/queue';
  static const String history = '/history';
  static const String settings = '/settings';
}
