import 'download_enums.dart';

/// Represents the configuration and state of a single download task.
///
/// Immutable value object — all state changes produce a new instance via [copyWith].
class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.url,
    required this.outputDirectory,
    required this.type,
    required this.videoQuality,
    required this.audioQuality,
    required this.status,
    required this.createdAt,
    this.title,
    this.thumbnailUrl,
    this.websiteName,
    this.outputPath,
    this.errorMessage,
    this.customArgs,
    this.subtitleLanguage,
    this.embedSubtitles = false,
    this.embedThumbnail = false,
    this.embedMetadata = false,
    this.downloadSubtitles = false,
    this.downloadThumbnail = false,
    this.sponsorBlock = false,
    this.priority = 0,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.progress,
  });

  /// Unique identifier for this download task.
  final String id;

  /// Source URL to download from.
  final String url;

  /// Directory where the file will be saved.
  final String outputDirectory;

  /// Whether this is a video or audio download.
  final DownloadType type;

  /// Selected video quality preset (video downloads only).
  final VideoQuality videoQuality;

  /// Selected audio quality preset (audio downloads only).
  final AudioQuality audioQuality;

  /// Current lifecycle state.
  final DownloadStatus status;

  /// When this download task was created.
  final DateTime createdAt;

  /// Media title, populated after metadata is fetched.
  final String? title;

  /// Thumbnail URL for display, populated after metadata is fetched.
  final String? thumbnailUrl;

  /// Name of the source website.
  final String? websiteName;

  /// Full path to the completed output file.
  final String? outputPath;

  /// Error message if [status] is [DownloadStatus.failed].
  final String? errorMessage;

  /// Optional user-supplied extra yt-dlp arguments.
  final String? customArgs;

  /// Subtitle language code (e.g. "en", "ar").
  final String? subtitleLanguage;

  final bool embedSubtitles;
  final bool embedThumbnail;
  final bool embedMetadata;
  final bool downloadSubtitles;
  final bool downloadThumbnail;
  final bool sponsorBlock;

  /// Queue priority (higher = processed first).
  final int priority;

  /// Number of times this download has been retried.
  final int retryCount;

  /// Maximum number of automatic retries.
  final int maxRetries;

  /// Live download progress snapshot.
  final DownloadProgress? progress;

  DownloadItem copyWith({
    String? id,
    String? url,
    String? outputDirectory,
    DownloadType? type,
    VideoQuality? videoQuality,
    AudioQuality? audioQuality,
    DownloadStatus? status,
    DateTime? createdAt,
    String? title,
    String? thumbnailUrl,
    String? websiteName,
    String? outputPath,
    String? errorMessage,
    String? customArgs,
    String? subtitleLanguage,
    bool? embedSubtitles,
    bool? embedThumbnail,
    bool? embedMetadata,
    bool? downloadSubtitles,
    bool? downloadThumbnail,
    bool? sponsorBlock,
    int? priority,
    int? retryCount,
    int? maxRetries,
    DownloadProgress? progress,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      url: url ?? this.url,
      outputDirectory: outputDirectory ?? this.outputDirectory,
      type: type ?? this.type,
      videoQuality: videoQuality ?? this.videoQuality,
      audioQuality: audioQuality ?? this.audioQuality,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      websiteName: websiteName ?? this.websiteName,
      outputPath: outputPath ?? this.outputPath,
      errorMessage: errorMessage ?? this.errorMessage,
      customArgs: customArgs ?? this.customArgs,
      subtitleLanguage: subtitleLanguage ?? this.subtitleLanguage,
      embedSubtitles: embedSubtitles ?? this.embedSubtitles,
      embedThumbnail: embedThumbnail ?? this.embedThumbnail,
      embedMetadata: embedMetadata ?? this.embedMetadata,
      downloadSubtitles: downloadSubtitles ?? this.downloadSubtitles,
      downloadThumbnail: downloadThumbnail ?? this.downloadThumbnail,
      sponsorBlock: sponsorBlock ?? this.sponsorBlock,
      priority: priority ?? this.priority,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      progress: progress ?? this.progress,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DownloadItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A snapshot of download progress for a single item.
class DownloadProgress {
  const DownloadProgress({
    this.percentage,
    this.downloadedBytes,
    this.totalBytes,
    this.speed,
    this.eta,
    this.filename,
  });

  /// Progress percentage 0.0–100.0.
  final double? percentage;

  /// Bytes downloaded so far.
  final int? downloadedBytes;

  /// Total file size in bytes.
  final int? totalBytes;

  /// Current download speed in bytes/second.
  final double? speed;

  /// Estimated time of completion.
  final Duration? eta;

  /// Output filename being written.
  final String? filename;

  DownloadProgress copyWith({
    double? percentage,
    int? downloadedBytes,
    int? totalBytes,
    double? speed,
    Duration? eta,
    String? filename,
  }) {
    return DownloadProgress(
      percentage: percentage ?? this.percentage,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      speed: speed ?? this.speed,
      eta: eta ?? this.eta,
      filename: filename ?? this.filename,
    );
  }
}
