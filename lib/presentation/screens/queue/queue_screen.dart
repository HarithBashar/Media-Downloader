import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/download_enums.dart';
import '../../viewmodels/download_queue_viewmodel.dart';
import '../../widgets/content_scaffold.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/download_card.dart';

/// Active download queue screen.
///
/// Shows all queued, active, paused, and recently completed downloads
/// with pause/resume/cancel/retry controls and a spinning activity indicator.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(downloadQueueProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final active = queue.where((e) => e.item.status.isActive).length;
    final completed = queue.where((e) => e.item.status == DownloadStatus.completed).length;

    return ContentScaffold(
      title: 'Queue',
      actions: [
        // Spinning download indicator when downloads are active
        if (active > 0) ...[
          const _ActiveDownloadIndicator(),
          const SizedBox(width: 12),
        ],
        if (completed > 0)
          TextButton.icon(
            onPressed: () => ref.read(downloadQueueProvider.notifier).clearCompleted(),
            icon: const Icon(Icons.clear_all_rounded, size: 18),
            label: const Text('Clear Completed'),
          ),
      ],
      child: queue.isEmpty
          ? const EmptyState(
              icon: Icons.download_rounded,
              title: 'No downloads yet',
              subtitle: 'Add a URL on the Download tab to get started.',
            )
          : Column(
              children: [
                // Summary bar
                if (queue.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        _StatBadge(
                          label: 'Active',
                          count: active,
                          color: AppColors.stateDownloading,
                          isActive: active > 0,
                        ),
                        const SizedBox(width: 24),
                        _StatBadge(
                          label: 'Queued',
                          count: queue.where((e) => e.item.status == DownloadStatus.waiting).length,
                          color: AppColors.stateWaiting,
                        ),
                        const SizedBox(width: 24),
                        _StatBadge(
                          label: 'Completed',
                          count: completed,
                          color: AppColors.stateCompleted,
                        ),
                        const SizedBox(width: 24),
                        _StatBadge(
                          label: 'Failed',
                          count: queue.where((e) => e.item.status == DownloadStatus.failed).length,
                          color: AppColors.stateFailed,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms),

                // Download list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: queue.length,
                    itemBuilder: (context, index) {
                      final entry = queue[index];
                      return DownloadCard(
                        key: ValueKey(entry.item.id),
                        item: entry.item,
                        onPause: () => ref.read(downloadQueueProvider.notifier).pause(entry.item.id),
                        onResume: () => ref.read(downloadQueueProvider.notifier).resume(entry.item.id),
                        onCancel: () => ref.read(downloadQueueProvider.notifier).cancel(entry.item.id),
                        onRetry: () => ref.read(downloadQueueProvider.notifier).retry(entry.item.id),
                        onRemove: () => ref.read(downloadQueueProvider.notifier).remove(entry.item.id),
                      ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

/// Animated spinning download icon shown in the top bar when downloads are active.
class _ActiveDownloadIndicator extends StatefulWidget {
  const _ActiveDownloadIndicator();

  @override
  State<_ActiveDownloadIndicator> createState() => _ActiveDownloadIndicatorState();
}

class _ActiveDownloadIndicatorState extends State<_ActiveDownloadIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, child) => Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: child,
            ),
            child: const Icon(
              Icons.sync_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Downloading…',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
    this.isActive = false,
  });
  final String label;
  final int count;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isActive)
          _PulsingDot(color: color)
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const SizedBox(width: 6),
        Text(
          '$count $label',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// A dot that pulses (scales up and down) to indicate activity.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Container(
        width: 8 * _scale.value,
        height: 8 * _scale.value,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.6 + 0.4 * (_scale.value - 0.7) / 0.6),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.3),
              blurRadius: 4 * _scale.value,
            ),
          ],
        ),
      ),
    );
  }
}
