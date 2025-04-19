import 'dart:convert';
import 'dart:io';
import 'package:code_g/app/core/services/files_services.dart';
import 'package:code_g/app/core/services/json_services.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  final Logger logger = Logger();
  final JsonServices jsonServices = JsonServices();
  final FilesServices filesServices = FilesServices();

  // Cache for JSON data
  final Map<String, dynamic> _jsonCache = {};

  /// Extract indices JSON data with caching
  Future<List<dynamic>> extractIndicesJsonData() async {
    const cacheKey = 'indiceJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadIndiceJson();
      var newData = [...fetchedJsonData["contenu"]];
      _jsonCache[cacheKey] = newData;

      return newData;
    } catch (e) {
      logger.e('Error extracting indices JSON data: $e');
      return [];
    }
  }

  /// Extract machine JSON data with caching
  Future<List<dynamic>> extractMachineJsonData() async {
    const cacheKey = 'machineJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadMachineJson();
      var newData = [...fetchedJsonData["contenu"][0]["machines"]];

      // Sort machines alphabetically by name
      newData.sort((a, b) {
        final String nameA = a['nom']?.toString().toLowerCase() ?? '';
        final String nameB = b['nom']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      _jsonCache[cacheKey] = newData;
      return newData;
    } catch (e) {
      logger.e('Error extracting machine JSON data: $e');
      return [];
    }
  }

  /// Extract mechoire JSON data with caching
  Future<List<dynamic>> extractMechoireJsonData() async {
    const cacheKey = 'mechoireJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final Map<String, dynamic> fetchedJsonData = await jsonServices
          .loadJsonFromAssets('assets/json/machoireEJECTION.json');
      var newData = [...fetchedJsonData["contenu"][0]["types"]];

      // Sort types alphabetically
      newData.sort((a, b) {
        final String nameA = a.toString().toLowerCase();
        final String nameB = b.toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      _jsonCache[cacheKey] = newData;
      return newData;
    } catch (e) {
      logger.e('Error extracting mechoire JSON data: $e');
      return [];
    }
  }

  /// Extract programmers JSON data with caching
  Future<List<dynamic>> extractProgrammersJsonData() async {
    const cacheKey = 'programmersJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadProgrammerJson();
      var newData = [...fetchedJsonData["contenu"]];

      // Sort the programmers data alphabetically by name
      newData.sort((a, b) {
        final String nameA = a['nom']?.toString().toLowerCase() ?? '';
        final String nameB = b['nom']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      _jsonCache[cacheKey] = newData;
      return newData;
    } catch (e) {
      logger.e('Error extracting programmers JSON data: $e');
      return [];
    }
  }

  /// Extract arrosage types JSON data with caching
  Future<List<dynamic>> extractArrosageTypesJsonData() async {
    const cacheKey = 'arrosageTypesJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadArrosageJson();
      var newData = [...fetchedJsonData["contenu"]];

      // Sort arrosage types alphabetically by name
      newData.sort((a, b) {
        final String nameA = a['name']?.toString().toLowerCase() ?? '';
        final String nameB = b['name']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      _jsonCache[cacheKey] = newData;
      return newData;
    } catch (e) {
      logger.e('Error extracting arrosage types JSON data: $e');
      return [];
    }
  }

  /// Extract top solide operations JSON data with caching
  Future<List<dynamic>> extractTopSolideOperationsJsonData() async {
    const cacheKey = 'topSolideOperationsJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadTopSolideJson();
      var newData = [...fetchedJsonData["contenu"]];

      // Sort operations alphabetically by name
      newData.sort((a, b) {
        final String nameA = a['name']?.toString().toLowerCase() ?? '';
        final String nameB = b['name']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      _jsonCache[cacheKey] = newData;
      return newData;
    } catch (e) {
      logger.e('Error extracting top solide operations JSON data: $e');
      return [];
    }
  }

  /// Copy the selected project to the destination folder
  Future<bool> copyProjectFolder({
    required String sourceFolder,
    required String pieceRef,
    required String pieceIndice,
    required String fileZPath,
    required String formPath,
    required String faoFilePath,
    required Map<String, dynamic> projectData,
  }) async {
    try {
      String userProfile = Platform.environment['USERPROFILE'] ??
          '\\home\\${Platform.environment['USER']}';
      String defaultDesktopPath = "$userProfile\\Desktop\\aerobase";
      String subPath = "${pieceRef}\\${pieceIndice}\\copied_folder";
      final sourceDir = Directory(sourceFolder);
      final destinationDir = Directory(path.join(defaultDesktopPath, subPath));

      if (!sourceDir.existsSync()) {
        logger.e("Source directory does not exist.");
        return false;
      }

      // Create destination directory
      destinationDir.createSync(recursive: true);
      filesServices.copyDirectory(sourceDir, destinationDir);
      logger.i("Files copied successfully.");

      // Create and manage Fiche Zoller folder
      final ficheZollerDir =
          Directory(path.join(destinationDir.path, 'Fiche Zoller'));
      if (!ficheZollerDir.existsSync()) {
        ficheZollerDir.createSync(recursive: true);
        logger.i("Fiche Zoller folder created.");
      }

      // Copy files to Fiche Zoller directory
      _ensureFileInDirectory(fileZPath, ficheZollerDir);
      _ensureFileInDirectory(formPath, ficheZollerDir);

      // Clean up Thumbs.db
      _removeThumbsDb(destinationDir);
      _removeJsonFileWithSameName(fileZPath);

      // Check and handle ARC files
      if (!_containsArcFiles(destinationDir)) {
        _ensureFileInDirectory(faoFilePath, destinationDir);
      }

      // Save project data
      _saveProjectDataToJson(
          path.join(destinationDir.parent.path, 'project.json'), projectData);

      return true;
    } catch (e) {
      logger.e("Error copying folder: $e");
      return false;
    }
  }

  /// Process File Z to extract JSON data
  Future<Map<String, dynamic>> processFileZ(String filePath) async {
    try {
      String fileName = path.basename(filePath);
      String directory = path.dirname(filePath);

      Map<String, dynamic> structuredJson =
          await filesServices.convertFileZHtmlToJson(filePath);

      // Save the JSON to a file
      await filesServices.saveContentToFile(
          structuredJson, directory, fileName.split(".")[0], "json");

      return structuredJson;
    } catch (e) {
      logger.e("Error processing file Z: $e");
      return {};
    }
  }

  /// Check if directory contains .arc files
  bool _containsArcFiles(Directory directory) {
    try {
      final arcFiles = directory.listSync().where((entity) {
        if (entity is File) {
          final extension = path.extension(entity.path).toLowerCase();
          return extension == '.arc';
        }
        return false;
      }).toList();
      return arcFiles.isNotEmpty;
    } catch (e) {
      logger.e("Error checking for ARC files: $e");
      return false;
    }
  }

  /// Remove JSON file with the same name
  void _removeJsonFileWithSameName(String filePath) {
    if (filePath.isEmpty) return;

    try {
      final fileNameWithoutExtension = path.basenameWithoutExtension(filePath);
      final directory = path.dirname(filePath);
      final jsonFile =
          File(path.join(directory, '$fileNameWithoutExtension.json'));

      if (jsonFile.existsSync()) {
        jsonFile.deleteSync();
        logger.i("Removed JSON file: ${jsonFile.path}");
      }
    } catch (e) {
      logger.e("Error removing JSON file: $e");
    }
  }

  /// Remove Thumbs.db file from directory
  void _removeThumbsDb(Directory directory) {
    try {
      final thumbsDbFile = File(path.join(directory.path, 'Thumbs.db'));
      if (thumbsDbFile.existsSync()) {
        thumbsDbFile.deleteSync();
        logger.i("Thumbs.db file removed from ${directory.path}");
      }
    } catch (e) {
      logger.e("Error removing Thumbs.db: $e");
    }
  }

  /// Ensure file exists in directory, copy if it doesn't
  void _ensureFileInDirectory(String filePath, Directory destinationDir) {
    if (filePath.isEmpty) return;

    try {
      final file = File(filePath);
      final destinationFile =
          File(path.join(destinationDir.path, path.basename(file.path)));

      if (!destinationFile.existsSync()) {
        if (file.existsSync()) {
          file.copySync(destinationFile.path);
          logger.i("Copied ${file.path} to ${destinationFile.path}");
          // Remove Thumbs.db if it exists
          _removeThumbsDb(destinationDir);
        } else {
          logger.w("Source file ${file.path} does not exist.");
        }
      } else {
        logger.i(
            "File ${destinationFile.path} already exists in the destination.");
      }
    } catch (e) {
      logger.e("Error ensuring file in directory: $e");
    }
  }

  /// Save project data to JSON file
  void _saveProjectDataToJson(
      String filePath, Map<String, dynamic> projectData) {
    try {
      // Convert to JSON and save to file
      final jsonString = jsonEncode(projectData);
      final file = File(filePath);
      file.writeAsStringSync(jsonString);

      logger.i("Project data saved to $filePath");
    } catch (e) {
      logger.e("Error saving project data to JSON: $e");
    }
  }

  /// Validate files for specific types
  bool isValidFaoFile(String filePath) {
    try {
      if (filePath.isEmpty) return false;

      String fileName = path.basename(filePath);
      return (fileName.toLowerCase().endsWith('.arc')) &&
          !fileName.toLowerCase().contains('pince');
    } catch (e) {
      logger.e("Error validating FAO file: $e");
      return false;
    }
  }

  bool isValidPlanFile(String filePath) {
    try {
      if (filePath.isEmpty) return false;

      String fileName = path.basename(filePath);
      return fileName.toLowerCase().contains("ind") &&
          fileName.toLowerCase().endsWith('.pdf');
    } catch (e) {
      logger.e("Error validating plan file: $e");
      return false;
    }
  }

  bool isValidFileZ(String filePath) {
    try {
      if (filePath.isEmpty) return false;

      String fileName = path.basename(filePath);
      return fileName.toLowerCase().contains('fiche z') &&
          fileName.toLowerCase().endsWith('.pdf');
    } catch (e) {
      logger.e("Error validating File Z: $e");
      return false;
    }
  }
}
