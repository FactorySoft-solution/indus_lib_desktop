import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'file_explorer_service.dart';

class ProjectDataService {
  final Logger logger = Logger();
  final FileExplorerService _fileExplorerService = FileExplorerService();

  // Method to read project data from JSON file
  Future<Map<String, dynamic>?> readProjectData(String projectPath) async {
    try {
      final projectJsonFile = File(path.join(projectPath, 'project.json'));

      if (!await projectJsonFile.exists()) {
        logger.d('Project JSON file does not exist: ${projectJsonFile.path}');
        return null;
      }

      final String contents = await projectJsonFile.readAsString();
      final Map<String, dynamic> projectData = jsonDecode(contents);

      // Add directory paths to the project data
      projectData['projectPath'] = projectPath;
      projectData['copiedFolderPath'] = path.join(projectPath, 'copied_folder');

      return projectData;
    } catch (e) {
      logger.e('Error reading project data: $e');
      return null;
    }
  }

  // Method to get all projects
  Future<List<Map<String, dynamic>>> getAllProjects() async {
    try {
      final baseDir = _fileExplorerService.getBaseDirectory();
      if (!await _fileExplorerService.directoryExists(baseDir)) {
        logger.e('Base directory does not exist: $baseDir');
        return [];
      }

      final pieceRefDirs = await _fileExplorerService.listDirectories(baseDir);
      List<Map<String, dynamic>> results = [];

      for (var pieceRefDir in pieceRefDirs) {
        if (pieceRefDir is Directory) {
          final pieceIndexDirs =
              await _fileExplorerService.listDirectories(pieceRefDir.path);

          for (var pieceIndexDir in pieceIndexDirs) {
            if (pieceIndexDir is Directory) {
              final projectData = await readProjectData(pieceIndexDir.path);
              if (projectData != null) {
                results.add(projectData);
              }
            }
          }
        }
      }

      return results;
    } catch (e) {
      logger.e('Error getting all projects: $e');
      return [];
    }
  }

  // Method to get project by path
  Future<Map<String, dynamic>?> getProjectByPath(String projectPath) async {
    try {
      return await readProjectData(projectPath);
    } catch (e) {
      logger.e('Error getting project by path: $e');
      return null;
    }
  }

  // Method to save project data
  Future<bool> saveProjectData(
      String projectPath, Map<String, dynamic> projectData) async {
    try {
      final projectJsonFile = File(path.join(projectPath, 'project.json'));
      final jsonString = jsonEncode(projectData);
      await projectJsonFile.writeAsString(jsonString);
      return true;
    } catch (e) {
      logger.e('Error saving project data: $e');
      return false;
    }
  }

  // Method to update project field
  Future<bool> updateProjectField(
      String projectPath, String field, dynamic value) async {
    try {
      final projectData = await readProjectData(projectPath);
      if (projectData == null) return false;

      projectData[field] = value;
      return await saveProjectData(projectPath, projectData);
    } catch (e) {
      logger.e('Error updating project field: $e');
      return false;
    }
  }
}
