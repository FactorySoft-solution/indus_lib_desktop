import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';

class ProjectSearchService {
  final Logger logger = Logger();

  // Method to search for projects based on search criteria
  Future<List<Map<String, dynamic>>> searchProjects(
      Map<String, String> searchTerms) async {
    logger.i('Searching projects...');
    try {
      // Get the base directory path (Desktop/aerobase)
      String userProfile = Platform.environment['USERPROFILE'] ??
          '/home/${Platform.environment['USER']}';
      String baseDir = "$userProfile/Desktop/aerobase";

      if (!await Directory(baseDir).exists()) {
        logger.e('Base directory does not exist: $baseDir');
        return [];
      }

      // Get all piece reference directories
      final pieceRefDirs = await Directory(baseDir).list().toList();
      List<Map<String, dynamic>> results = [];

      for (var pieceRefDir in pieceRefDirs) {
        if (pieceRefDir is Directory) {
          // Get all piece index directories
          final pieceIndexDirs = await pieceRefDir.list().toList();

          for (var pieceIndexDir in pieceIndexDirs) {
            if (pieceIndexDir is Directory) {
              try {
                // Look for project.json file
                final projectJsonFile =
                    File(path.join(pieceIndexDir.path, 'project.json'));

                if (await projectJsonFile.exists()) {
                  // Read project data from JSON file
                  final String contents = await projectJsonFile.readAsString();
                  final Map<String, dynamic> projectData = jsonDecode(contents);

                  // Add directory paths to the project data
                  projectData['projectPath'] = pieceIndexDir.path;
                  projectData['copiedFolderPath'] =
                      path.join(pieceIndexDir.path, 'copied_folder');

                  // Check if project matches search criteria
                  if (matchesSearchCriteria(projectData, searchTerms)) {
                    results.add(projectData);
                  }
                }
              } catch (e) {
                logger
                    .e('Error processing directory ${pieceIndexDir.path}: $e');
                continue;
              }
            }
          }
        }
      }

      logger.i('Found ${results.length} matching projects');
      return results;
    } catch (e) {
      logger.e('Error searching projects: $e');
      return [];
    }
  }

  // Method to check if a project matches search criteria
  bool matchesSearchCriteria(
      Map<String, dynamic> projectData, Map<String, String> searchTerms) {
    try {
      // Check if project data exists
      if (projectData.isEmpty) {
        return false;
      }

      // If no search terms, return all projects
      if (searchTerms.isEmpty) {
        return true;
      }

      // Check each search term against project data
      for (final entry in searchTerms.entries) {
        final field = entry.key;
        final searchValue = entry.value.toLowerCase();

        // Special handling for topSolideOperation
        if (field == "topSolideOperation") {
          if (!_matchesTopSolideOperation(projectData, searchValue)) {
            return false;
          }
          continue;
        }
        if (field == "selectedItems") {
          // Check if project has selectedItems field
          if (!projectData.containsKey('selectedItems') ||
              projectData['selectedItems'] == null ||
              projectData['selectedItems'].toString().isEmpty) {
            return false;
          }

          // Convert both arrays to lowercase for case-insensitive comparison
          final projectSelectedItems = projectData['selectedItems']
              .toString()
              .toLowerCase()
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList();

          final searchSelectedItems = searchTerms['selectedItems']
                  ?.toLowerCase()
                  .split(',')
                  .map((item) => item.trim())
                  .where((item) => item.isNotEmpty)
                  .toList() ??
              [];

          // Check if at least one search item exists in project items
          bool hasMatch = false;
          for (var searchItem in searchSelectedItems) {
            print("searching for  = $searchItem");
            if (projectSelectedItems.any((projectItem) =>
                projectItem.contains(searchItem) ||
                searchItem.contains(projectItem))) {
              hasMatch = true;
              break;
            }
          }

          if (!hasMatch) {
            return false;
          }
          continue;
        }

        // Check if field exists in project data
        if (!projectData.containsKey(field) ||
            projectData[field] == null ||
            projectData[field].toString().isEmpty) {
          return false;
        }

        // Check if field value contains search term
        final fieldValue = projectData[field].toString().toLowerCase();
        if (!fieldValue.contains(searchValue)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      logger.e('Error matching search criteria: $e');
      return false;
    }
  }

  // Helper method to check topSolideOperation in operations array
  bool _matchesTopSolideOperation(
      Map<String, dynamic> projectData, String searchValue) {
    // Check if operations array exists
    if (!projectData.containsKey('operations') ||
        projectData['operations'] == null ||
        !(projectData['operations'] is List)) {
      return false;
    }

    // Search through all operations for matching topSolideOperation
    final operations = projectData['operations'] as List;

    for (var operation in operations) {
      if (operation is Map &&
          operation.containsKey('topSolideOperation') &&
          operation['topSolideOperation'] != null) {
        final operationValue =
            operation['topSolideOperation'].toString().toLowerCase();
        if (operationValue.contains(searchValue)) {
          return true;
        }
      }
    }

    return false;
  }

  // Method to sort search results
  List<Map<String, dynamic>> sortResults(
      List<Map<String, dynamic>> results, String sortField, bool ascending) {
    results.sort((a, b) {
      // Handle null values by putting them last
      if (!a.containsKey(sortField) || a[sortField] == null)
        return ascending ? 1 : -1;
      if (!b.containsKey(sortField) || b[sortField] == null)
        return ascending ? -1 : 1;

      // Handle date sorting
      if (sortField == 'createdDate') {
        final aDate = a[sortField].toString();
        final bDate = b[sortField].toString();
        return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
      }

      // Default string comparison
      final aValue = a[sortField].toString().toLowerCase();
      final bValue = b[sortField].toString().toLowerCase();
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });

    return results;
  }
}
