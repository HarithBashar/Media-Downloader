import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';

/// State for the history screen.
class HistoryState {
  const HistoryState({
    this.items = const [],
    this.filteredItems = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  final List<HistoryItem> items;
  final List<HistoryItem> filteredItems;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  HistoryState copyWith({
    List<HistoryItem>? items,
    List<HistoryItem>? filteredItems,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// ViewModel for the download history screen.
class HistoryViewModel extends Notifier<HistoryState> {
  late HistoryRepository _repo;

  @override
  HistoryState build() {
    _repo = getIt<HistoryRepository>();
    // Load history on first build
    Future.microtask(loadHistory);
    return const HistoryState(isLoading: true);
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repo.getAllHistory();
      state = state.copyWith(
        items: items,
        filteredItems: _applyFilter(items, state.searchQuery),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredItems: _applyFilter(state.items, query),
    );
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repo.deleteHistoryItem(id);
      final updated = state.items.where((i) => i.id != id).toList();
      state = state.copyWith(
        items: updated,
        filteredItems: _applyFilter(updated, state.searchQuery),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearAll() async {
    try {
      await _repo.clearHistory();
      state = state.copyWith(items: [], filteredItems: []);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<HistoryItem> _applyFilter(List<HistoryItem> items, String query) {
    if (query.trim().isEmpty) return items;
    final lower = query.toLowerCase();
    return items.where((i) =>
      i.title.toLowerCase().contains(lower) ||
      i.url.toLowerCase().contains(lower)
    ).toList();
  }
}

final historyProvider = NotifierProvider<HistoryViewModel, HistoryState>(
  HistoryViewModel.new,
);
