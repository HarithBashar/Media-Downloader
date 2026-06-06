import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/download_enums.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/download_repository.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/entities/history_item.dart';

/// Represents a download entry in the UI queue, combining item + subscription.
class QueueEntry {
  const QueueEntry({
    required this.item,
    this.subscription,
  });
  final DownloadItem item;
  final StreamSubscription<DownloadItem>? subscription;

  QueueEntry copyWith({DownloadItem? item}) => QueueEntry(
        item: item ?? this.item,
        subscription: subscription,
      );
}

/// ViewModel for the download queue.
///
/// Manages the list of active and queued downloads, enforces concurrent
/// download limits, and persists completed items to history.
class DownloadQueueViewModel extends Notifier<List<QueueEntry>> {
  static const _uuid = Uuid();

  late DownloadRepository _downloadRepo;
  late HistoryRepository _historyRepo;
  AppSettings _settings = const AppSettings();

  @override
  List<QueueEntry> build() {
    // These may not be registered yet on first launch (before setup completes).
    // They'll be set when the first enqueue() call is made.
    if (getIt.isRegistered<DownloadRepository>()) {
      _downloadRepo = getIt<DownloadRepository>();
    }
    if (getIt.isRegistered<HistoryRepository>()) {
      _historyRepo = getIt<HistoryRepository>();
    }
    return [];
  }

  /// Ensures repositories are resolved (called before any queue operation).
  void _ensureRepos() {
    _downloadRepo = getIt<DownloadRepository>();
    _historyRepo = getIt<HistoryRepository>();
  }

  void updateSettings(AppSettings settings) {
    _settings = settings;
  }

  // ─── Active download count ───────────────────────────────────────────────────
  int get _activeCount => state
      .where((e) => e.item.status.isActive)
      .length;

  // ─── Enqueue ──────────────────────────────────────────────────────────────────

  /// Adds a new download to the queue and starts it if capacity allows.
  void enqueue({
    required String url,
    required DownloadType type,
    required VideoQuality videoQuality,
    required AudioQuality audioQuality,
    required String outputDirectory,
    String? customArgs,
    String? subtitleLanguage,
    bool embedSubtitles = false,
    bool embedThumbnail = false,
    bool embedMetadata = true,
    bool downloadSubtitles = false,
    bool downloadThumbnail = false,
    bool sponsorBlock = false,
  }) {
    _ensureRepos();
    final item = DownloadItem(
      id: _uuid.v4(),
      url: url,
      outputDirectory: outputDirectory,
      type: type,
      videoQuality: videoQuality,
      audioQuality: audioQuality,
      status: DownloadStatus.waiting,
      createdAt: DateTime.now(),
      customArgs: customArgs,
      subtitleLanguage: subtitleLanguage,
      embedSubtitles: embedSubtitles,
      embedThumbnail: embedThumbnail,
      embedMetadata: embedMetadata,
      downloadSubtitles: downloadSubtitles,
      downloadThumbnail: downloadThumbnail,
      sponsorBlock: sponsorBlock,
      maxRetries: _settings.retryCount,
    );

    final entry = QueueEntry(item: item);
    state = [...state, entry];

    if (_activeCount < _settings.maxConcurrentDownloads) {
      _startEntry(entry);
    }
  }

  // ─── Control actions ─────────────────────────────────────────────────────────

  void pause(String id) {
    _downloadRepo.pauseDownload(id);
    _updateItemStatus(id, DownloadStatus.paused);
  }

  void resume(String id) {
    final entry = _findEntry(id);
    if (entry == null) return;
    _downloadRepo.resumeDownload(id);
    _updateItemStatus(id, DownloadStatus.downloading);
  }

  void cancel(String id) {
    final entry = _findEntry(id);
    if (entry == null) return;
    entry.subscription?.cancel();
    _downloadRepo.cancelDownload(id);
    _updateItemStatus(id, DownloadStatus.cancelled);
    _processQueue();
  }

  void retry(String id) {
    final entry = _findEntry(id);
    if (entry == null) return;
    final retried = entry.item.copyWith(
      status: DownloadStatus.waiting,
      errorMessage: null,
      progress: null,
      retryCount: entry.item.retryCount + 1,
    );
    _replaceEntry(entry.copyWith(item: retried));
    if (_activeCount < _settings.maxConcurrentDownloads) {
      _startEntry(_findEntry(id)!);
    }
  }

  void remove(String id) {
    final entry = _findEntry(id);
    if (entry != null) {
      entry.subscription?.cancel();
      _downloadRepo.cancelDownload(id);
    }
    state = state.where((e) => e.item.id != id).toList();
    _processQueue();
  }

  void clearCompleted() {
    state = state.where((e) => !e.item.status.isTerminal).toList();
  }

  // ─── Private helpers ─────────────────────────────────────────────────────────

  void _startEntry(QueueEntry entry) {
    final stream = _downloadRepo.startDownload(entry.item);
    final sub = stream.listen(
      (updatedItem) {
        _updateEntry(entry.item.id, updatedItem);
        if (updatedItem.status == DownloadStatus.completed) {
          _saveToHistory(updatedItem);
          _processQueue();
        } else if (updatedItem.status == DownloadStatus.failed) {
          if (updatedItem.retryCount < updatedItem.maxRetries) {
            Future.delayed(const Duration(seconds: 3), () => retry(updatedItem.id));
          } else {
            _processQueue();
          }
        }
      },
      onError: (Object e) {
        _updateItemStatus(entry.item.id, DownloadStatus.failed);
        _processQueue();
      },
    );

    _replaceEntry(QueueEntry(item: entry.item, subscription: sub));
  }

  void _processQueue() {
    if (_activeCount >= _settings.maxConcurrentDownloads) return;
    final waiting = state.where((e) => e.item.status == DownloadStatus.waiting).toList()
      ..sort((a, b) => b.item.priority.compareTo(a.item.priority));
    if (waiting.isEmpty) return;
    _startEntry(waiting.first);
  }

  void _updateEntry(String id, DownloadItem updated) {
    state = state.map((e) => e.item.id == id ? e.copyWith(item: updated) : e).toList();
  }

  void _updateItemStatus(String id, DownloadStatus status) {
    state = state.map((e) {
      if (e.item.id != id) return e;
      return e.copyWith(item: e.item.copyWith(status: status));
    }).toList();
  }

  void _replaceEntry(QueueEntry entry) {
    state = state.map((e) => e.item.id == entry.item.id ? entry : e).toList();
  }

  QueueEntry? _findEntry(String id) {
    try {
      return state.firstWhere((e) => e.item.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToHistory(DownloadItem item) async {
    try {
      final historyItem = HistoryItem(
        id: item.id,
        url: item.url,
        title: item.title ?? item.url,
        outputPath: item.outputPath ?? item.outputDirectory,
        downloadedAt: DateTime.now(),
        type: item.type,
        thumbnailUrl: item.thumbnailUrl,
        websiteName: item.websiteName,
      );
      await _historyRepo.saveHistoryItem(historyItem);
    } catch (_) {
      // History save failure is non-critical
    }
  }
}

/// Provider for the download queue viewmodel.
final downloadQueueProvider = NotifierProvider<DownloadQueueViewModel, List<QueueEntry>>(
  DownloadQueueViewModel.new,
);

/// Provider for the settings that the queue needs access to.
/// Updated by the SettingsViewModel when settings change.
final queueSettingsProvider = StateProvider<AppSettings>((ref) => const AppSettings());
