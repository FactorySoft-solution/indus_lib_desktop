import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

class FileExplorerService {
  final Logger logger = Logger();

  // Method to open a folder in the file explorer
  Future<void> openFolder(String folderPath) async {
    try {
      logger.i('Opening folder: $folderPath');

      // Clean up the path - replace forward slashes with backslashes on Windows
      String cleanPath = folderPath;
      if (Platform.isWindows) {
        cleanPath = folderPath.replaceAll('/', '\\');
        // Ensure path isn't quoted
        cleanPath = cleanPath.replaceAll('"', '');
      }

      // Special handling for aerobase path
      if (cleanPath.contains('aerobase')) {
        cleanPath = await _handleAerobasePath(cleanPath);
        if (cleanPath.isEmpty) return;
      }

      // Check if the folder exists
      final dir = Directory(cleanPath);
      if (!dir.existsSync()) {
        logger.e('Folder does not exist: $cleanPath');
        return;
      }

      await _openFolderInSystem(cleanPath);
    } catch (e) {
      logger.e('Error opening folder: $e');
    }
  }

  // Helper method to handle aerobase paths
  Future<String> _handleAerobasePath(String cleanPath) async {
    final parts = cleanPath.split('aerobase');
    if (parts.length > 1) {
      String afterAerobase = parts[1];
      if (afterAerobase.isEmpty) {
        logger.e(
            'Cannot open just the aerobase folder, need a specific project path');
        return '';
      }

      // Get user desktop
      String userProfile = Platform.environment['USERPROFILE'] ?? '';
      if (userProfile.isNotEmpty) {
        String desktopPath = "$userProfile\\Desktop";
        // Extract project ref and indice from the path if possible
        final regex = RegExp(r'(\w+)\\(\w+)');
        final match = regex.firstMatch(cleanPath.split('aerobase').last);

        if (match != null && match.groupCount >= 2) {
          String pieceRef = match.group(1) ?? '';
          String pieceIndice = match.group(2) ?? '';

          if (pieceRef.isNotEmpty && pieceIndice.isNotEmpty) {
            String newPath = "$desktopPath\\aerobase\\$pieceRef\\$pieceIndice";
            if (Directory(newPath).existsSync()) {
              return newPath;
            }
          }
        }
      }
    }
    return cleanPath;
  }

  // Helper method to open folder in system file explorer
  Future<void> _openFolderInSystem(String cleanPath) async {
    if (Platform.isWindows) {
      await Process.run('explorer.exe', [cleanPath]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [cleanPath]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [cleanPath]);
    } else {
      logger.e('Unsupported platform for opening folders');
    }
  }

  // Method to get base directory path
  String getBaseDirectory() {
    String userProfile = Platform.environment['USERPROFILE'] ??
        '/home/${Platform.environment['USER']}';
    return "$userProfile/Desktop/aerobase";
  }

  // Method to check if directory exists
  Future<bool> directoryExists(String path) async {
    return await Directory(path).exists();
  }

  // Method to list directories
  Future<List<FileSystemEntity>> listDirectories(String path) async {
    try {
      return await Directory(path).list().toList();
    } catch (e) {
      logger.e('Error listing directories: $e');
      return [];
    }
  }
}
