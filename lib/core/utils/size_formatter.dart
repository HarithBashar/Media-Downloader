/// Human-readable file size formatting.
library;

/// Formats byte counts into human-readable strings (KB, MB, GB, TB).
class SizeFormatter {
  SizeFormatter._();

  static const List<String> _units = ['B', 'KB', 'MB', 'GB', 'TB'];

  /// Formats [bytes] into a compact string like "45.2 MB".
  ///
  /// Returns "—" for null values.
  static String format(int? bytes, {int decimals = 1}) {
    if (bytes == null) return '—';
    if (bytes <= 0) return '0 B';

    double size = bytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < _units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(decimals)} ${_units[unitIndex]}';
  }

  /// Formats a speed in bytes/second like "1.5 MB/s".
  static String formatSpeed(double? bytesPerSecond) {
    if (bytesPerSecond == null || bytesPerSecond <= 0) return '—';
    return '${format(bytesPerSecond.round())}/s';
  }

  /// Parses a yt-dlp speed string like "1.50MiB/s" into bytes/second.
  static double? parseYtDlpSpeed(String? speedStr) {
    if (speedStr == null || speedStr == 'N/A' || speedStr.isEmpty) return null;
    final cleaned = speedStr.replaceAll('/s', '').trim();
    return _parseSizeString(cleaned);
  }

  /// Parses a yt-dlp size string like "45.23MiB" into bytes.
  static int? parseYtDlpSize(String? sizeStr) {
    if (sizeStr == null || sizeStr == 'N/A' || sizeStr.isEmpty) return null;
    return _parseSizeString(sizeStr)?.round();
  }

  static double? _parseSizeString(String s) {
    final lower = s.toLowerCase().trim();
    final multipliers = {
      'kib': 1024.0,
      'mib': 1024.0 * 1024,
      'gib': 1024.0 * 1024 * 1024,
      'kb': 1000.0,
      'mb': 1000.0 * 1000,
      'gb': 1000.0 * 1000 * 1000,
      'b': 1.0,
    };

    for (final entry in multipliers.entries) {
      if (lower.endsWith(entry.key)) {
        final num = double.tryParse(lower.replaceAll(entry.key, '').trim());
        if (num != null) return num * entry.value;
      }
    }
    return double.tryParse(lower);
  }
}
