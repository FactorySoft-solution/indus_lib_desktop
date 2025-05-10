import 'dart:io';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'file_explorer_service.dart';

class ProjectFileService {
  final Logger logger = Logger();
  final FileExplorerService _fileExplorerService = FileExplorerService();

  // Method to get project folder path
  String getProjectFolderPath(String pieceRef, String pieceIndice) {
    final baseDir = _fileExplorerService.getBaseDirectory();
    return path.join(baseDir, pieceRef, pieceIndice);
  }

  // Method to check if project folder exists
  Future<bool> projectFolderExists(String pieceRef, String pieceIndice) async {
    final projectPath = getProjectFolderPath(pieceRef, pieceIndice);
    return await _fileExplorerService.directoryExists(projectPath);
  }

  // Method to create project folder structure
  Future<bool> createProjectFolder(String pieceRef, String pieceIndice) async {
    try {
      final projectPath = getProjectFolderPath(pieceRef, pieceIndice);

      // Create main project folder
      await Directory(projectPath).create(recursive: true);
      logger.i('Created project folder: $projectPath');

      // Create subfolders
      final subfolders = [
        'copied_folder',
        'Fiche Zoller',
        'Programme',
        'Dessin',
        'Photo'
      ];

      for (var folder in subfolders) {
        final subfolderPath = path.join(projectPath, folder);
        await Directory(subfolderPath).create();
        logger.i('Created subfolder: $subfolderPath');
      }

      return true;
    } catch (e) {
      logger.e('Error creating project folder structure: $e');
      return false;
    }
  }

  // Method to get project subfolder path
  String getProjectSubfolderPath(String projectPath, String subfolderName) {
    return path.join(projectPath, subfolderName);
  }

  // Method to list files in a project subfolder
  Future<List<FileSystemEntity>> listProjectSubfolderFiles(
      String projectPath, String subfolderName) async {
    try {
      final subfolderPath = getProjectSubfolderPath(projectPath, subfolderName);
      if (!await _fileExplorerService.directoryExists(subfolderPath)) {
        logger.w('Subfolder does not exist: $subfolderPath');
        return [];
      }

      final files = await _fileExplorerService.listDirectories(subfolderPath);
      logger.i('Found ${files.length} files in $subfolderPath');
      return files;
    } catch (e) {
      logger.e('Error listing project subfolder files: $e');
      return [];
    }
  }

  // Method to copy file to project subfolder
  Future<bool> copyFileToProjectSubfolder(
      String sourcePath, String projectPath, String subfolderName) async {
    try {
      final subfolderPath = getProjectSubfolderPath(projectPath, subfolderName);

      // Create subfolder if it doesn't exist
      if (!await _fileExplorerService.directoryExists(subfolderPath)) {
        await Directory(subfolderPath).create(recursive: true);
        logger.i('Created subfolder: $subfolderPath');
      }

      // Get source file name
      final fileName = path.basename(sourcePath);
      final destinationPath = path.join(subfolderPath, fileName);

      // Copy file
      await File(sourcePath).copy(destinationPath);
      logger.i('Copied file from $sourcePath to $destinationPath');

      return true;
    } catch (e) {
      logger.e('Error copying file to project subfolder: $e');
      return false;
    }
  }

  // Method to delete file from project subfolder
  Future<bool> deleteFileFromProjectSubfolder(
      String projectPath, String subfolderName, String fileName) async {
    try {
      final filePath = path.join(
          getProjectSubfolderPath(projectPath, subfolderName), fileName);

      if (!await File(filePath).exists()) {
        logger.w('File does not exist: $filePath');
        return false;
      }

      await File(filePath).delete();
      logger.i('Deleted file: $filePath');

      return true;
    } catch (e) {
      logger.e('Error deleting file from project subfolder: $e');
      return false;
    }
  }

  // Method to get Fiche Zoller file path
  Future<String?> getFicheZollerPath(String projectPath) async {
    try {
      final ficheZollerDir =
          getProjectSubfolderPath(projectPath, 'Fiche Zoller');
      if (!await _fileExplorerService.directoryExists(ficheZollerDir)) {
        logger.w('Fiche Zoller directory does not exist: $ficheZollerDir');
        return null;
      }

      final files =
          await listProjectSubfolderFiles(projectPath, 'Fiche Zoller');
      for (var file in files) {
        if (file is File &&
            file.path.toLowerCase().endsWith('.pdf') &&
            file.path.toLowerCase().contains('fiche z')) {
          logger.i('Found Fiche Zoller file: ${file.path}');
          return file.path;
        }
      }

      logger.w('No Fiche Zoller file found in: $ficheZollerDir');
      return null;
    } catch (e) {
      logger.e('Error getting Fiche Zoller path: $e');
      return null;
    }
  }

  // Method to get project files by type
  Future<List<FileSystemEntity>> getProjectFilesByType(
      String projectPath, String fileType) async {
    try {
      final files = <FileSystemEntity>[];
      final subfolders = [
        'copied_folder',
        'Fiche Zoller',
        'Programme',
        'Dessin',
        'Photo'
      ];

      for (var subfolder in subfolders) {
        final subfolderFiles =
            await listProjectSubfolderFiles(projectPath, subfolder);
        for (var file in subfolderFiles) {
          if (file is File &&
              file.path.toLowerCase().endsWith(fileType.toLowerCase())) {
            files.add(file);
          }
        }
      }

      logger.i(
          'Found ${files.length} files of type $fileType in project: $projectPath');
      return files;
    } catch (e) {
      logger.e('Error getting project files by type: $e');
      return [];
    }
  }

  // Method to check if project has specific file type
  Future<bool> hasFileType(String projectPath, String fileType) async {
    final files = await getProjectFilesByType(projectPath, fileType);
    return files.isNotEmpty;
  }

  // Method to get project folder size
  Future<int> getProjectFolderSize(String projectPath) async {
    try {
      int totalSize = 0;
      final dir = Directory(projectPath);

      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      logger.i('Project folder size: ${totalSize} bytes');
      return totalSize;
    } catch (e) {
      logger.e('Error getting project folder size: $e');
      return 0;
    }
  }
}
