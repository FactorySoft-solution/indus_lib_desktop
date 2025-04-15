import 'package:code_g/app/core/services/files_services.dart';
import 'package:code_g/app/core/services/json_services.dart';
import 'package:code_g/app/core/services/shared_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

class SearchPieceController extends GetxController {
  final Logger logger = new Logger();
  final SharedService sharedService = SharedService();
  final JsonServices jsonServices = JsonServices();
  final FilesServices filesServices = new FilesServices();

  // Search results
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;

  // Search fields
  final machine = ''.obs;
  final pieceDiametre = ''.obs;
  final form = ''.obs;
  final epaisseur = ''.obs;
  final operationName = ''.obs;
  final topSolideOperation = ''.obs;
  final materiel = ''.obs;
  final specification = ''.obs;
  final selectedItems =
      <String>[].obs; // Observable list for selected checkboxes
  final selectedItemsController = TextEditingController();

  final machineController = TextEditingController();
  final pieceDiametreController = TextEditingController();
  final formController = TextEditingController();
  final epaisseurController = TextEditingController();
  final operationNameController = TextEditingController();
  final topSolideOperationController = TextEditingController();
  final materielController = TextEditingController();
  final specificationController = TextEditingController();

  // Observable fields for search
  final RxString sortField = 'pieceRef'.obs; // Default sort field
  final RxBool sortAscending = true.obs; // Default sort order
  final RxString displayTemplate =
      'grid'.obs; // Display template: 'list' or 'grid'

  // Sort options map (display name to field name)
  final Map<String, String> sortOptions = {
    'Référence (A-Z)': 'pieceRef',
    'Indice (A-Z)': 'pieceIndice',
    'Machine (A-Z)': 'machine',
    'Nom de pièce (A-Z)': 'pieceName',
    'Date (Plus récent)': 'createdDate',
  };

  @override
  void onInit() {
    super.onInit();
    // Add listeners to controllers to update observable fields when values change
    setupControllerListeners();
  }

  @override
  void onClose() {
    // Dispose controllers when not needed
    machineController.dispose();
    pieceDiametreController.dispose();
    formController.dispose();
    epaisseurController.dispose();
    operationNameController.dispose();
    topSolideOperationController.dispose();
    materielController.dispose();
    specificationController.dispose();
    super.onClose();
  }

