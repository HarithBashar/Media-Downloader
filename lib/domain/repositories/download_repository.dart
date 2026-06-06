import '../entities/download_item.dart';

/// Abstract repository contract for download operations.
///
/// Implementations live in the data layer; the domain depends only on this interface.
abstract interface class DownloadRepository {
  /// Starts a new download. Returns a stream of progress updates.
  Stream<DownloadItem> startDownload(DownloadItem item);

  /// Pauses an active download by its [id].
  Future<void> pauseDownload(String id);

  /// Resumes a paused download by its [id].
  Future<void> resumeDownload(String id);

  /// Cancels and terminates a download by its [id].
  Future<void> cancelDownload(String id);

  /// Retries a failed or cancelled download.
  Future<void> retryDownload(String id);

  /// Returns the current state of all downloads.
  List<DownloadItem> getActiveDownloads();
}
