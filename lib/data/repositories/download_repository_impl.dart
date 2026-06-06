import '../../domain/entities/download_enums.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/process/ytdlp_process_datasource.dart';

/// Concrete implementation of [DownloadRepository] using [YtDlpProcessDatasource].
class DownloadRepositoryImpl implements DownloadRepository {
  DownloadRepositoryImpl({required YtDlpProcessDatasource datasource})
      : _datasource = datasource;

  final YtDlpProcessDatasource _datasource;
  final Map<String, DownloadItem> _activeItems = {};

  @override
  Stream<DownloadItem> startDownload(DownloadItem item) {
    _activeItems[item.id] = item;
    return _datasource.download(item).map((updated) {
      _activeItems[item.id] = updated;
      if (updated.status.isTerminal) _activeItems.remove(item.id);
      return updated;
    });
  }

  @override
  Future<void> pauseDownload(String id) => _datasource.pause(id);

  @override
  Future<void> resumeDownload(String id) => _datasource.resume(id);

  @override
  Future<void> cancelDownload(String id) async {
    await _datasource.cancel(id);
    _activeItems.remove(id);
  }

  @override
  Future<void> retryDownload(String id) async {
    final item = _activeItems[id];
    if (item == null) return;
    await startDownload(item.copyWith(
      status: DownloadStatus.waiting,
      retryCount: item.retryCount + 1,
      errorMessage: null,
      progress: null,
    )).drain<void>();
  }

  @override
  List<DownloadItem> getActiveDownloads() => List.unmodifiable(_activeItems.values);
}
