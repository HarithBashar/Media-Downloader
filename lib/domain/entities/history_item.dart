import 'download_enums.dart';

/// A completed download record stored in the history database.
class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.url,
    required this.title,
    required this.outputPath,
    required this.downloadedAt,
    required this.type,
    this.thumbnailUrl,
    this.websiteName,
    this.fileSizeBytes,
  });

  final String id;
  final String url;
  final String title;
  final String outputPath;
  final DateTime downloadedAt;
  final DownloadType type;
  final String? thumbnailUrl;
  final String? websiteName;
  final int? fileSizeBytes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'title': title,
        'outputPath': outputPath,
        'downloadedAt': downloadedAt.toIso8601String(),
        'type': type.name,
        'thumbnailUrl': thumbnailUrl,
        'websiteName': websiteName,
        'fileSizeBytes': fileSizeBytes,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'] as String,
        url: json['url'] as String,
        title: json['title'] as String,
        outputPath: json['outputPath'] as String,
        downloadedAt: DateTime.parse(json['downloadedAt'] as String),
        type: DownloadType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => DownloadType.video,
        ),
        thumbnailUrl: json['thumbnailUrl'] as String?,
        websiteName: json['websiteName'] as String?,
        fileSizeBytes: json['fileSizeBytes'] as int?,
      );
}
