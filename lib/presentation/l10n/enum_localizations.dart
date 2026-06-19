import '../../domain/entities/app_settings.dart';
import '../../domain/entities/download_enums.dart';
import '../../l10n/app_localizations.dart';

/// Localized labels for domain enums.
///
/// The enums keep their English `label` getters for logging/debugging; these
/// extensions provide the user-facing, translated text used in the UI.

extension DownloadStatusL10n on DownloadStatus {
  String localizedLabel(AppLocalizations l) => switch (this) {
        DownloadStatus.waiting => l.statusWaiting,
        DownloadStatus.preparing => l.statusPreparing,
        DownloadStatus.downloading => l.statusDownloading,
        DownloadStatus.converting => l.statusConverting,
        DownloadStatus.merging => l.statusMerging,
        DownloadStatus.completed => l.statusCompleted,
        DownloadStatus.failed => l.statusFailed,
        DownloadStatus.paused => l.statusPaused,
        DownloadStatus.cancelled => l.statusCancelled,
      };
}

extension DownloadTypeL10n on DownloadType {
  String localizedLabel(AppLocalizations l) => switch (this) {
        DownloadType.video => l.typeVideo,
        DownloadType.audio => l.typeAudio,
      };
}

extension VideoQualityL10n on VideoQuality {
  String localizedLabel(AppLocalizations l) => switch (this) {
        VideoQuality.best => l.qualityBest,
        VideoQuality.high => l.qualityHigh,
        VideoQuality.medium => l.qualityMedium,
        VideoQuality.low => l.qualityLow,
        VideoQuality.custom => l.qualityCustom,
      };
}

extension AudioQualityL10n on AudioQuality {
  String localizedLabel(AppLocalizations l) => switch (this) {
        AudioQuality.best => l.audioBest,
        AudioQuality.mp3_320 => l.audioMp3_320,
        AudioQuality.mp3_256 => l.audioMp3_256,
        AudioQuality.mp3_192 => l.audioMp3_192,
        AudioQuality.mp3_128 => l.audioMp3_128,
        AudioQuality.original => l.audioOriginal,
      };
}

extension AppThemeModeL10n on AppThemeMode {
  String localizedLabel(AppLocalizations l) => switch (this) {
        AppThemeMode.light => l.themeLight,
        AppThemeMode.dark => l.themeDark,
        AppThemeMode.system => l.themeSystem,
      };
}
