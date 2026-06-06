import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/size_formatter.dart';
import '../../../domain/entities/download_enums.dart';
import '../../../domain/entities/history_item.dart';
import '../../viewmodels/history_viewmodel.dart';
import '../../widgets/content_scaffold.dart';
import '../../widgets/empty_state.dart';

/// Download history screen with search and management features.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);


    return ContentScaffold(
      title: 'History',
      actions: [
        if (historyState.items.isNotEmpty)
          TextButton.icon(
            onPressed: () => _confirmClearAll(context, ref),
            icon: const Icon(Icons.delete_sweep_rounded, size: 18),
            label: const Text('Clear All'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
      ],
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (q) => ref.read(historyProvider.notifier).search(q),
              decoration: InputDecoration(
                hintText: 'Search history…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(historyProvider.notifier).search('');
                        },
                      )
                    : null,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 8),

          // List
          Expanded(
            child: historyState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : historyState.filteredItems.isEmpty
                    ? EmptyState(
                        icon: Icons.history_rounded,
                        title: historyState.searchQuery.isNotEmpty
                            ? 'No results found'
                            : 'No download history',
                        subtitle: historyState.searchQuery.isNotEmpty
                            ? 'Try a different search term.'
                            : 'Your completed downloads will appear here.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: historyState.filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = historyState.filteredItems[index];
                          return _HistoryCard(
                            key: ValueKey(item.id),
                            item: item,
                            onDelete: () =>
                                ref.read(historyProvider.notifier).deleteItem(item.id),
                          ).animate(delay: (index * 30).ms).fadeIn(duration: 250.ms);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirm == true) ref.read(historyProvider.notifier).clearAll();
  }
}

class _HistoryCard extends StatefulWidget {
  const _HistoryCard({super.key, required this.item, required this.onDelete});
  final HistoryItem item;
  final VoidCallback onDelete;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _hovering = false;
  static final _dateFormat = DateFormat('MMM d, yyyy • h:mm a');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _hovering ? colorScheme.surfaceContainerHigh : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (item.type == DownloadType.video ? AppColors.primary : AppColors.secondary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.type == DownloadType.video
                      ? Icons.videocam_rounded
                      : Icons.music_note_rounded,
                  color: item.type == DownloadType.video ? AppColors.primary : AppColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.websiteName != null) ...[
                          Text(
                            item.websiteName!,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('•', style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          )),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _dateFormat.format(item.downloadedAt),
                          style: textTheme.bodySmall,
                        ),
                        if (item.fileSizeBytes != null) ...[
                          const SizedBox(width: 8),
                          Text('•', style: textTheme.bodySmall),
                          const SizedBox(width: 8),
                          Text(
                            SizeFormatter.format(item.fileSizeBytes),
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              AnimatedOpacity(
                opacity: _hovering ? 1.0 : 0.0,
                duration: AppConstants.shortAnimation,
                child: Row(
                  children: [
                    _ActionIconButton(
                      icon: Icons.folder_open_rounded,
                      tooltip: 'Open folder',
                      onPressed: () => _openFolder(item.outputPath),
                    ),
                    _ActionIconButton(
                      icon: Icons.open_in_new_rounded,
                      tooltip: 'Open file',
                      onPressed: () => _openFile(item.outputPath),
                    ),
                    _ActionIconButton(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Delete from history',
                      color: AppColors.error,
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFolder(String path) async {
    final dir = File(path).parent;
    final uri = Uri.file(dir.path);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openFile(String path) async {
    final uri = Uri.file(path);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        style: IconButton.styleFrom(
          minimumSize: const Size(36, 36),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
