/// Duration and time formatting utilities.
library;

/// Formats [Duration] objects and ETA strings into human-readable text.
class DurationFormatter {
  DurationFormatter._();

  /// Formats a [Duration] as "HH:MM:SS" or "MM:SS".
  static String format(Duration? duration) {
    if (duration == null) return '—';
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Parses a yt-dlp ETA string like "01:23" or "1:23:45" into [Duration].
  static Duration? parseEta(String? eta) {
    if (eta == null || eta == 'N/A' || eta.isEmpty) return null;
    final parts = eta.split(':').map(int.tryParse).toList();
    if (parts.any((p) => p == null)) return null;
    if (parts.length == 3) {
      return Duration(hours: parts[0]!, minutes: parts[1]!, seconds: parts[2]!);
    } else if (parts.length == 2) {
      return Duration(minutes: parts[0]!, seconds: parts[1]!);
    }
    return null;
  }

  /// Returns a short human-readable ETA string like "2m 30s remaining".
  static String formatEta(Duration? eta) {
    if (eta == null) return '—';
    if (eta.inSeconds < 60) return '${eta.inSeconds}s remaining';
    if (eta.inMinutes < 60) {
      final m = eta.inMinutes;
      final s = eta.inSeconds.remainder(60);
      return '${m}m ${s}s remaining';
    }
    final h = eta.inHours;
    final m = eta.inMinutes.remainder(60);
    return '${h}h ${m}m remaining';
  }
}
