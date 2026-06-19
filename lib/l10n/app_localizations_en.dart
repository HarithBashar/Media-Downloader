// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navDownload => 'Download';

  @override
  String get navPlaylist => 'Playlist';

  @override
  String get navQueue => 'Queue';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get homeTitle => 'Download';

  @override
  String get addDownload => 'Add Download';

  @override
  String get addDownloadSubtitle =>
      'Paste a URL, drag & drop, or let us detect from your clipboard';

  @override
  String get invalidUrl => 'Please enter a valid URL';

  @override
  String get selectDownloadLocation => 'Select Download Location';

  @override
  String get downloadAddedToQueue => 'Download added to queue';

  @override
  String get dropUrlHere => 'Drop URL here…';

  @override
  String get pasteUrlHint =>
      'Paste URL here (YouTube, Vimeo, TikTok, and 1000+ more)';

  @override
  String get clear => 'Clear';

  @override
  String get pasteFromClipboard => 'Paste from clipboard';

  @override
  String get type => 'Type';

  @override
  String get quality => 'Quality';

  @override
  String get saveTo => 'Save to';

  @override
  String get filename => 'Filename';

  @override
  String get filenameHint => 'Leave empty to use original title';

  @override
  String get options => 'Options';

  @override
  String get embedThumbnail => 'Embed Thumbnail';

  @override
  String get embedMetadata => 'Embed Metadata';

  @override
  String get subtitles => 'Subtitles';

  @override
  String get sponsorBlock => 'SponsorBlock';

  @override
  String get subtitleSettings => 'Subtitle Settings';

  @override
  String get language => 'Language';

  @override
  String get embedInVideo => 'Embed in Video';

  @override
  String get noFolderSelected => 'No folder selected';

  @override
  String get browse => 'Browse';

  @override
  String get startDownload => 'Start Download';

  @override
  String get playlistTitle => 'Playlist Download';

  @override
  String get fetchAndDownloadPlaylist => 'Fetch & Download Playlist';

  @override
  String get playlistSubtitle =>
      'Paste a playlist or channel URL to load all videos before downloading.';

  @override
  String get pastePlaylistUrlHint => 'Paste playlist URL here...';

  @override
  String get fetching => 'Fetching...';

  @override
  String get fetch => 'Fetch';

  @override
  String get selectAtLeastOneVideo =>
      'Please select at least one video to download.';

  @override
  String get selectDownloadFolder => 'Please select a download folder.';

  @override
  String get selectDownloadFolderDialog => 'Select Download Folder';

  @override
  String addedVideosToQueue(int count) {
    return 'Added $count videos to queue.';
  }

  @override
  String get noVideosFound => 'No videos found in this playlist.';

  @override
  String videosFound(int count) {
    return '$count videos found';
  }

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get format => 'Format';

  @override
  String get selectFolder => 'Select folder';

  @override
  String downloadCount(int count) {
    return 'Download $count';
  }

  @override
  String get queueTitle => 'Queue';

  @override
  String get clearCompleted => 'Clear Completed';

  @override
  String get noDownloadsYet => 'No downloads yet';

  @override
  String get noDownloadsSubtitle =>
      'Add a URL on the Download tab to get started.';

  @override
  String get statActive => 'Active';

  @override
  String get statQueued => 'Queued';

  @override
  String get statCompleted => 'Completed';

  @override
  String get statFailed => 'Failed';

  @override
  String get downloadingEllipsis => 'Downloading…';

  @override
  String statBadge(int count, String label) {
    return '$count $label';
  }

  @override
  String get historyTitle => 'History';

  @override
  String get clearAll => 'Clear All';

  @override
  String get cancel => 'Cancel';

  @override
  String get searchHistoryHint => 'Search history…';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get noDownloadHistory => 'No download history';

  @override
  String get tryDifferentSearch => 'Try a different search term.';

  @override
  String get completedDownloadsAppearHere =>
      'Your completed downloads will appear here.';

  @override
  String get clearAllHistory => 'Clear all history?';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get openFolder => 'Open folder';

  @override
  String get openFile => 'Open file';

  @override
  String get deleteFromHistory => 'Delete from history';

  @override
  String get settingsTitle => 'Settings';

  @override
  String errorLoadingSettings(String error) {
    return 'Error loading settings: $error';
  }

  @override
  String get general => 'General';

  @override
  String get startOnStartup => 'Start on system startup';

  @override
  String get startOnStartupSubtitle =>
      'Launch Media Downloader when you log in';

  @override
  String get minimizeToTray => 'Minimize to system tray';

  @override
  String get minimizeToTraySubtitle =>
      'Keep running in the background when window is closed';

  @override
  String get downloads => 'Downloads';

  @override
  String get defaultDownloadLocation => 'Default download location';

  @override
  String get systemDownloadsFolder => 'System Downloads folder';

  @override
  String get selectDefaultDownloadLocation =>
      'Select Default Download Location';

  @override
  String get concurrentDownloads => 'Concurrent downloads';

  @override
  String concurrentDownloadsSubtitle(int count) {
    return '$count simultaneous downloads';
  }

  @override
  String get retryCountLabel => 'Retry count';

  @override
  String retryCountSubtitle(int count) {
    return '$count retries on failure';
  }

  @override
  String get openFileAfterDownload => 'Open file after download';

  @override
  String get openFileAfterDownloadSubtitle =>
      'Automatically open completed files';

  @override
  String get openFolderAfterDownload => 'Open folder after download';

  @override
  String get openFolderAfterDownloadSubtitle =>
      'Reveal completed file in its folder';

  @override
  String get autoUpdateYtDlp => 'Auto-update yt-dlp';

  @override
  String get autoUpdateYtDlpSubtitle =>
      'Download the latest version on startup';

  @override
  String get embedMetadataByDefault => 'Embed metadata by default';

  @override
  String get embedMetadataByDefaultSubtitle =>
      'Add title, artist, and other tags to files';

  @override
  String get useDownloadArchive => 'Use download archive';

  @override
  String get useDownloadArchiveSubtitle =>
      'Skip already-downloaded videos in playlists';

  @override
  String get customYtDlpArgs => 'Custom yt-dlp arguments';

  @override
  String get customYtDlpArgsSubtitle =>
      'Extra arguments appended to every download';

  @override
  String get customYtDlpArgsHint => 'e.g. --no-playlist --geo-bypass';

  @override
  String get proxyUrl => 'Proxy URL';

  @override
  String get proxyUrlSubtitle => 'HTTP/HTTPS/SOCKS5 proxy for downloads';

  @override
  String get advanced => 'Advanced';

  @override
  String get debugLogging => 'Debug logging';

  @override
  String get debugLoggingSubtitle =>
      'Write verbose logs to disk for troubleshooting';

  @override
  String get resetAllSettingsQuestion => 'Reset all settings?';

  @override
  String get resetAllSettingsConfirm =>
      'This will restore all settings to their defaults.';

  @override
  String get reset => 'Reset';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get speedLimit => 'Speed limit';

  @override
  String get unlimited => 'Unlimited';

  @override
  String speedLimitValue(int count) {
    return '$count KB/s';
  }

  @override
  String get speedLimitHint => '0 = unlimited';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get resetAllSettingsToDefaults => 'Reset all settings to defaults';

  @override
  String get leadDeveloper => 'Lead Developer & Designer';

  @override
  String get settingUpEngine => 'Setting up your download engine…';

  @override
  String get setupFailed => 'Setup failed.';

  @override
  String get ready => 'Ready!';

  @override
  String get retrySetup => 'Retry Setup';

  @override
  String get splashTagline => 'Your media, anywhere';

  @override
  String get statusWaiting => 'Waiting';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusDownloading => 'Downloading';

  @override
  String get statusConverting => 'Converting';

  @override
  String get statusMerging => 'Merging';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get typeVideo => 'Video';

  @override
  String get typeAudio => 'Audio';

  @override
  String get qualityBest => 'Best Available';

  @override
  String get qualityHigh => 'High (1080p)';

  @override
  String get qualityMedium => 'Medium (720p)';

  @override
  String get qualityLow => 'Low (480p)';

  @override
  String get qualityCustom => 'Custom Format';

  @override
  String get audioBest => 'Best Available';

  @override
  String get audioMp3_320 => 'MP3 320kbps';

  @override
  String get audioMp3_256 => 'MP3 256kbps';

  @override
  String get audioMp3_192 => 'MP3 192kbps';

  @override
  String get audioMp3_128 => 'MP3 128kbps';

  @override
  String get audioOriginal => 'Original Audio';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get retry => 'Retry';

  @override
  String get remove => 'Remove';

  @override
  String get play => 'Play';
}
