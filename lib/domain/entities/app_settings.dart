/// Application settings entity.
///
/// Encapsulates all user-configurable preferences with sensible defaults.
class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.language = 'en',
    this.defaultOutputDirectory,
    this.maxConcurrentDownloads = 3,
    this.retryCount = 3,
    this.speedLimitKbps = 0,
    this.autoUpdateYtDlp = true,
    this.customYtDlpArgs = '',
    this.customFfmpegPath = '',
    this.autoOpenFile = false,
    this.autoOpenFolder = false,
    this.minimizeToTray = false,
    this.startOnStartup = false,
    this.debugLogging = false,
    this.useDownloadArchive = false,
    this.proxyUrl = '',
    this.cookiesFromBrowser = '',
    this.sponsorBlockCategories = const [],
    this.embedThumbnailDefault = false,
    this.embedMetadataDefault = true,
    this.defaultSubtitleLanguage = 'en',
  });

  final AppThemeMode themeMode;
  final String language;
  final String? defaultOutputDirectory;
  final int maxConcurrentDownloads;
  final int retryCount;

  /// Speed limit in KB/s. 0 means unlimited.
  final int speedLimitKbps;

  final bool autoUpdateYtDlp;
  final String customYtDlpArgs;
  final String customFfmpegPath;
  final bool autoOpenFile;
  final bool autoOpenFolder;
  final bool minimizeToTray;
  final bool startOnStartup;
  final bool debugLogging;
  final bool useDownloadArchive;
  final String proxyUrl;
  final String cookiesFromBrowser;
  final List<String> sponsorBlockCategories;
  final bool embedThumbnailDefault;
  final bool embedMetadataDefault;
  final String defaultSubtitleLanguage;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? language,
    String? defaultOutputDirectory,
    int? maxConcurrentDownloads,
    int? retryCount,
    int? speedLimitKbps,
    bool? autoUpdateYtDlp,
    String? customYtDlpArgs,
    String? customFfmpegPath,
    bool? autoOpenFile,
    bool? autoOpenFolder,
    bool? minimizeToTray,
    bool? startOnStartup,
    bool? debugLogging,
    bool? useDownloadArchive,
    String? proxyUrl,
    String? cookiesFromBrowser,
    List<String>? sponsorBlockCategories,
    bool? embedThumbnailDefault,
    bool? embedMetadataDefault,
    String? defaultSubtitleLanguage,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      defaultOutputDirectory: defaultOutputDirectory ?? this.defaultOutputDirectory,
      maxConcurrentDownloads: maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      retryCount: retryCount ?? this.retryCount,
      speedLimitKbps: speedLimitKbps ?? this.speedLimitKbps,
      autoUpdateYtDlp: autoUpdateYtDlp ?? this.autoUpdateYtDlp,
      customYtDlpArgs: customYtDlpArgs ?? this.customYtDlpArgs,
      customFfmpegPath: customFfmpegPath ?? this.customFfmpegPath,
      autoOpenFile: autoOpenFile ?? this.autoOpenFile,
      autoOpenFolder: autoOpenFolder ?? this.autoOpenFolder,
      minimizeToTray: minimizeToTray ?? this.minimizeToTray,
      startOnStartup: startOnStartup ?? this.startOnStartup,
      debugLogging: debugLogging ?? this.debugLogging,
      useDownloadArchive: useDownloadArchive ?? this.useDownloadArchive,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      cookiesFromBrowser: cookiesFromBrowser ?? this.cookiesFromBrowser,
      sponsorBlockCategories: sponsorBlockCategories ?? this.sponsorBlockCategories,
      embedThumbnailDefault: embedThumbnailDefault ?? this.embedThumbnailDefault,
      embedMetadataDefault: embedMetadataDefault ?? this.embedMetadataDefault,
      defaultSubtitleLanguage: defaultSubtitleLanguage ?? this.defaultSubtitleLanguage,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'language': language,
        'defaultOutputDirectory': defaultOutputDirectory,
        'maxConcurrentDownloads': maxConcurrentDownloads,
        'retryCount': retryCount,
        'speedLimitKbps': speedLimitKbps,
        'autoUpdateYtDlp': autoUpdateYtDlp,
        'customYtDlpArgs': customYtDlpArgs,
        'customFfmpegPath': customFfmpegPath,
        'autoOpenFile': autoOpenFile,
        'autoOpenFolder': autoOpenFolder,
        'minimizeToTray': minimizeToTray,
        'startOnStartup': startOnStartup,
        'debugLogging': debugLogging,
        'useDownloadArchive': useDownloadArchive,
        'proxyUrl': proxyUrl,
        'cookiesFromBrowser': cookiesFromBrowser,
        'sponsorBlockCategories': sponsorBlockCategories,
        'embedThumbnailDefault': embedThumbnailDefault,
        'embedMetadataDefault': embedMetadataDefault,
        'defaultSubtitleLanguage': defaultSubtitleLanguage,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        themeMode: AppThemeMode.values.firstWhere(
          (e) => e.name == json['themeMode'],
          orElse: () => AppThemeMode.system,
        ),
        language: json['language'] as String? ?? 'en',
        defaultOutputDirectory: json['defaultOutputDirectory'] as String?,
        maxConcurrentDownloads: json['maxConcurrentDownloads'] as int? ?? 3,
        retryCount: json['retryCount'] as int? ?? 3,
        speedLimitKbps: json['speedLimitKbps'] as int? ?? 0,
        autoUpdateYtDlp: json['autoUpdateYtDlp'] as bool? ?? true,
        customYtDlpArgs: json['customYtDlpArgs'] as String? ?? '',
        customFfmpegPath: json['customFfmpegPath'] as String? ?? '',
        autoOpenFile: json['autoOpenFile'] as bool? ?? false,
        autoOpenFolder: json['autoOpenFolder'] as bool? ?? false,
        minimizeToTray: json['minimizeToTray'] as bool? ?? false,
        startOnStartup: json['startOnStartup'] as bool? ?? false,
        debugLogging: json['debugLogging'] as bool? ?? false,
        useDownloadArchive: json['useDownloadArchive'] as bool? ?? false,
        proxyUrl: json['proxyUrl'] as String? ?? '',
        cookiesFromBrowser: json['cookiesFromBrowser'] as String? ?? '',
        sponsorBlockCategories: List<String>.from(json['sponsorBlockCategories'] as List? ?? []),
        embedThumbnailDefault: json['embedThumbnailDefault'] as bool? ?? false,
        embedMetadataDefault: json['embedMetadataDefault'] as bool? ?? true,
        defaultSubtitleLanguage: json['defaultSubtitleLanguage'] as String? ?? 'en',
      );
}

/// Application theme mode preference.
enum AppThemeMode {
  light,
  dark,
  system;

  String get label => switch (this) {
        light => 'Light',
        dark => 'Dark',
        system => 'System',
      };
}
