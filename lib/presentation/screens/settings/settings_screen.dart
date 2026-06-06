import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/entities/app_settings.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../widgets/content_scaffold.dart';

/// Full settings screen with General, Downloads, yt-dlp, and Advanced sections.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return ContentScaffold(
      title: 'Settings',
      child: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading settings: $e')),
        data: (settings) => _SettingsContent(settings: settings),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  const _SettingsContent({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(settingsProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── General ──────────────────────────────────────────────────────────
          _SettingsSection(
            title: 'General',
            icon: Icons.tune_rounded,
            children: [
              _ThemeSetting(
                current: settings.themeMode,
                onChanged: (mode) => vm.updateField((s) => s.copyWith(themeMode: mode)),
              ),
              _SwitchSetting(
                label: 'Start on system startup',
                subtitle: 'Launch Media Downloader when you log in',
                icon: Icons.start_rounded,
                value: settings.startOnStartup,
                onChanged: (v) => vm.updateField((s) => s.copyWith(startOnStartup: v)),
              ),
              _SwitchSetting(
                label: 'Minimize to system tray',
                subtitle: 'Keep running in the background when window is closed',
                icon: Icons.minimize_rounded,
                value: settings.minimizeToTray,
                onChanged: (v) => vm.updateField((s) => s.copyWith(minimizeToTray: v)),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // ── Downloads ────────────────────────────────────────────────────────
          _SettingsSection(
            title: 'Downloads',
            icon: Icons.download_rounded,
            children: [
              _DirectorySetting(
                label: 'Default download location',
                subtitle: settings.defaultOutputDirectory ?? 'System Downloads folder',
                icon: Icons.folder_outlined,
                onTap: () async {
                  final result = await FilePicker.platform.getDirectoryPath(
                    dialogTitle: 'Select Default Download Location',
                  );
                  if (result != null) {
                    vm.updateField((s) => s.copyWith(defaultOutputDirectory: result));
                  }
                },
              ),
              _SliderSetting(
                label: 'Concurrent downloads',
                subtitle: '${settings.maxConcurrentDownloads} simultaneous downloads',
                icon: Icons.multiple_stop_rounded,
                value: settings.maxConcurrentDownloads.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (v) =>
                    vm.updateField((s) => s.copyWith(maxConcurrentDownloads: v.round())),
              ),
              _SliderSetting(
                label: 'Retry count',
                subtitle: '${settings.retryCount} retries on failure',
                icon: Icons.replay_rounded,
                value: settings.retryCount.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (v) =>
                    vm.updateField((s) => s.copyWith(retryCount: v.round())),
              ),
              _SpeedLimitSetting(
                current: settings.speedLimitKbps,
                onChanged: (v) => vm.updateField((s) => s.copyWith(speedLimitKbps: v)),
              ),
              _SwitchSetting(
                label: 'Open file after download',
                subtitle: 'Automatically open completed files',
                icon: Icons.open_in_new_rounded,
                value: settings.autoOpenFile,
                onChanged: (v) => vm.updateField((s) => s.copyWith(autoOpenFile: v)),
              ),
              _SwitchSetting(
                label: 'Open folder after download',
                subtitle: 'Reveal completed file in its folder',
                icon: Icons.folder_open_rounded,
                value: settings.autoOpenFolder,
                onChanged: (v) => vm.updateField((s) => s.copyWith(autoOpenFolder: v)),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

          const SizedBox(height: 24),

          // ── yt-dlp ───────────────────────────────────────────────────────────
          _SettingsSection(
            title: 'yt-dlp',
            icon: Icons.terminal_rounded,
            children: [
              _SwitchSetting(
                label: 'Auto-update yt-dlp',
                subtitle: 'Download the latest version on startup',
                icon: Icons.system_update_alt_rounded,
                value: settings.autoUpdateYtDlp,
                onChanged: (v) => vm.updateField((s) => s.copyWith(autoUpdateYtDlp: v)),
              ),
              _SwitchSetting(
                label: 'Embed metadata by default',
                subtitle: 'Add title, artist, and other tags to files',
                icon: Icons.info_outline_rounded,
                value: settings.embedMetadataDefault,
                onChanged: (v) => vm.updateField((s) => s.copyWith(embedMetadataDefault: v)),
              ),
              _SwitchSetting(
                label: 'Use download archive',
                subtitle: 'Skip already-downloaded videos in playlists',
                icon: Icons.archive_outlined,
                value: settings.useDownloadArchive,
                onChanged: (v) => vm.updateField((s) => s.copyWith(useDownloadArchive: v)),
              ),
              _TextFieldSetting(
                label: 'Custom yt-dlp arguments',
                subtitle: 'Extra arguments appended to every download',
                icon: Icons.code_rounded,
                value: settings.customYtDlpArgs,
                hint: 'e.g. --no-playlist --geo-bypass',
                onChanged: (v) => vm.updateField((s) => s.copyWith(customYtDlpArgs: v)),
              ),
              _TextFieldSetting(
                label: 'Proxy URL',
                subtitle: 'HTTP/HTTPS/SOCKS5 proxy for downloads',
                icon: Icons.vpn_lock_rounded,
                value: settings.proxyUrl,
                hint: 'socks5://127.0.0.1:1080',
                onChanged: (v) => vm.updateField((s) => s.copyWith(proxyUrl: v)),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

          const SizedBox(height: 24),

          // ── Advanced ─────────────────────────────────────────────────────────
          _SettingsSection(
            title: 'Advanced',
            icon: Icons.settings_rounded,
            children: [
              _SwitchSetting(
                label: 'Debug logging',
                subtitle: 'Write verbose logs to disk for troubleshooting',
                icon: Icons.bug_report_outlined,
                value: settings.debugLogging,
                onChanged: (v) => vm.updateField((s) => s.copyWith(debugLogging: v)),
              ),
              _DangerZone(
                onReset: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset all settings?'),
                      content: const Text('This will restore all settings to their defaults.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(settingsProvider.notifier).resetToDefaults();
                  }
                },
              ),
            ].animate().fadeIn(delay: 300.ms, duration: 300.ms),
          ),
          
          const SizedBox(height: 32),

          // ── About Developer ────────────────────────────────────────────────────
          const _AboutDeveloperSection().animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(begin: 0.05),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Section container ────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: children.expand((w) sync* {
              yield w;
              if (w != children.last) {
                yield const Divider(height: 1, indent: 16, endIndent: 16);
              }
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Setting row types ────────────────────────────────────────────────────────

class _SwitchSetting extends StatelessWidget {
  const _SwitchSetting({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Switch(value: value, onChanged: onChanged, activeTrackColor: AppColors.primary),
    );
  }
}

class _ThemeSetting extends StatelessWidget {
  const _ThemeSetting({required this.current, required this.onChanged});
  final AppThemeMode current;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined, size: 20),
      title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(current.label),
      trailing: SegmentedButton<AppThemeMode>(
        segments: AppThemeMode.values.map((m) => ButtonSegment(
          value: m,
          label: Text(m.label, style: const TextStyle(fontSize: 12)),
        )).toList(),
        selected: {current},
        onSelectionChanged: (s) => onChanged(s.first),
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class _DirectorySetting extends StatelessWidget {
  const _DirectorySetting({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}

class _SliderSetting extends StatelessWidget {
  const _SliderSetting({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.round().toString(),
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SpeedLimitSetting extends StatelessWidget {
  const _SpeedLimitSetting({required this.current, required this.onChanged});
  final int current;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.speed_rounded, size: 20),
      title: const Text('Speed limit', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(current == 0 ? 'Unlimited' : '$current KB/s'),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          controller: TextEditingController(text: current == 0 ? '' : current.toString()),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '0 = unlimited',
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            isDense: true,
          ),
          onSubmitted: (v) => onChanged(int.tryParse(v) ?? 0),
        ),
      ),
    );
  }
}

class _TextFieldSetting extends StatefulWidget {
  const _TextFieldSetting({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.hint,
    required this.onChanged,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<_TextFieldSetting> createState() => _TextFieldSettingState();
}

class _TextFieldSettingState extends State<_TextFieldSetting> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(widget.subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            onSubmitted: widget.onChanged,
            decoration: InputDecoration(hintText: widget.hint, isDense: true),
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restore_rounded, size: 18),
            label: const Text('Reset all settings to defaults'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── About Developer ─────────────────────────────────────────────────────────

class _AboutDeveloperSection extends StatefulWidget {
  const _AboutDeveloperSection();

  @override
  State<_AboutDeveloperSection> createState() => _AboutDeveloperSectionState();
}

class _AboutDeveloperSectionState extends State<_AboutDeveloperSection> {
  bool _isHovered = false;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surfaceContainer.withOpacity(_isHovered ? .6 : 1),
              Theme.of(context).colorScheme.surfaceContainer.withOpacity(_isHovered ? .6 : 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: _isHovered 
                ? colorScheme.primary.withOpacity(0.5) 
                : colorScheme.outlineVariant.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network('https://avatars.githubusercontent.com/u/25960528?v=4')
                  )
                ).animate(target: _isHovered ? 1 : 0).scaleXY(end: 1.05, duration: 200.ms),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harith Bashar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lead Developer & Designer',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SocialButton(
                  icon: Icons.code_rounded,
                  label: 'GitHub',
                  url: 'https://github.com/HarithBashar',
                  onTap: () => _launchUrl('https://github.com/HarithBashar'),
                ),
                _SocialButton(
                  icon: Icons.work_outline_rounded,
                  label: 'LinkedIn',
                  url: 'https://www.linkedin.com/in/harithbashar/',
                  onTap: () => _launchUrl('https://www.linkedin.com/in/harithbashar/'),
                ),
                _SocialButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  url: 'https://www.instagram.com/harith.bashar/',
                  onTap: () => _launchUrl('https://www.instagram.com/harith.bashar/'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatefulWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.url,
    required this.onTap,
  });
  
  final IconData icon;
  final String label;
  final String url;
  final VoidCallback onTap;

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? colorScheme.primary : colorScheme.outlineVariant,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: _isHovered ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isHovered ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ).animate(target: _isHovered ? 1 : 0).moveY(end: -2, duration: 150.ms),
    );
  }
}
