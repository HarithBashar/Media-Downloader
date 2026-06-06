/// File system utilities for Media Downloader.
library;

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Provides platform-appropriate paths and file operations.
class FileUtils {
  FileUtils._();

  /// Returns the default downloads directory for the current OS.
  static Future<Directory> getDefaultDownloadsDirectory() async {
    if (Platform.isMacOS || Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        final dir = Directory(p.join(home, 'Downloads'));
        if (await dir.exists()) return dir;
      }
    } else if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        final dir = Directory(p.join(userProfile, 'Downloads'));
        if (await dir.exists()) return dir;
      }
    }
    // Fallback to app documents directory
    return await getApplicationDocumentsDirectory();
  }

  /// Returns the application's private support directory for storing binaries.
  static Future<Directory> getBinariesDirectory() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'binaries'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Returns the app logs directory.
  static Future<Directory> getLogsDirectory() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'logs'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Returns the download archive file path.
  static Future<File> getArchiveFile() async {
    final support = await getApplicationSupportDirectory();
    return File(p.join(support.path, 'archive', 'downloaded.txt'));
  }

  /// Ensures a directory exists, creating it recursively if needed.
  static Future<bool> ensureDirectoryExists(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) await dir.create(recursive: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Sanitises a filename by removing invalid characters.
  static String sanitiseFilename(String name) {
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Returns the file size in bytes, or null if the file does not exist.
  static Future<int?> getFileSize(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return await file.length();
    } catch (_) {
      return null;
    }
  }

  /// Makes a binary file executable on Unix systems.
  static Future<void> makeExecutable(String path) async {
    if (Platform.isWindows) return;
    await Process.run('chmod', ['+x', path]);
  }

  /// Checks available disk space at [directory] (approximate, Unix only).
  static Future<int?> getAvailableSpace(String directory) async {
    if (Platform.isWindows) return null; // Windows requires native interop
    try {
      final result = await Process.run('df', ['-k', directory]);
      if (result.exitCode != 0) return null;
      final lines = result.stdout.toString().split('\n');
      if (lines.length < 2) return null;
      final parts = lines[1].trim().split(RegExp(r'\s+'));
      if (parts.length < 4) return null;
      final available = int.tryParse(parts[3]);
      return available != null ? available * 1024 : null;
    } catch (_) {
      return null;
    }
  }
}
