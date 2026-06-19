/// Represents a single video entry in a playlist, as returned by yt-dlp metadata.
///
/// Used for previewing playlist contents before downloading.
class PlaylistVideoInfo {
  const PlaylistVideoInfo({
    required this.id,
    required this.url,
    required this.title,
    this.thumbnailUrl,
    this.durationSeconds,
    this.uploader,
    this.index,
  });

  /// Unique video ID (from the source platform).
  final String id;

  /// Direct URL to the video.
  final String url;

  /// Video title.
  final String title;

  /// Thumbnail image URL.
  final String? thumbnailUrl;

  /// Duration in seconds.
  final int? durationSeconds;

  /// Channel / uploader name.
  final String? uploader;

  /// 1-based position in the playlist.
  final int? index;

  /// Formats [durationSeconds] as "mm:ss" or "h:mm:ss".
  String get formattedDuration {
    if (durationSeconds == null) return '--:--';
    final d = Duration(seconds: durationSeconds!);
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Creates from a yt-dlp JSON object (one line of --dump-json output).
  factory PlaylistVideoInfo.fromJson(Map<String, dynamic> json) {
    // yt-dlp uses 'webpage_url' for the full URL; 'url' can be a direct stream URL
    final url = (json['webpage_url'] as String?) ??
        (json['url'] as String?) ??
        'https://www.youtube.com/watch?v=${json['id']}';

    // Thumbnail: yt-dlp may provide 'thumbnail' or 'thumbnails' array
    String? thumbnail = json['thumbnail'] as String?;
    if (thumbnail == null) {
      final thumbnails = json['thumbnails'] as List?;
      if (thumbnails != null && thumbnails.isNotEmpty) {
        thumbnail = thumbnails.last['url'] as String?;
      }
    }

    return PlaylistVideoInfo(
      id: json['id'] as String? ?? '',
      url: url,
      title: json['title'] as String? ?? 'Unknown',
      thumbnailUrl: thumbnail,
      durationSeconds: (json['duration'] as num?)?.toInt(),
      uploader: json['uploader'] as String? ?? json['channel'] as String?,
      index: (json['playlist_index'] as num?)?.toInt(),
    );
  }
}
