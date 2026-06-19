import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../viewmodels/download_queue_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Navigation item model.
class _NavItem {
  const _NavItem({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

const _navItems = [
  _NavItem(
    route: AppRoutes.home,
    icon: Icons.download_outlined,
    selectedIcon: Icons.download_rounded,
    label: 'Download',
  ),
  _NavItem(
    route: AppRoutes.playlist,
    icon: Icons.playlist_play_outlined,
    selectedIcon: Icons.playlist_play_rounded,
    label: 'Playlist',
  ),
  _NavItem(
    route: AppRoutes.queue,
    icon: Icons.list_alt_outlined,
    selectedIcon: Icons.list_alt_rounded,
    label: 'Queue',
  ),
  _NavItem(
    route: AppRoutes.history,
    icon: Icons.history_outlined,
    selectedIcon: Icons.history_rounded,
    label: 'History',
  ),
  _NavItem(
    route: AppRoutes.settings,
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];

/// Vertical sidebar navigation for the desktop layout.
class SidebarNav extends ConsumerWidget {
  const SidebarNav({super.key, required this.currentRoute});
  final String currentRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final queue = ref.watch(downloadQueueProvider);
    final activeCount = queue.where((e) => e.item.status.isActive).length;

    final colors = isDark ? AppColors.dark : AppColors.light;

    return Container(
      width: AppConstants.sidebarWidth,
      decoration: BoxDecoration(
        color: colors.sidebarBackground,
        border: Border(right: BorderSide(color: colors.sidebarBorder)),
      ),
      child: Column(
        children: [
          // App logo / name
          _SidebarHeader(),
          const SizedBox(height: 8),

          // Nav items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: _navItems.map((item) {
                  final isSelected = currentRoute == item.route ||
                      (item.route == AppRoutes.home && currentRoute == '/');
                  final badge = item.route == AppRoutes.queue && activeCount > 0
                      ? activeCount
                      : null;
                  return _NavTile(
                    item: item,
                    isSelected: isSelected,
                    badge: badge,
                    onTap: () => context.go(item.route),
                  );
                }).toList(),
              ),
            ),
          ),

          // Version footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'v${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Media',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Downloader',
                  style: textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : _hovering
                    ? colorScheme.surfaceContainerHigh
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // Left accent bar
              AnimatedContainer(
                duration: AppConstants.shortAnimation,
                width: 3,
                height: 20,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Icon(
                isSelected ? widget.item.selectedIcon : widget.item.icon,
                size: 20,
                color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.primary : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),

              // Badge
              if (widget.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
