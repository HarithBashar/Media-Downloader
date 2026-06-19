import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/dependency_injection/injection_container.dart';
import '../../data/datasources/process/ytdlp_process_datasource.dart';
import '../../domain/entities/download_enums.dart';
import '../../domain/entities/playlist_video_info.dart';
import 'download_queue_viewmodel.dart';

/// State for the playlist screen.
class PlaylistState {
  const PlaylistState({
    this.videos = const [],
    this.selectedIds = const {},
    this.isLoading = false,
    this.isFetched = false,
    this.error,
    this.playlistTitle,
  });

  /// All fetched video entries from the playlist.
  final List<PlaylistVideoInfo> videos;

  /// IDs of videos selected for download.
  final Set<String> selectedIds;

  /// Whether a playlist fetch is in progress.
  final bool isLoading;

  /// Whether at least one fetch has completed.
  final bool isFetched;

  /// Error message if the fetch failed.
  final String? error;

  /// Extracted playlist title (if available).
  final String? playlistTitle;

  int get selectedCount => selectedIds.length;
  int get totalCount => videos.length;

  /// Total duration of selected videos.
  Duration get selectedDuration {
    final seconds = videos
        .where((v) => selectedIds.contains(v.id))
        .fold<int>(0, (sum, v) => sum + (v.durationSeconds ?? 0));
    return Duration(seconds: seconds);
  }

  PlaylistState copyWith({
    List<PlaylistVideoInfo>? videos,
    Set<String>? selectedIds,
    bool? isLoading,
    bool? isFetched,
    String? error,
    String? playlistTitle,
  }) {
    return PlaylistState(
      videos: videos ?? this.videos,
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
      isFetched: isFetched ?? this.isFetched,
      error: error ?? this.error,
      playlistTitle: playlistTitle ?? this.playlistTitle,
    );
  }
}

/// ViewModel for the playlist screen.
///
/// Manages fetching playlist metadata, video selection, and
/// enqueuing selected videos for download.
class PlaylistViewModel extends Notifier<PlaylistState> {
  StreamSubscription<PlaylistVideoInfo>? _fetchSubscription;

  @override
  PlaylistState build() => const PlaylistState();

  /// Fetches all videos from the given playlist [url].
  void fetchPlaylist(String url) {
    if (!getIt.isRegistered<YtDlpProcessDatasource>()) return;

    // Cancel any previous fetch
    cancelFetch();

    state = const PlaylistState(isLoading: true);

    final datasource = getIt<YtDlpProcessDatasource>();
    final stream = datasource.fetchPlaylistInfo(url);

    final fetchedVideos = <PlaylistVideoInfo>[];
    final fetchedIds = <String>{};

    _fetchSubscription = stream.listen(
      (video) {
        fetchedVideos.add(video);
        fetchedIds.add(video.id);
        state = state.copyWith(
          videos: List.unmodifiable(fetchedVideos),
          selectedIds: Set.unmodifiable(fetchedIds),
          isLoading: true,
        );
      },
      onError: (Object error) {
        state = state.copyWith(
          isLoading: false,
          isFetched: true,
          error: error.toString(),
        );
      },
      onDone: () {
        state = state.copyWith(
          isLoading: false,
          isFetched: true,
        );
      },
    );
  }

  /// Cancels an in-progress playlist fetch.
  void cancelFetch() {
    _fetchSubscription?.cancel();
    _fetchSubscription = null;
    if (getIt.isRegistered<YtDlpProcessDatasource>()) {
      getIt<YtDlpProcessDatasource>().cancelPlaylistFetch();
    }
  }

  /// Clears the current playlist state.
  void clear() {
    cancelFetch();
    state = const PlaylistState();
  }

  /// Toggles selection of a single video.
  void toggleVideo(String id) {
    final selected = Set<String>.from(state.selectedIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
    state = state.copyWith(selectedIds: selected);
  }

  /// Selects all videos.
  void selectAll() {
    state = state.copyWith(
      selectedIds: state.videos.map((v) => v.id).toSet(),
    );
  }

  /// Deselects all videos.
  void deselectAll() {
    state = state.copyWith(selectedIds: const {});
  }

  /// Enqueues all selected videos for download.
  void downloadSelected({
    required String outputDirectory,
    required DownloadType type,
    required VideoQuality videoQuality,
    required AudioQuality audioQuality,
    bool embedThumbnail = false,
    bool embedMetadata = true,
  }) {
    final queueNotifier = ref.read(downloadQueueProvider.notifier);
    final selectedVideos = state.videos
        .where((v) => state.selectedIds.contains(v.id))
        .toList();

    // Use playlist title or a generic name
    final playlistName = state.playlistTitle ?? 'Playlist';

    for (final video in selectedVideos) {
      queueNotifier.enqueue(
        url: video.url,
        type: type,
        videoQuality: videoQuality,
        audioQuality: audioQuality,
        outputDirectory: outputDirectory,
        playlistName: playlistName,
        title: video.title,
        thumbnailUrl: video.thumbnailUrl,
        embedThumbnail: embedThumbnail,
        embedMetadata: embedMetadata,
      );
    }
  }
}

/// Provider for the playlist viewmodel.
final playlistProvider = NotifierProvider<PlaylistViewModel, PlaylistState>(
  PlaylistViewModel.new,
);