  Future<List<dynamic>> extractMachineJsonData() async {
    try {
      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadMachineJson();
      var newData = [...fetchedJsonData["contenu"][0]["machines"]];

      // Sort machines alphabetically by name
      newData.sort((a, b) {
        final String nameA = a['nom']?.toString().toLowerCase() ?? '';
        final String nameB = b['nom']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> extractMechoireJsonData() async {
    try {
      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadMechoireJson();
      var newData = [...fetchedJsonData["contenu"][0]["types"]];

      // Sort types alphabetically
      newData.sort((a, b) {
        final String nameA = a.toString().toLowerCase();
        final String nameB = b.toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> extractProgrammersJsonData() async {
    try {
      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadProgrammerJson();
      var newData = [...fetchedJsonData["contenu"]];

      // Sort programmers alphabetically by name
      newData.sort((a, b) {
        final String nameA = a['nom']?.toString().toLowerCase() ?? '';
        final String nameB = b['nom']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> extractArrosageTypesJsonData() async {
    try {
      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadArrosageJson();

      var newData = [...fetchedJsonData["contenu"]];

      // Sort arrosage types alphabetically by name
      newData.sort((a, b) {
        final String nameA = a['name']?.toString().toLowerCase() ?? '';
        final String nameB = b['name']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> extractTopSolideOperationsJsonData() async {
    try {
      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadTopSolideJson();
      var newData = [...fetchedJsonData["contenu"]];

      // Sort operations alphabetically by name
      newData.sort((a, b) {
        final String nameA = a['name']?.toString().toLowerCase() ?? '';
        final String nameB = b['name']?.toString().toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> extractDiametreJsonData() async {
    // Implement the logic to fetch diametre data
    return [];
  }

  Future<List<Map<String, dynamic>>> extractMaterialJsonData() async {
    // Implement the logic to fetch material data
    return [];
  }

  Future<List<Map<String, dynamic>>> extractSpecificationJsonData() async {
    // Implement the logic to fetch specification data
    return [];
  }

  // Method to search for projects
  Future<void> searchProjects() async {
    logger.i('Searching projects...');
    try {
      // Get the base directory path (Desktop/aerobase)
      String userProfile = Platform.environment['USERPROFILE'] ??
          '/home/${Platform.environment['USER']}';
      String baseDir = "$userProfile/Desktop/aerobase";

      if (!await Directory(baseDir).exists()) {
        logger.e('Base directory does not exist: $baseDir');
        return;
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
                // Look for project.json file first
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

                  // Check for Fiche Zoller files
                  await enrichProjectDataWithFicheZoller(
                      projectData, Directory(projectData['copiedFolderPath']));

                  // Check if project matches search criteria
                  if (matchesSearchCriteria(projectData)) {
                    results.add(projectData);
                  }
                  continue; // Skip further processing for this directory
                }

                // If no project.json file, fallback to look for copied_folder
                final copiedFolder =
                    Directory(path.join(pieceIndexDir.path, 'copied_folder'));
                if (await copiedFolder.exists()) {
                  // Create base project data from directory structure
                  final projectData = {
                    'projectPath': pieceIndexDir.path,
                    'pieceRef': path.basename(pieceRefDir.path),
                    'pieceIndice': path.basename(pieceIndexDir.path),
                    'copiedFolderPath': copiedFolder.path,
                  };

                  // Look for Fiche Zoller folder and files
                  await enrichProjectDataWithFicheZoller(
                      projectData, copiedFolder);

                  // Check if project matches search criteria
                  if (matchesSearchCriteria(projectData)) {
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

      searchResults.value = results;
      logger.i('Found ${results.length} matching projects');
    } catch (e) {
      logger.e('Error searching projects: $e');
      searchResults.clear();
    }
  }

  // Method to look for Fiche Zoller file and extract machine info
  Future<void> enrichProjectDataWithFicheZoller(
      Map<String, dynamic> projectData, Directory copiedFolder) async {
    try {
      // Check if "Fiche Zoller" folder exists
      final ficheZollerDir =
          Directory(path.join(copiedFolder.path, 'Fiche Zoller'));
      if (await ficheZollerDir.exists()) {
        // Look for PDF files in the Fiche Zoller folder
        final files = await ficheZollerDir.list().toList();
        for (var file in files) {
          if (file is File &&
              file.path.toLowerCase().endsWith('.pdf') &&
              file.path.toLowerCase().contains('fiche z')) {
            // Found a Fiche Zoller PDF file
            projectData['ficheZollerPath'] = file.path;
            projectData['ficheZollerFilename'] = path.basename(file.path);

            // Don't try to extract machine name, just store the filename
            // for later comparison during search
            break; // Found one Fiche Zoller file, no need to continue
          }
        }
      }
    } catch (e) {
      logger.e('Error enriching project with Fiche Zoller data: $e');
    }
  }

  // Method to check if a project matches search criteria
  bool matchesSearchCriteria(Map<String, dynamic> projectData) {
    try {
      // Check if project data exists
      if (projectData.isEmpty) {
        return false;
      }

      // Get search terms from controllers (non-empty only)
      final searchTerms = <String, String>{};

      if (machine.value.isNotEmpty) {
        searchTerms['machine'] = machine.value.toLowerCase();
      }

      if (pieceDiametre.value.isNotEmpty) {
        searchTerms['pieceDiametre'] = pieceDiametre.value.toLowerCase();
      }
      if (form.value.isNotEmpty) searchTerms['form'] = form.value.toLowerCase();

      if (epaisseur.value.isNotEmpty) {
        searchTerms['epaisseur'] = epaisseur.value.toLowerCase();
      }
      if (operationName.value.isNotEmpty) {
        searchTerms['operationName'] = operationName.value.toLowerCase();
      }
      if (topSolideOperation.value.isNotEmpty) {
        searchTerms['topSolideOperation'] =
            topSolideOperation.value.toLowerCase();
      }

      if (materiel.value.isNotEmpty) {
        searchTerms['materiel'] = materiel.value.toLowerCase();
      }
      if (specification.value.isNotEmpty) {
        searchTerms['specification'] = specification.value.toLowerCase();
      }
      // If no search terms and no selected items, return all projects
      if (searchTerms.isEmpty && selectedItems.isEmpty) {
        return true;
      }

      // Check if Fiche Zoller filename contains machine name if searching by machine
      if (searchTerms.containsKey('machine') &&
          projectData.containsKey('ficheZollerFilename') &&
          projectData['ficheZollerFilename'] != null &&
          projectData['ficheZollerFilename'].toString().isNotEmpty) {
        final ficheZollerFilename =
            projectData['ficheZollerFilename'].toString().toLowerCase();
        // If the Fiche Zoller file exists but doesn't contain the machine name, exclude this project
        if (!ficheZollerFilename.contains(searchTerms['machine']!)) {
          return false;
        }
        // If matched by Fiche Zoller, no need to check machine in project data
        searchTerms.remove('machine');
      }

      // Check remaining search terms against project data
      for (final entry in searchTerms.entries) {
        final field = entry.key;
        final searchValue = entry.value;

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

      // Check selected items (checkboxes)
      if (selectedItems.isNotEmpty) {
        // If project doesn't have selectedItems field, return false
        if (!projectData.containsKey('selectedItems') ||
            projectData['selectedItems'] == null ||
            projectData['selectedItems'].toString().isEmpty) {
          return false;
        }

        // Get the project's selectedItems value
        String projectSelectedItems =
            projectData['selectedItems'].toString().toLowerCase();

        // Check if at least one of the selected items is in the project's selectedItems
        bool hasAtLeastOneSelectedItem = false;
        for (final item in selectedItems) {
          if (projectSelectedItems.contains(item.toLowerCase())) {
            hasAtLeastOneSelectedItem = true;
            break; // Found one match, no need to check others
          }
        }

        // If none of the selected items match, exclude this project
        if (!hasAtLeastOneSelectedItem) {
          return false;
        }
      }

      // If all search criteria match, return true
      return true;
    } catch (e) {
      logger.e('Error matching search criteria: $e');
      return false;
    }
  }

  // Method to update search field values from controllers
  void updateSearchFields() {
    machine.value = machineController.text.trim();
    pieceDiametre.value = pieceDiametreController.text.trim();
    form.value = formController.text.trim();
    epaisseur.value = epaisseurController.text.trim();
    operationName.value = operationNameController.text.trim();
    topSolideOperation.value = topSolideOperationController.text.trim();
    materiel.value = materielController.text.trim();
    specification.value = specificationController.text.trim();

    // Update selected items from the controller text
    // The format is expected to be comma-separated values
    if (selectedItemsController.text.isNotEmpty) {
      selectedItems.clear();
      final items = selectedItemsController.text.split(',');
      for (var item in items) {
        final trimmedItem = item.trim();
        if (trimmedItem.isNotEmpty) {
          selectedItems.add(trimmedItem);
        }
      }
    } else {
      selectedItems.clear();
    }
  }

  // Method to perform search with current field values
  Future<void> performSearch() async {
    updateSearchFields();
    await searchProjects();
    sortResults(); // Apply sorting after search
  }

  // Method to sort search results
  void sortResults() {
    final field = sortField.value;
    final ascending = sortAscending.value;

    // Sort the results list based on the sort field
    searchResults.sort((a, b) {
      // Handle null values by putting them last
      if (!a.containsKey(field) || a[field] == null) return ascending ? 1 : -1;
      if (!b.containsKey(field) || b[field] == null) return ascending ? -1 : 1;

      // Handle date sorting
      if (field == 'createdDate') {
        final aDate = a[field].toString();
        final bDate = b[field].toString();
        return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
      }

      // Default string comparison
      final aValue = a[field].toString().toLowerCase();
      final bValue = b[field].toString().toLowerCase();
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  // Method to clear search results
  void clearSearch() {
    searchResults.clear();
    machine.value = '';
    pieceDiametre.value = '';
    form.value = '';
    epaisseur.value = '';
    operationName.value = '';
    topSolideOperation.value = '';
    materiel.value = '';
    specification.value = '';

    machineController.clear();
    pieceDiametreController.clear();
    formController.clear();
    epaisseurController.clear();
    operationNameController.clear();
    topSolideOperationController.clear();
    materielController.clear();
    specificationController.clear();
  }

  // Setup listeners for text controllers to update reactive fields
  void setupControllerListeners() {
    machineController.addListener(() {
      machine.value = machineController.text.trim();
    });

    pieceDiametreController.addListener(() {
      pieceDiametre.value = pieceDiametreController.text.trim();
    });

    formController.addListener(() {
      form.value = formController.text.trim();
    });

    epaisseurController.addListener(() {
      epaisseur.value = epaisseurController.text.trim();
    });

    operationNameController.addListener(() {
      operationName.value = operationNameController.text.trim();
    });

    topSolideOperationController.addListener(() {
      topSolideOperation.value = topSolideOperationController.text.trim();
    });

    materielController.addListener(() {
      materiel.value = materielController.text.trim();
    });

    specificationController.addListener(() {
      specification.value = specificationController.text.trim();
    });
  }

  // Handle reset for a specific field
  void handleReset(String fieldName) {
    switch (fieldName) {
      case 'machine':
        machineController.clear();
        machine.value = '';
        break;
      case 'pieceDiametre':
        pieceDiametreController.clear();
        pieceDiametre.value = '';
        break;
      case 'form':
        formController.clear();
        form.value = '';
        break;
      case 'epaisseur':
        epaisseurController.clear();
        epaisseur.value = '';
        break;
      case 'operationName':
        operationNameController.clear();
        operationName.value = '';
        break;
      case 'topSolideOperation':
        topSolideOperationController.clear();
        topSolideOperation.value = '';
        break;
      case 'materiel':
        materielController.clear();
        materiel.value = '';
        break;
      case 'specification':
        specificationController.clear();
        specification.value = '';
        break;
      default:
        break;
    }

    // Auto-search if we have other fields with values
    if (hasActiveSearchFilters()) {
      performSearch();
    }
  }

  // Check if there are any active search filters
  bool hasActiveSearchFilters() {
    return machine.value.isNotEmpty ||
        pieceDiametre.value.isNotEmpty ||
        form.value.isNotEmpty ||
        epaisseur.value.isNotEmpty ||
        operationName.value.isNotEmpty ||
        topSolideOperation.value.isNotEmpty ||
        materiel.value.isNotEmpty ||
        specification.value.isNotEmpty ||
        selectedItems.isNotEmpty; // Add check for selected items
  }

  // Toggle between list and grid display templates
  void toggleDisplayTemplate() {
    displayTemplate.value = displayTemplate.value == 'list' ? 'grid' : 'list';
    logger.i('Display template changed to: ${displayTemplate.value}');
  }

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

      logger.i('Cleaned path: $cleanPath');

      // Special handling for aerobase path
      if (cleanPath.contains('aerobase')) {
        final parts = cleanPath.split('aerobase');
        if (parts.length > 1) {
          // Add the pieceRef and pieceIndice to the path if it's not there
          String afterAerobase = parts[1];
          logger.i('After aerobase: $afterAerobase');

          if (afterAerobase.isEmpty) {
            // This is just the aerobase path with no specific project
            logger.e(
                'Cannot open just the aerobase folder, need a specific project path');
            return;
          }
        }
      }

      // Check if the folder exists
      final dir = Directory(cleanPath);
      if (!dir.existsSync()) {
        logger.e('Folder does not exist: $cleanPath');
        // Try to infer the correct path if it contains aerobase
        if (cleanPath.contains('aerobase')) {
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
                String newPath =
                    "$desktopPath\\aerobase\\$pieceRef\\$pieceIndice";
                logger.i('Trying alternative path: $newPath');

                if (Directory(newPath).existsSync()) {
                  cleanPath = newPath;
                  logger.i('Alternative path exists, using: $cleanPath');
                } else {
                  logger.e('Alternative path does not exist: $newPath');
                  return;
                }
              } else {
                logger
                    .e('Could not extract pieceRef and pieceIndice from path');
                return;
              }
            } else {
              logger.e('Could not match project information in path');
              return;
            }
          } else {
            logger.e('Could not determine user profile');
            return;
          }
        } else {
          return;
        }
      }

      logger.i('Folder exists, attempting to open: $cleanPath');

      if (Platform.isWindows) {
        // On Windows, use explorer.exe
        logger.i('Running: explorer.exe "$cleanPath"');
        final result = await Process.run('explorer.exe', [cleanPath]);
        logger.i('Process exit code: ${result.exitCode}');
        logger.i('Process stdout: ${result.stdout}');
        logger.i('Process stderr: ${result.stderr}');
      } else if (Platform.isMacOS) {
        // On macOS, use open
        await Process.run('open', [cleanPath]);
      } else if (Platform.isLinux) {
        // On Linux, use xdg-open
        await Process.run('xdg-open', [cleanPath]);
      } else {
        logger.e('Unsupported platform for opening folders');
      }
    } catch (e) {
      logger.e('Error opening folder: $e');
    }
  }
}
