
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/url_validator.dart';
import '../../../core/utils/file_utils.dart';
import '../../../domain/entities/download_enums.dart';
import '../../viewmodels/playlist_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../widgets/content_scaffold.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  const PlaylistScreen({super.key});

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  final _urlController = TextEditingController();
  final _urlFocusNode = FocusNode();
  bool _isDraggingOver = false;
  String? _urlError;

  DownloadType _downloadType = DownloadType.video;
  VideoQuality _videoQuality = DownloadType.video == DownloadType.video ? VideoQuality.best : VideoQuality.best; // default
  AudioQuality _audioQuality = AudioQuality.best;
  String? _outputDirectory;

  @override
  void initState() {
    super.initState();
    _loadDefaultDirectory();
  }

  Future<void> _loadDefaultDirectory() async {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings != null) {
      setState(() {
        _outputDirectory = settings.defaultOutputDirectory;
      });
    } else {
      final defaultDir = await FileUtils.getDefaultDownloadsDirectory();
      setState(() {
        _outputDirectory = defaultDir.path;
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  void _validateUrl(String value) {
    if (value.isEmpty) {
      setState(() => _urlError = null);
      return;
    }
    setState(() {
      _urlError = UrlValidator.isValidUrl(value) ? null : 'Please enter a valid URL';
    });
  }

  void _fetchPlaylist() {
    final url = _urlController.text.trim();
    if (url.isEmpty || _urlError != null) return;
    
    // Clear old state and fetch new
    ref.read(playlistProvider.notifier).fetchPlaylist(url);
  }

  Future<void> _pickOutputDirectory() async {
    String? path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Download Folder',
      initialDirectory: _outputDirectory,
    );
    if (path != null) {
      setState(() => _outputDirectory = path);
    }
  }

  void _startDownload() {
    final state = ref.read(playlistProvider);
    if (state.selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one video to download.')),
      );
      return;
    }
    if (_outputDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a download folder.')),
      );
      return;
    }

    ref.read(playlistProvider.notifier).downloadSelected(
      outputDirectory: _outputDirectory!,
      type: _downloadType,
      videoQuality: _videoQuality,
      audioQuality: _audioQuality,
      embedThumbnail: false,
      embedMetadata: true,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${state.selectedCount} videos to queue.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(playlistProvider);

    return ContentScaffold(
      title: 'Playlist Download',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Top Section
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fetch & Download Playlist',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
                const SizedBox(height: 4),
                Text(
                  'Paste a playlist or channel URL to load all videos before downloading.',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // URL Input Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropTarget(
                        onDragDone: (details) {},
                        onDragEntered: (_) => setState(() => _isDraggingOver = true),
                        onDragExited: (_) => setState(() => _isDraggingOver = false),
                        child: AnimatedContainer(
                          duration: AppConstants.shortAnimation,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
                            border: Border.all(
                              color: _isDraggingOver ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: TextField(
                            controller: _urlController,
                            focusNode: _urlFocusNode,
                            onChanged: _validateUrl,
                            onSubmitted: (_) => _fetchPlaylist(),
                            style: textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: 'Paste playlist URL here...',
                              errorText: _urlError,
                              fillColor: colorScheme.surfaceContainerLow,
                              prefixIcon: const Icon(Icons.link_rounded),
                              suffixIcon: _urlController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () => _urlController.clear(),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 56, // Match text field height
                      child: FilledButton.icon(
                        onPressed: state.isLoading ? null : _fetchPlaylist,
                        icon: state.isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.search_rounded),
                        label: Text(state.isLoading ? 'Fetching...' : 'Fetch'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius)),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              ],
            ),
          ),

          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.error!, style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ),
            ),

          // Videos List
          if (state.isFetched && state.videos.isEmpty && !state.isLoading && state.error == null)
            const Expanded(
              child: Center(child: Text('No videos found in this playlist.')),
            )
          else if (state.videos.isNotEmpty)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // List Header & Actions
                    Row(
                      children: [
                        Text('${state.totalCount} videos found', style: textTheme.titleMedium),
                        const Spacer(),
                        TextButton(
                          onPressed: () => ref.read(playlistProvider.notifier).selectAll(),
                          child: const Text('Select All'),
                        ),
                        TextButton(
                          onPressed: () => ref.read(playlistProvider.notifier).deselectAll(),
                          child: const Text('Deselect All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // List
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: state.videos.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final video = state.videos[index];
                            final isSelected = state.selectedIds.contains(video.id);
                            
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: video.thumbnailUrl != null
                                    ? Image.network(video.thumbnailUrl!, width: 80, height: 45, fit: BoxFit.cover,
                                        errorBuilder: (_,__,___) => Container(width: 80, height: 45, color: Colors.grey.withValues(alpha: 0.3), child: const Icon(Icons.video_file)))
                                    : Container(width: 80, height: 45, color: Colors.grey.withValues(alpha: 0.3), child: const Icon(Icons.video_file)),
                              ),
                              title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(video.formattedDuration),
                              trailing: Checkbox(
                                value: isSelected,
                                onChanged: (_) => ref.read(playlistProvider.notifier).toggleVideo(video.id),
                              ),
                              onTap: () => ref.read(playlistProvider.notifier).toggleVideo(video.id),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // If not fetched yet, empty space
          if (!state.isFetched && !state.isLoading)
             const Expanded(child: SizedBox()),

          // Bottom Bar (Options & Download)
          if (state.isFetched && state.videos.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Type
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Format', style: textTheme.labelSmall),
                          const SizedBox(height: 8),
                          DropdownButton<DownloadType>(
                            value: _downloadType,
                            isExpanded: true,
                            items: DownloadType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
                            onChanged: (v) => setState(() => _downloadType = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Directory
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Save to', style: textTheme.labelSmall),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _pickOutputDirectory,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: colorScheme.outlineVariant),
                                borderRadius: BorderRadius.circular(8),
                                color: colorScheme.surfaceContainerLow,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.folder_outlined, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(_outputDirectory ?? 'Select folder', maxLines: 1, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Download Button
                    FilledButton.icon(
                      onPressed: state.selectedCount == 0 ? null : _startDownload,
                      icon: const Icon(Icons.playlist_add_rounded),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Text('Download ${state.selectedCount}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
