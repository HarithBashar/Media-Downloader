import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @navDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get navDownload;

  /// No description provided for @navPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get navPlaylist;

  /// No description provided for @navQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get navQueue;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get homeTitle;

  /// No description provided for @addDownload.
  ///
  /// In en, this message translates to:
  /// **'Add Download'**
  String get addDownload;

  /// No description provided for @addDownloadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste a URL, drag & drop, or let us detect from your clipboard'**
  String get addDownloadSubtitle;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get invalidUrl;

  /// No description provided for @selectDownloadLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Download Location'**
  String get selectDownloadLocation;

  /// No description provided for @downloadAddedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Download added to queue'**
  String get downloadAddedToQueue;

  /// No description provided for @dropUrlHere.
  ///
  /// In en, this message translates to:
  /// **'Drop URL here…'**
  String get dropUrlHere;

  /// No description provided for @pasteUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Paste URL here (YouTube, Vimeo, TikTok, and 1000+ more)'**
  String get pasteUrlHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @pasteFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get pasteFromClipboard;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @saveTo.
  ///
  /// In en, this message translates to:
  /// **'Save to'**
  String get saveTo;

  /// No description provided for @filename.
  ///
  /// In en, this message translates to:
  /// **'Filename'**
  String get filename;

  /// No description provided for @filenameHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use original title'**
  String get filenameHint;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @embedThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Embed Thumbnail'**
  String get embedThumbnail;

  /// No description provided for @embedMetadata.
  ///
  /// In en, this message translates to:
  /// **'Embed Metadata'**
  String get embedMetadata;

  /// No description provided for @subtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get subtitles;

  /// No description provided for @sponsorBlock.
  ///
  /// In en, this message translates to:
  /// **'SponsorBlock'**
  String get sponsorBlock;

  /// No description provided for @subtitleSettings.
  ///
  /// In en, this message translates to:
  /// **'Subtitle Settings'**
  String get subtitleSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @embedInVideo.
  ///
  /// In en, this message translates to:
  /// **'Embed in Video'**
  String get embedInVideo;

  /// No description provided for @noFolderSelected.
  ///
  /// In en, this message translates to:
  /// **'No folder selected'**
  String get noFolderSelected;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @startDownload.
  ///
  /// In en, this message translates to:
  /// **'Start Download'**
  String get startDownload;

  /// No description provided for @playlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Playlist Download'**
  String get playlistTitle;

  /// No description provided for @fetchAndDownloadPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Fetch & Download Playlist'**
  String get fetchAndDownloadPlaylist;

  /// No description provided for @playlistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste a playlist or channel URL to load all videos before downloading.'**
  String get playlistSubtitle;

  /// No description provided for @pastePlaylistUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Paste playlist URL here...'**
  String get pastePlaylistUrlHint;

  /// No description provided for @fetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching...'**
  String get fetching;

  /// No description provided for @fetch.
  ///
  /// In en, this message translates to:
  /// **'Fetch'**
  String get fetch;

  /// No description provided for @selectAtLeastOneVideo.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one video to download.'**
  String get selectAtLeastOneVideo;

  /// No description provided for @selectDownloadFolder.
  ///
  /// In en, this message translates to:
  /// **'Please select a download folder.'**
  String get selectDownloadFolder;

  /// No description provided for @selectDownloadFolderDialog.
  ///
  /// In en, this message translates to:
  /// **'Select Download Folder'**
  String get selectDownloadFolderDialog;

  /// No description provided for @addedVideosToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added {count} videos to queue.'**
  String addedVideosToQueue(int count);

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No videos found in this playlist.'**
  String get noVideosFound;

  /// No description provided for @videosFound.
  ///
  /// In en, this message translates to:
  /// **'{count} videos found'**
  String videosFound(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @selectFolder.
  ///
  /// In en, this message translates to:
  /// **'Select folder'**
  String get selectFolder;

  /// No description provided for @downloadCount.
  ///
  /// In en, this message translates to:
  /// **'Download {count}'**
  String downloadCount(int count);

  /// No description provided for @queueTitle.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queueTitle;

  /// No description provided for @clearCompleted.
  ///
  /// In en, this message translates to:
  /// **'Clear Completed'**
  String get clearCompleted;

  /// No description provided for @noDownloadsYet.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get noDownloadsYet;

  /// No description provided for @noDownloadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a URL on the Download tab to get started.'**
  String get noDownloadsSubtitle;

  /// No description provided for @statActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statActive;

  /// No description provided for @statQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get statQueued;

  /// No description provided for @statCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statCompleted;

  /// No description provided for @statFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statFailed;

  /// No description provided for @downloadingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get downloadingEllipsis;

  /// No description provided for @statBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} {label}'**
  String statBadge(int count, String label);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @searchHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Search history…'**
  String get searchHistoryHint;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noDownloadHistory.
  ///
  /// In en, this message translates to:
  /// **'No download history'**
  String get noDownloadHistory;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term.'**
  String get tryDifferentSearch;

  /// No description provided for @completedDownloadsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your completed downloads will appear here.'**
  String get completedDownloadsAppearHere;

  /// No description provided for @clearAllHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear all history?'**
  String get clearAllHistory;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get openFolder;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get openFile;

  /// No description provided for @deleteFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Delete from history'**
  String get deleteFromHistory;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @errorLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings: {error}'**
  String errorLoadingSettings(String error);

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @startOnStartup.
  ///
  /// In en, this message translates to:
  /// **'Start on system startup'**
  String get startOnStartup;

  /// No description provided for @startOnStartupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Launch Media Downloader when you log in'**
  String get startOnStartupSubtitle;

  /// No description provided for @minimizeToTray.
  ///
  /// In en, this message translates to:
  /// **'Minimize to system tray'**
  String get minimizeToTray;

  /// No description provided for @minimizeToTraySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep running in the background when window is closed'**
  String get minimizeToTraySubtitle;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @defaultDownloadLocation.
  ///
  /// In en, this message translates to:
  /// **'Default download location'**
  String get defaultDownloadLocation;

  /// No description provided for @systemDownloadsFolder.
  ///
  /// In en, this message translates to:
  /// **'System Downloads folder'**
  String get systemDownloadsFolder;

  /// No description provided for @selectDefaultDownloadLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Default Download Location'**
  String get selectDefaultDownloadLocation;

  /// No description provided for @concurrentDownloads.
  ///
  /// In en, this message translates to:
  /// **'Concurrent downloads'**
  String get concurrentDownloads;

  /// No description provided for @concurrentDownloadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} simultaneous downloads'**
  String concurrentDownloadsSubtitle(int count);

  /// No description provided for @retryCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry count'**
  String get retryCountLabel;

  /// No description provided for @retryCountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} retries on failure'**
  String retryCountSubtitle(int count);

  /// No description provided for @openFileAfterDownload.
  ///
  /// In en, this message translates to:
  /// **'Open file after download'**
  String get openFileAfterDownload;

  /// No description provided for @openFileAfterDownloadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically open completed files'**
  String get openFileAfterDownloadSubtitle;

  /// No description provided for @openFolderAfterDownload.
  ///
  /// In en, this message translates to:
  /// **'Open folder after download'**
  String get openFolderAfterDownload;

  /// No description provided for @openFolderAfterDownloadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reveal completed file in its folder'**
  String get openFolderAfterDownloadSubtitle;

  /// No description provided for @autoUpdateYtDlp.
  ///
  /// In en, this message translates to:
  /// **'Auto-update yt-dlp'**
  String get autoUpdateYtDlp;

  /// No description provided for @autoUpdateYtDlpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download the latest version on startup'**
  String get autoUpdateYtDlpSubtitle;

  /// No description provided for @embedMetadataByDefault.
  ///
  /// In en, this message translates to:
  /// **'Embed metadata by default'**
  String get embedMetadataByDefault;

  /// No description provided for @embedMetadataByDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add title, artist, and other tags to files'**
  String get embedMetadataByDefaultSubtitle;

  /// No description provided for @useDownloadArchive.
  ///
  /// In en, this message translates to:
  /// **'Use download archive'**
  String get useDownloadArchive;

  /// No description provided for @useDownloadArchiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Skip already-downloaded videos in playlists'**
  String get useDownloadArchiveSubtitle;

  /// No description provided for @customYtDlpArgs.
  ///
  /// In en, this message translates to:
  /// **'Custom yt-dlp arguments'**
  String get customYtDlpArgs;

  /// No description provided for @customYtDlpArgsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extra arguments appended to every download'**
  String get customYtDlpArgsSubtitle;

  /// No description provided for @customYtDlpArgsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. --no-playlist --geo-bypass'**
  String get customYtDlpArgsHint;

  /// No description provided for @proxyUrl.
  ///
  /// In en, this message translates to:
  /// **'Proxy URL'**
  String get proxyUrl;

  /// No description provided for @proxyUrlSubtitle.
  ///
  /// In en, this message translates to:
  /// **'HTTP/HTTPS/SOCKS5 proxy for downloads'**
  String get proxyUrlSubtitle;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @debugLogging.
  ///
  /// In en, this message translates to:
  /// **'Debug logging'**
  String get debugLogging;

  /// No description provided for @debugLoggingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write verbose logs to disk for troubleshooting'**
  String get debugLoggingSubtitle;

  /// No description provided for @resetAllSettingsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings?'**
  String get resetAllSettingsQuestion;

  /// No description provided for @resetAllSettingsConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will restore all settings to their defaults.'**
  String get resetAllSettingsConfirm;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @speedLimit.
  ///
  /// In en, this message translates to:
  /// **'Speed limit'**
  String get speedLimit;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @speedLimitValue.
  ///
  /// In en, this message translates to:
  /// **'{count} KB/s'**
  String speedLimitValue(int count);

  /// No description provided for @speedLimitHint.
  ///
  /// In en, this message translates to:
  /// **'0 = unlimited'**
  String get speedLimitHint;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @resetAllSettingsToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset all settings to defaults'**
  String get resetAllSettingsToDefaults;

  /// No description provided for @leadDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Lead Developer & Designer'**
  String get leadDeveloper;

  /// No description provided for @settingUpEngine.
  ///
  /// In en, this message translates to:
  /// **'Setting up your download engine…'**
  String get settingUpEngine;

  /// No description provided for @setupFailed.
  ///
  /// In en, this message translates to:
  /// **'Setup failed.'**
  String get setupFailed;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready!'**
  String get ready;

  /// No description provided for @retrySetup.
  ///
  /// In en, this message translates to:
  /// **'Retry Setup'**
  String get retrySetup;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your media, anywhere'**
  String get splashTagline;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get statusWaiting;

  /// No description provided for @statusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// No description provided for @statusDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get statusDownloading;

  /// No description provided for @statusConverting.
  ///
  /// In en, this message translates to:
  /// **'Converting'**
  String get statusConverting;

  /// No description provided for @statusMerging.
  ///
  /// In en, this message translates to:
  /// **'Merging'**
  String get statusMerging;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get statusPaused;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @typeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get typeVideo;

  /// No description provided for @typeAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get typeAudio;

  /// No description provided for @qualityBest.
  ///
  /// In en, this message translates to:
  /// **'Best Available'**
  String get qualityBest;

  /// No description provided for @qualityHigh.
  ///
  /// In en, this message translates to:
  /// **'High (1080p)'**
  String get qualityHigh;

  /// No description provided for @qualityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium (720p)'**
  String get qualityMedium;

  /// No description provided for @qualityLow.
  ///
  /// In en, this message translates to:
  /// **'Low (480p)'**
  String get qualityLow;

  /// No description provided for @qualityCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Format'**
  String get qualityCustom;

  /// No description provided for @audioBest.
  ///
  /// In en, this message translates to:
  /// **'Best Available'**
  String get audioBest;

  /// No description provided for @audioMp3_320.
  ///
  /// In en, this message translates to:
  /// **'MP3 320kbps'**
  String get audioMp3_320;

  /// No description provided for @audioMp3_256.
  ///
  /// In en, this message translates to:
  /// **'MP3 256kbps'**
  String get audioMp3_256;

  /// No description provided for @audioMp3_192.
  ///
  /// In en, this message translates to:
  /// **'MP3 192kbps'**
  String get audioMp3_192;

  /// No description provided for @audioMp3_128.
  ///
  /// In en, this message translates to:
  /// **'MP3 128kbps'**
  String get audioMp3_128;

  /// No description provided for @audioOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original Audio'**
  String get audioOriginal;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
