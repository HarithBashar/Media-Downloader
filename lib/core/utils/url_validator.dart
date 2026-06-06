/// URL validation utilities.
library;

/// Validates and classifies URLs for yt-dlp compatibility.
class UrlValidator {
  UrlValidator._();

  /// Supported domain patterns (non-exhaustive — yt-dlp supports 1000+ sites).
  static const List<String> _knownDomains = [
    'youtube.com',
    'youtu.be',
    'vimeo.com',
    'dailymotion.com',
    'twitch.tv',
    'tiktok.com',
    'twitter.com',
    'x.com',
    'instagram.com',
    'facebook.com',
    'fb.watch',
    'reddit.com',
    'soundcloud.com',
    'bandcamp.com',
    'bilibili.com',
    'nicovideo.jp',
    'rumble.com',
    'odysee.com',
    'peertube',
    'streamable.com',
    'imgur.com',
  ];

  /// Returns `true` if [url] is a valid HTTP/HTTPS URL.
  static bool isValidUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    try {
      final uri = Uri.parse(trimmed);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Returns `true` if the URL appears to point to a YouTube playlist.
  static bool isPlaylist(String url) {
    return url.contains('list=') || url.contains('/playlist');
  }

  /// Returns `true` if the URL appears to point to a YouTube channel.
  static bool isChannel(String url) {
    return url.contains('/channel/') ||
        url.contains('/c/') ||
        url.contains('/user/') ||
        url.contains('/@');
  }

  /// Returns `true` if the URL is from a known supported domain.
  static bool isKnownDomain(String url) {
    final lower = url.toLowerCase();
    return _knownDomains.any((d) => lower.contains(d));
  }

  /// Sanitises and normalises a URL string.
  static String sanitise(String url) => url.trim().replaceAll('\n', '').replaceAll('\r', '');

  /// Extracts video ID from a YouTube URL (if possible).
  static String? extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
    return uri.queryParameters['v'];
  }
}
