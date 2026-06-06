import '../entities/history_item.dart';

/// Abstract repository contract for download history.
abstract interface class HistoryRepository {
  /// Returns all history items, newest first.
  Future<List<HistoryItem>> getAllHistory();

  /// Saves a completed download to history.
  Future<void> saveHistoryItem(HistoryItem item);

  /// Deletes a single history entry by [id].
  Future<void> deleteHistoryItem(String id);

  /// Deletes all history entries.
  Future<void> clearHistory();

  /// Searches history by title or URL.
  Future<List<HistoryItem>> searchHistory(String query);
}
