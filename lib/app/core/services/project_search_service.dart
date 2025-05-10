import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';
import 'project_data_service.dart';

class ProjectSearchService {
  final Logger logger = Logger();
  final ProjectDataService _projectDataService = ProjectDataService();

  // Method to search for projects based on search criteria
  Future<List<Map<String, dynamic>>> searchProjects(
      Map<String, String> searchTerms) async {
    logger.i('Searching projects...');
    try {
      // Get all projects
      final allProjects = await _projectDataService.getAllProjects();
      List<Map<String, dynamic>> results = [];

      // Filter projects based on search criteria
      for (var projectData in allProjects) {
        if (matchesSearchCriteria(projectData, searchTerms)) {
          results.add(projectData);
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
        logger.d('Project data is empty');
        return false;
      }

      // If no search terms, return all projects
      if (searchTerms.isEmpty) {
        logger.d('No search terms provided, returning all projects');
        return true;
      }

      // Check each search term against project data
      for (final entry in searchTerms.entries) {
        final field = entry.key;
        final searchValue = entry.value.toLowerCase();
        logger.d('Checking field: $field with value: $searchValue');

        // Special handling for topSolideOperation
        if (field == "topSolideOperation") {
          if (!_matchesTopSolideOperation(projectData, searchValue)) {
            logger.d('No match found for topSolideOperation: $searchValue');
            return false;
          }
          logger.d('Found match for topSolideOperation: $searchValue');
          continue;
        }

        if (field == "selectedItems") {
          if (!_matchesSelectedItems(projectData, searchValue)) {
            logger.d('No match found for selectedItems: $searchValue');
            return false;
          }
          logger.d('Found match for selectedItems: $searchValue');
          continue;
        }

        // Check if field exists in project data
        if (!projectData.containsKey(field) ||
            projectData[field] == null ||
            projectData[field].toString().isEmpty) {
          logger.d('Field $field not found in project data');
          return false;
        }

        // Check if field value contains search term
        final fieldValue = projectData[field].toString().toLowerCase();
        if (!fieldValue.contains(searchValue)) {
          logger.d('No match found for field $field: $searchValue');
          return false;
        }
        logger.d('Match found for field $field: $searchValue');
      }

      logger.d('All search criteria matched');
      return true;
    } catch (e) {
      logger.e('Error matching search criteria: $e');
      return false;
    }
  }

  // Helper method to check topSolideOperation in operations array
  bool _matchesTopSolideOperation(
      Map<String, dynamic> projectData, String searchValue) {
    logger.d('Checking topSolideOperation for value: $searchValue');

    // Check if operations array exists
    if (!projectData.containsKey('operations') ||
        projectData['operations'] == null ||
        !(projectData['operations'] is List)) {
      logger.d('No operations array found in project data');
      return false;
    }

    // Search through all operations for matching topSolideOperation
    final operations = projectData['operations'] as List;
    logger.d('Found ${operations.length} operations to check');

    for (var operation in operations) {
      if (operation is Map &&
          operation.containsKey('topSolideOperation') &&
          operation['topSolideOperation'] != null) {
        final operationValue =
            operation['topSolideOperation'].toString().toLowerCase();
        logger.d('Checking operation value: $operationValue');
        if (operationValue.contains(searchValue)) {
          logger.d('Found matching topSolideOperation: $operationValue');
          return true;
        }
      }
    }

    logger.d('No matching topSolideOperation found');
    return false;
  }

  // Helper method to check selected items
  bool _matchesSelectedItems(
      Map<String, dynamic> projectData, String searchValue) {
    // Check if project has selectedItems field
    if (!projectData.containsKey('selectedItems') ||
        projectData['selectedItems'] == null ||
        projectData['selectedItems'].toString().isEmpty) {
      logger.d('Project has no selectedItems field');
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

    final searchSelectedItems = searchValue
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    logger.d('Project selected items: $projectSelectedItems');
    logger.d('Search selected items: $searchSelectedItems');

    // Check if at least one search item exists in project items
    for (var searchItem in searchSelectedItems) {
      if (projectSelectedItems.any((projectItem) =>
          projectItem.contains(searchItem) ||
          searchItem.contains(projectItem))) {
        logger.d('Found match for selected item: $searchItem');
        return true;
      }
    }

    logger.d('No matches found for selected items');
    return false;
  }

  // Method to sort search results
  List<Map<String, dynamic>> sortResults(
      List<Map<String, dynamic>> results, String sortField, bool ascending) {
    logger.d(
        'Sorting results by $sortField ${ascending ? 'ascending' : 'descending'}');

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

    logger.d('Sorting completed');
    return results;
  }
}
