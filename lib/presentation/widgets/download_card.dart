import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../core/utils/size_formatter.dart';
import '../../core/utils/duration_formatter.dart';
import '../../domain/entities/download_enums.dart';
import '../../domain/entities/download_item.dart';

/// Card widget for a single download item in the queue.
///
/// Shows thumbnail, title, website, progress bar, speed, ETA,
/// and action buttons (pause/resume/cancel/retry/remove).
class DownloadCard extends StatefulWidget {
  const DownloadCard({
    super.key,
    required this.item,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onRetry,
    required this.onRemove,
  });

  final DownloadItem item;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  @override
  State<DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends State<DownloadCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = item.progress;
    final statusColor = _statusColor(item.status);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: icon + info + actions ───────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media type icon / thumbnail placeholder
                  _ThumbnailWidget(
                    thumbnailUrl: item.thumbnailUrl,
                    type: item.type,
                  ),
                  const SizedBox(width: 14),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          item.title ?? item.url,
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Website + status
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
                              Text('•', style: textTheme.bodySmall),
                              const SizedBox(width: 8),
                            ],
                            _StatusBadge(status: item.status),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  AnimatedOpacity(
                    opacity: _hovering ? 1.0 : 0.6,
                    duration: AppConstants.shortAnimation,
                    child: _ActionButtons(
                      status: item.status,
                      onPause: widget.onPause,
                      onResume: widget.onResume,
                      onCancel: widget.onCancel,
                      onRetry: widget.onRetry,
                      onRemove: widget.onRemove,
                    ),
                  ),
                ],
              ),

              // ── Progress section ─────────────────────────────────────────────
              if (item.status != DownloadStatus.waiting && item.status != DownloadStatus.cancelled) ...[
                const SizedBox(height: 14),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress?.percentage != null ? progress!.percentage! / 100 : null,
                    minHeight: 5,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),

                const SizedBox(height: 8),

                // Stats row
                Row(
                  children: [
                    if (progress?.percentage != null)
                      _StatChip(
                        icon: Icons.percent_rounded,
                        label: '${progress!.percentage!.toStringAsFixed(1)}%',
                        color: statusColor,
                      ),
                    if (progress?.speed != null) ...[
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.speed_rounded,
                        label: SizeFormatter.formatSpeed(progress!.speed),
                      ),
                    ],
                    if (progress?.eta != null) ...[
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.timer_outlined,
                        label: DurationFormatter.formatEta(progress!.eta),
                      ),
                    ],
                    const Spacer(),
                    if (progress?.downloadedBytes != null && progress?.totalBytes != null)
                      Text(
                        '${SizeFormatter.format(progress!.downloadedBytes)} / ${SizeFormatter.format(progress.totalBytes)}',
                        style: textTheme.bodySmall,
                      ),
                  ],
                ),
              ],

              // ── Error message ─────────────────────────────────────────────────
              if (item.status == DownloadStatus.failed && item.errorMessage != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.errorMessage!,
                          style: textTheme.bodySmall?.copyWith(color: AppColors.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(DownloadStatus status) => switch (status) {
        DownloadStatus.waiting => AppColors.stateWaiting,
        DownloadStatus.preparing => AppColors.statePreparing,
        DownloadStatus.downloading => AppColors.stateDownloading,
        DownloadStatus.converting => AppColors.stateConverting,
        DownloadStatus.merging => AppColors.stateMerging,
        DownloadStatus.completed => AppColors.stateCompleted,
        DownloadStatus.failed => AppColors.stateFailed,
        DownloadStatus.paused => AppColors.statePaused,
        DownloadStatus.cancelled => AppColors.stateCancelled,
      };
}

class _ThumbnailWidget extends StatelessWidget {
  const _ThumbnailWidget({this.thumbnailUrl, required this.type});
  final String? thumbnailUrl;
  final DownloadType type;

  @override
  Widget build(BuildContext context) {
    final color = type == DownloadType.video ? AppColors.primary : AppColors.secondary;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        image: thumbnailUrl != null
            ? DecorationImage(image: NetworkImage(thumbnailUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: thumbnailUrl == null
          ? Icon(
              type == DownloadType.video ? Icons.videocam_rounded : Icons.music_note_rounded,
              color: color,
              size: 28,
            )
          : null,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final DownloadStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusDot(color: color, isAnimated: status.isActive),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color => switch (status) {
        DownloadStatus.waiting => AppColors.stateWaiting,
        DownloadStatus.preparing => AppColors.statePreparing,
        DownloadStatus.downloading => AppColors.stateDownloading,
        DownloadStatus.converting => AppColors.stateConverting,
        DownloadStatus.merging => AppColors.stateMerging,
        DownloadStatus.completed => AppColors.stateCompleted,
        DownloadStatus.failed => AppColors.stateFailed,
        DownloadStatus.paused => AppColors.statePaused,
        DownloadStatus.cancelled => AppColors.stateCancelled,
      };
}

class _StatusDot extends StatefulWidget {
  const _StatusDot({required this.color, required this.isAnimated});
  final Color color;
  final bool isAnimated;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimated) {
      return Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      );
    }
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.5 + _ctrl.value * 0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final c = color ?? colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: c),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.status,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
    required this.onRetry,
    required this.onRemove,
  });
  final DownloadStatus status;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status.canPause)
          _IconBtn(icon: Icons.pause_rounded, tooltip: 'Pause', onPressed: onPause),
        if (status.canResume)
          _IconBtn(icon: Icons.play_arrow_rounded, tooltip: 'Resume', onPressed: onResume),
        if (status.canRetry)
          _IconBtn(icon: Icons.replay_rounded, tooltip: 'Retry', onPressed: onRetry),
        if (status.isActive || status == DownloadStatus.waiting)
          _IconBtn(icon: Icons.close_rounded, tooltip: 'Cancel', onPressed: onCancel),
        _IconBtn(
          icon: Icons.delete_outline_rounded,
          tooltip: 'Remove',
          onPressed: onRemove,
          color: AppColors.error,
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.tooltip, required this.onPressed, this.color});
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
          minimumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
