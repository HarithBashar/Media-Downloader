import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/local/history_local_datasource.dart';

/// Concrete [HistoryRepository] backed by a local JSON file.
class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({required HistoryLocalDatasource datasource})
      : _datasource = datasource;

  final HistoryLocalDatasource _datasource;

  @override
  Future<List<HistoryItem>> getAllHistory() => _datasource.loadAll();

  @override
  Future<void> saveHistoryItem(HistoryItem item) => _datasource.save(item);

  @override
  Future<void> deleteHistoryItem(String id) => _datasource.deleteById(id);

  @override
  Future<void> clearHistory() => _datasource.clear();

  @override
  Future<List<HistoryItem>> searchHistory(String query) async {
    final all = await _datasource.loadAll();
    if (query.trim().isEmpty) return all;
    final lower = query.toLowerCase();
    return all.where((i) =>
      i.title.toLowerCase().contains(lower) ||
      i.url.toLowerCase().contains(lower) ||
      (i.websiteName?.toLowerCase().contains(lower) ?? false)
    ).toList();
  }
}
