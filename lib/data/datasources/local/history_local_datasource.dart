import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/history_item.dart';

/// Local JSON-file based datasource for download history.
class HistoryLocalDatasource {
  HistoryLocalDatasource();

  File? _cacheFile;

  Future<File> _getFile() async {
    if (_cacheFile != null) return _cacheFile!;
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'data'));
    if (!await dir.exists()) await dir.create(recursive: true);
    _cacheFile = File(p.join(dir.path, 'history.json'));
    return _cacheFile!;
  }

  Future<List<HistoryItem>> loadAll() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];
      final List<dynamic> jsonList = json.decode(content) as List<dynamic>;
      return jsonList
          .map((e) => HistoryItem.fromJson(e as Map<String, dynamic>))
          .toList()
          ..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    } catch (e) {
      throw StorageException('Failed to load history.', cause: e);
    }
  }

  Future<void> save(HistoryItem item) async {
    try {
      final all = await loadAll();
      // Keep max items
      final updated = [item, ...all.where((i) => i.id != item.id)]
          .take(AppConstants.maxHistoryItems)
          .toList();
      await _writeAll(updated);
    } catch (e) {
      throw StorageException('Failed to save history item.', cause: e);
    }
  }

  Future<void> deleteById(String id) async {
    try {
      final all = await loadAll();
      final filtered = all.where((i) => i.id != id).toList();
      await _writeAll(filtered);
    } catch (e) {
      throw StorageException('Failed to delete history item.', cause: e);
    }
  }

  Future<void> clear() async {
    try {
      final file = await _getFile();
      await file.writeAsString('[]');
    } catch (e) {
      throw StorageException('Failed to clear history.', cause: e);
    }
  }

  Future<void> _writeAll(List<HistoryItem> items) async {
    final file = await _getFile();
    final json = jsonEncode(items.map((i) => i.toJson()).toList());
    await file.writeAsString(json);
  }
}
