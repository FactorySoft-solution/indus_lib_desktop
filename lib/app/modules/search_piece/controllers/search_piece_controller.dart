import 'package:code_g/app/core/services/files_services.dart';
import 'package:code_g/app/core/services/shared_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class SearchPieceController extends GetxController {
  final Logger logger = new Logger();
  final SharedService sharedService = SharedService();
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
  final selectedItemsController = TextEditingController();

  final machineController = TextEditingController();
  final pieceDiametreController = TextEditingController();
  final formController = TextEditingController();
  final epaisseurController = TextEditingController();
  final operationNameController = TextEditingController();
  final topSolideOperationController = TextEditingController();
  final materielController = TextEditingController();
  final specificationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
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
      final Map<String, dynamic> fetchedJsonData = await sharedService
          .loadJsonFromAssets('assets/json/listeMACHINE.json');
      var newData = [...fetchedJsonData["contenu"][0]["machines"]];
      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> extractMechoireJsonData() async {
    try {
      final Map<String, dynamic> fetchedJsonData = await sharedService
          .loadJsonFromAssets('assets/json/machoireEJECTION.json');
      var newData = [...fetchedJsonData["contenu"][0]["types"]];
      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> extractProgrammersJsonData() async {
    try {
      final Map<String, dynamic> fetchedJsonData = await sharedService
          .loadJsonFromAssets('assets/json/listePROGRAMMEUR.json');
      var newData = [...fetchedJsonData["contenu"]];
      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> extractArrosageTypesJsonData() async {
    try {
      final Map<String, dynamic> fetchedJsonData = await sharedService
          .loadJsonFromAssets('assets/json/arrosage_type.json');

      var newData = [...fetchedJsonData["contenu"]];
      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> extractTopSolideOperationsJsonData() async {
    try {
      final Map<String, dynamic> fetchedJsonData = await sharedService
          .loadJsonFromAssets('assets/json/topSolide_operations.json');
      var newData = [...fetchedJsonData["contenu"]];
      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> extractOperationsData() async {
    // try {
    //   var newData =
    //       sharedService.extractAllOperations(fileZJsonData.value, "operation");
    //   return newData;
    // } catch (e) {
    //   print('Error: $e');
    //   return [];
    // }
    return [];
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
                // Look for project data in the copied_folder
                final copiedFolder =
                    Directory(path.join(pieceIndexDir.path, 'copied_folder'));
                if (await copiedFolder.exists()) {
                  // Create base project data from directory structure
                  final projectData = {
                    'projectPath': pieceIndexDir.path,
                    'pieceRef': path.basename(pieceRefDir.path),
                    'pieceIndice': path.basename(pieceIndexDir.path),
                    'copiedFolderPath': copiedFolder.path,
                    'machine': machine.value,
                    'pieceDiametre': '',
                    'form': '',
                    'epaisseur': '',
                    'operationName': '',
                    'topSolideOperation': '',
                    'materiel': '',
                    'specification': '',
                    'ficheZollerContent': '',
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
      // Machine search - compare machine search term with Fiche Zoller filename
      if (machine.value.isNotEmpty) {
        // Get the Fiche Zoller filename if available
        final ficheZollerFilename =
            projectData['ficheZollerFilename']?.toString().toLowerCase() ?? '';

        // If the Fiche Zoller file exists but doesn't contain the machine name, exclude this project
        if (ficheZollerFilename.isNotEmpty &&
            !ficheZollerFilename.contains(machine.value.toLowerCase())) {
          return false;
        }
      }
      print('Project data : $projectData');
      // Piece Index search
      if (pieceDiametre.value.isNotEmpty) {
        final projectPieceIndex =
            projectData['pieceIndice']?.toString().toLowerCase() ?? '';
        if (!projectPieceIndex.contains(pieceDiametre.value.toLowerCase())) {
          return false;
        }
      }

      // // Form search
      // if (form.value.isNotEmpty) {
      //   final projectForm = projectData['form']?.toString().toLowerCase() ?? '';
      //   if (!projectForm.contains(form.value.toLowerCase())) {
      //     return false;
      //   }
      // }

      // // Thickness search
      // if (epaisseur.value.isNotEmpty) {
      //   final projectEpaisseur =
      //       projectData['epaisseur']?.toString().toLowerCase() ?? '';
      //   if (!projectEpaisseur.contains(epaisseur.value.toLowerCase())) {
      //     return false;
      //   }
      // }

      // // Operation name search
      // if (operationName.value.isNotEmpty) {
      //   final projectOperation =
      //       projectData['operationName']?.toString().toLowerCase() ?? '';
      //   if (!projectOperation.contains(operationName.value.toLowerCase())) {
      //     return false;
      //   }
      // }

      // // TopSolid operation search
      // if (topSolideOperation.value.isNotEmpty) {
      //   final projectTopSolide =
      //       projectData['topSolideOperation']?.toString().toLowerCase() ?? '';
      //   if (!projectTopSolide
      //       .contains(topSolideOperation.value.toLowerCase())) {
      //     return false;
      //   }
      // }

      // // Material search
      // if (materiel.value.isNotEmpty) {
      //   final projectMateriel =
      //       projectData['materiel']?.toString().toLowerCase() ?? '';
      //   if (!projectMateriel.contains(materiel.value.toLowerCase())) {
      //     return false;
      //   }
      // }

      // // Specification search
      // if (specification.value.isNotEmpty) {
      //   final projectSpec =
      //       projectData['specification']?.toString().toLowerCase() ?? '';
      //   if (!projectSpec.contains(specification.value.toLowerCase())) {
      //     return false;
      //   }
      // }

      return true;
    } catch (e) {
      logger.e('Error matching search criteria: $e');
      return false;
    }
  }

  // Method to update search field values from controllers
  void updateSearchFields() {
    machine.value = machineController.text;
    pieceDiametre.value = pieceDiametreController.text;
    form.value = formController.text;
    epaisseur.value = epaisseurController.text;
    operationName.value = operationNameController.text;
    topSolideOperation.value = topSolideOperationController.text;
    materiel.value = materielController.text;
    specification.value = specificationController.text;
  }

  // Method to perform search with current field values
  Future<void> performSearch() async {
    updateSearchFields();
    await searchProjects();
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
}
