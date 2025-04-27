import 'package:code_g/app/core/services/files_services.dart';
import 'package:code_g/app/core/services/json_services.dart';
import 'package:code_g/app/core/services/shared_service.dart';
import 'package:code_g/app/core/services/project_service.dart';
import 'package:code_g/app/core/services/form_validation_service.dart';
import 'package:code_g/app/core/services/file_selection_service.dart';
import 'package:code_g/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:convert';

class CreateProjectController extends GetxController {
  final Logger logger = Logger();
  final SharedService sharedService = SharedService();
  final ProjectService projectService = ProjectService();
  final FormValidationService formValidationService = FormValidationService();
  final FileSelectionService fileSelectionService = FileSelectionService();
  final JsonServices jsonServices = JsonServices();

  final pieceRef = TextEditingController();
  final pieceIndice = TextEditingController();
  final machine = TextEditingController();
  final pieceDiametre = TextEditingController();
  final pieceEjection = TextEditingController();
  final pieceName = TextEditingController();
  final epaisseur = TextEditingController();
  final materiel = TextEditingController();
  final form = TextEditingController();
  final programmeur = TextEditingController();
  final regieur = TextEditingController();
  final specification = TextEditingController();
  final organeBP = TextEditingController();
  final organeCB = TextEditingController();
  final selectedItemsController = TextEditingController();
  final caoFilePath = TextEditingController();
  final faoFilePath = TextEditingController();
  final fileZPath = TextEditingController();
  final planFilePath = TextEditingController();
  final topSolideOperation = TextEditingController();
  final operationName = TextEditingController();
  final displayOperation = TextEditingController();
  final arrosageType = TextEditingController();

  final RxString caoStatus = "pending".obs;
  final RxString faoStatus = "pending".obs;
  final RxString fileZStatus = "pending".obs;
  final RxList fileZJsonData = [].obs;
  final RxString planStatus = "pending".obs;
  final RxList<Map<String, dynamic>> selectedOperations =
      <Map<String, dynamic>>[].obs;

  // Current operation index - moved from view
  final RxInt currentOperationIndex = 0.obs;

  final Map<String, dynamic> _jsonCache = {};

  bool checkFilledFields(Map<String, TextEditingController> fields) {
    bool isAllFieldsFilled = true;
    fields.forEach((name, controller) {
      if (controller.text.isEmpty) {
        logger.d("Missing field: $name");
        isAllFieldsFilled = false;
      }
    });
    return isAllFieldsFilled;
  }

  bool areFirstPartFieldsFilled() {
    final fields = {
      'Piece Reference': pieceRef,
      'Piece Indice': pieceIndice,
      'Machine': machine,
      'Piece Diametre': pieceDiametre,
      'Piece Ejection': pieceEjection,
      'Piece Name': pieceName,
      'Epaisseur': epaisseur,
      'Materiel': materiel,
      'Form': form,
      'Programmeur': programmeur,
      'Regieur': regieur,
      'Specification': specification,
      'Organe BP': organeBP,
      'Organe CB': organeCB,
      'Selected Items': selectedItemsController,
      'CAO File Path': caoFilePath,
      'FAO File Path': faoFilePath,
      'File Z Path': fileZPath,
      'Plan File Path': planFilePath,
    };
    return formValidationService.checkFilledFields(fields);
  }

  Map<String, String> sideBarInfo() {
    return formValidationService.getSideBarInfo(
      pieceRef: pieceRef.text,
      pieceIndice: pieceIndice.text,
      machine: machine.text,
      materiel: materiel.text,
      pieceDiametre: pieceDiametre.text,
      pieceEjection: pieceEjection.text,
      selectedItems: selectedItemsController.text,
      epaisseur: epaisseur.text,
      programmeur: programmeur.text,
      regieur: regieur.text,
      pieceName: pieceName.text,
      organeBP: organeBP.text,
      organeCB: organeCB.text,
    );
  }

  bool areSecandPartFieldsFilled() {
    final fields = {
      'Top Solide Operation': topSolideOperation,
      'Operation Name': operationName,
      'Display Operation': displayOperation,
      'Arrosage Type': arrosageType,
    };
    return formValidationService.checkFilledFields(fields);
  }

  @override
  void onInit() {
    super.onInit();
    _preloadCommonJsonData();
  }

  void _preloadCommonJsonData() async {
    try {
      await extractMachineJsonData();
      await extractMechoireJsonData();
      await extractIndicesJsonData();
      await extractProgrammersJsonData();
    } catch (e) {
      logger.e('Error preloading JSON data: $e');
    }
  }

  void handleReset(String fieldName) {
    switch (fieldName) {
      case 'machine':
        machine.clear();
        break;
      case 'pieceIndice':
        pieceIndice.clear();
        break;
      case 'pieceEjection':
        pieceEjection.clear();
        break;
      case 'programmeur':
        programmeur.clear();
        break;
      case 'topSolideOperation':
        topSolideOperation.clear();
        break;
      case 'arrosageType':
        arrosageType.clear();
        break;
      default:
        logger.w('Unknown field name for reset: $fieldName');
    }
    update();
  }

  Future<List<dynamic>> extractIndicesJsonData() async {
    const cacheKey = 'indiceJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final List<dynamic> fetchedJsonData =
          await projectService.extractIndicesJsonData();
      var newData = fetchedJsonData;
      _jsonCache[cacheKey] = newData;

      return newData;
    } catch (e) {
      logger.e('Error extracting indices JSON data: $e');
      return [];
    }
  }

  Future<List<dynamic>> extractMachineJsonData() async {
    const cacheKey = 'machineJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final List<dynamic> fetchedJsonData =
          await projectService.extractMachineJsonData();
      var newData = fetchedJsonData;

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

  Future<List<dynamic>> extractMechoireJsonData() async {
    const cacheKey = 'mechoireJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final List<dynamic> fetchedJsonData =
          await projectService.extractMechoireJsonData();
      var newData = fetchedJsonData;

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

  Future<List<dynamic>> extractProgrammersJsonData() async {
    const cacheKey = 'programmersJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final List<dynamic> fetchedJsonData =
          await projectService.extractProgrammersJsonData();
      var newData = fetchedJsonData;

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

  Future<List<dynamic>> extractArrosageTypesJsonData() async {
    const cacheKey = 'arrosageTypesJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final List<dynamic> fetchedJsonData =
          await projectService.extractArrosageTypesJsonData();
      var newData = fetchedJsonData;

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

  Future<List<dynamic>> extractTopSolideOperationsJsonData() async {
    const cacheKey = 'topSolideOperationsJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final List<dynamic> fetchedJsonData =
          await projectService.extractTopSolideOperationsJsonData();
      var newData = fetchedJsonData;

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

  Future<List<dynamic>> extractOperationsData() async {
    try {
      if (fileZJsonData.isEmpty) {
        return [];
      }
      return sharedService.extractAllOperations(fileZJsonData, "operation");
    } catch (e) {
      logger.e('Error extracting operations data: $e');
      return [];
    }
  }

  void updateDisplayOperation(String value) {
    try {
      final String operationToUse =
          value.isNotEmpty ? value : operationName.text;
      if (operationToUse.isEmpty || fileZJsonData.isEmpty) {
        return;
      }

      // Fields are already cleared before this method is called

      // First get description from fileZJsonData
      final data = fileZJsonData
          .where((element) => element["operation"] == operationToUse)
          .toList();

      if (data.isNotEmpty && data[0].containsKey("description")) {
        displayOperation.text = data[0]["description"];

        // Check if this operation already has saved data in selectedOperations
        int operationIndex = -1;
        for (int i = 0; i < selectedOperations.length; i++) {
          if (selectedOperations[i]['operation'] == operationToUse) {
            operationIndex = i;
            break;
          }
        }

        // If we found saved data for this operation, load it
        if (operationIndex >= 0) {
          Map<String, dynamic> savedData = selectedOperations[operationIndex];
          bool hasSavedFields = false;

          // Only update the fields that should be loaded from saved data
          // Keep the operation name as selected by user
          displayOperation.text =
              savedData['displayOperation'] ?? data[0]["description"];

          // Only fill these if they exist in saved data
          if (savedData['topSolideOperation'] != null &&
              savedData['topSolideOperation'].toString().isNotEmpty) {
            topSolideOperation.text = savedData['topSolideOperation'];
            hasSavedFields = true;
          }

          if (savedData['arrosageType'] != null &&
              savedData['arrosageType'].toString().isNotEmpty) {
            arrosageType.text = savedData['arrosageType'];
            hasSavedFields = true;
          }

          if (hasSavedFields) {
            // Display a message that saved data was loaded if using Get
            Get.snackbar(
              'Saved Data Loaded',
              'Previously saved data loaded for operation: $operationToUse',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: Duration(seconds: 2),
            );
          }

          logger.i("Loaded saved data for operation: $operationToUse");
        } else {
          // No saved data found for this operation
          Get.snackbar(
            'New Operation',
            'No saved data for this operation. Please fill in the details.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        }
      } else {
        logger.i("No matching operation found or missing description");
      }
    } catch (e) {
      logger.e("Error updating display operation: $e");
    }
  }

  void addOrUpdateOperation(int index, String operation,
      String displayOperation, String topSolideOperation, String arrosageType) {
    while (selectedOperations.length <= index) {
      selectedOperations.add({});
    }

    selectedOperations[index] = {
      'operation': operation,
      'displayOperation': displayOperation,
      'topSolideOperation': topSolideOperation,
      'arrosageType': arrosageType,
    };

    if (index == 0) {
      this.operationName.text = operation;
      this.displayOperation.text = displayOperation;
      this.topSolideOperation.text = topSolideOperation;
      this.arrosageType.text = arrosageType;
    }

    update();
  }

  // A silent version that doesn't call update() - useful during initialization
  void addOrUpdateOperationSilently(int index, String operation,
      String displayOperation, String topSolideOperation, String arrosageType) {
    while (selectedOperations.length <= index) {
      selectedOperations.add({});
    }

    selectedOperations[index] = {
      'operation': operation,
      'displayOperation': displayOperation,
      'topSolideOperation': topSolideOperation,
      'arrosageType': arrosageType,
    };

    if (index == 0) {
      this.operationName.text = operation;
      this.displayOperation.text = displayOperation;
      this.topSolideOperation.text = topSolideOperation;
      this.arrosageType.text = arrosageType;
    }
  }

  bool areAllOperationsFilled() {
    if (selectedOperations.isEmpty) {
      return areSecandPartFieldsFilled();
    }

    for (var operation in selectedOperations) {
      if (operation['operation']?.isEmpty ??
          true || operation['topSolideOperation']?.isEmpty ??
          true || operation['arrosageType']?.isEmpty ??
          true) {
        return false;
      }
    }

    return true;
  }

  String _borderColor(TextEditingController controllerName) {
    final emptyFolder = caoFilePath.text.isEmpty;
    final emptyController = controllerName.text.isEmpty;

    if (emptyFolder || emptyController) {
      return "error";
    } else if (!emptyFolder && !emptyController) {
      return "success";
    }
    return "pending";
  }

  void selectFile(Map<String, List<String>>? selectedFile,
      TextEditingController controller) {
    fileSelectionService.selectFile(selectedFile, controller);
    update();
  }

  void selectFao(Map<String, List<String>>? selectedFile) {
    fileSelectionService.selectFao(
        selectedFile, faoFilePath, (status) => faoStatus.value = status);
    update();
  }

  void selectPlan(Map<String, List<String>>? selectedFile) {
    fileSelectionService.selectPlan(
        selectedFile, planFilePath, (status) => planStatus.value = status);
    update();
  }

  void selectFileZ(Map<String, List<String>>? selectedFile) async {
    Map<String, dynamic> result = await fileSelectionService.selectFileZ(
        selectedFile, fileZPath, (status) => fileZStatus.value = status);

    if (result.isNotEmpty) {
      processFileZResult(result);
    }

    update();
  }

  void processFileZResult(Map<String, dynamic> structuredJson) {
    if (structuredJson.containsKey("entries")) {
      fileZJsonData.value = List<dynamic>.from(structuredJson["entries"]);
    }

    if (structuredJson.containsKey("fileName")) {
      machine.text =
          structuredJson["fileName"].contains("R200") ? "R200" : "G160";
    }

    update();
  }

  void selectFilesFromFolder(Map<String, List<String>>? selectedFolderFiles) {
    fileSelectionService.selectFilesFromFolder(
        selectedFolderFiles,
        caoFilePath,
        faoFilePath,
        fileZPath,
        planFilePath,
        (status) => caoStatus.value = status,
        (status) => faoStatus.value = status,
        (status) => fileZStatus.value = status,
        (status) => planStatus.value = status,
        processFileZResult);
    update();
  }

  void copySelectedFolder() {
    if (caoFilePath.text.isEmpty) {
      logger.w("No CAO file path selected");
      return;
    }

    try {
      Map<String, dynamic> projectData =
          formValidationService.prepareProjectData(
        pieceRef: pieceRef.text,
        pieceIndice: pieceIndice.text,
        machine: machine.text,
        pieceDiametre: pieceDiametre.text,
        pieceEjection: pieceEjection.text,
        pieceName: pieceName.text,
        epaisseur: epaisseur.text,
        materiel: materiel.text,
        form: form.text,
        programmeur: programmeur.text,
        regieur: regieur.text,
        specification: specification.text,
        organeBP: organeBP.text,
        organeCB: organeCB.text,
        selectedItems: selectedItemsController.text,
        caoFilePath: caoFilePath.text,
        faoFilePath: faoFilePath.text,
        fileZPath: fileZPath.text,
        planFilePath: planFilePath.text,
        topSolideOperation: topSolideOperation.text,
        operationName: operationName.text,
        displayOperation: displayOperation.text,
        arrosageType: arrosageType.text,
        fileZStatus: fileZStatus.value,
        caoStatus: caoStatus.value,
        faoStatus: faoStatus.value,
        planStatus: planStatus.value,
      );

      if (selectedOperations.isNotEmpty) {
        projectData['operations'] = selectedOperations.toList();
      }

      projectService
          .copyProjectFolder(
        sourceFolder: caoFilePath.text,
        pieceRef: pieceRef.text,
        pieceIndice: pieceIndice.text,
        fileZPath: fileZPath.text,
        formPath: form.text,
        faoFilePath: faoFilePath.text,
        projectData: projectData,
      )
          .then((success) {
        if (success) {
          resetAllControllers();
        }
      });
    } catch (e) {
      logger.e("Error copying folder: $e");
    }
  }

  void resControllers(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      controller.clear();
    }
  }

  void resetFirstPartControllers() {
    final controllers = [
      pieceRef,
      pieceIndice,
      machine,
      pieceDiametre,
      pieceEjection,
      pieceName,
      epaisseur,
      materiel,
      form,
      programmeur,
      regieur,
      specification,
      organeBP,
      organeCB,
      selectedItemsController,
      caoFilePath,
      faoFilePath,
      fileZPath,
      planFilePath,
    ];
    resControllers(controllers);
    caoStatus.value = "pending";
    faoStatus.value = "pending";
    fileZStatus.value = "pending";
    planStatus.value = "pending";
  }

  void resetSecandPartControllers() {
    final controllers = [
      topSolideOperation,
      operationName,
      displayOperation,
      arrosageType,
    ];
    resControllers(controllers);
  }

  void resetAllControllers() {
    try {
      final homeController = Get.find<HomeController>();
      resetFirstPartControllers();
      resetSecandPartControllers();
      fileZJsonData.clear();
      homeController.activePage.value = "Ajouter une mouvelle pièce";
    } catch (e) {
      logger.e("Error resetting controllers: $e");
    }
  }

  bool containsArcFiles(Directory directory) {
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

  void removeJsonFileWithSameName(String filePath) {
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

  void removeThumbsDb(Directory directory) {
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

  void ensureFileInDirectory(String filePath, Directory destinationDir) {
    if (filePath.isEmpty) return;

    try {
      final file = File(filePath);
      final destinationFile =
          File(path.join(destinationDir.path, path.basename(file.path)));

      if (!destinationFile.existsSync()) {
        if (file.existsSync()) {
          file.copySync(destinationFile.path);
          logger.i("Copied ${file.path} to ${destinationFile.path}");
          removeThumbsDb(destinationDir);
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

  bool checkForFicheZoller(Directory destinationDir) {
    try {
      final ficheZollerDir =
          Directory(path.join(destinationDir.path, 'Fiche Zoller'));
      return ficheZollerDir.existsSync();
    } catch (e) {
      logger.e("Error checking for Fiche Zoller: $e");
      return false;
    }
  }

  void saveProjectDataToJson(String filePath) {
    try {
      final projectData = {
        'pieceRef': pieceRef.text,
        'pieceIndice': pieceIndice.text,
        'machine': machine.text,
        'pieceDiametre': pieceDiametre.text,
        'pieceEjection': pieceEjection.text,
        'pieceName': pieceName.text,
        'epaisseur': epaisseur.text,
        'materiel': materiel.text,
        'form': form.text,
        'programmeur': programmeur.text,
        'regieur': regieur.text,
        'specification': specification.text,
        'organeBP': organeBP.text,
        'organeCB': organeCB.text,
        'selectedItems': selectedItemsController.text,
        'caoFilePath': caoFilePath.text,
        'faoFilePath': faoFilePath.text,
        'fileZPath': fileZPath.text,
        'planFilePath': planFilePath.text,
        'topSolideOperation': topSolideOperation.text,
        'operationName': operationName.text,
        'displayOperation': displayOperation.text,
        'arrosageType': arrosageType.text,
        'fileZStatus': fileZStatus.value,
        'caoStatus': caoStatus.value,
        'faoStatus': faoStatus.value,
        'planStatus': planStatus.value,
        'createdDate': DateTime.now().toIso8601String(),
      };

      final jsonString = jsonEncode(projectData);
      final file = File(filePath);
      file.writeAsStringSync(jsonString);

      logger.i("Project data saved to $filePath");
    } catch (e) {
      logger.e("Error saving project data to JSON: $e");
    }
  }

  // Add this method to jump to a specific operation index
  void goToOperation(int index) {
    // Check if index is valid
    if (index >= 0 && index < fileZJsonData.length) {
      // Update the current index
      currentOperationIndex.value = index;

      // Call update to notify GetBuilder
      update();

      // Show a message
      Get.snackbar(
        'Operation Changed',
        'Switched to operation ${index + 1}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 1),
      );
    }
  }

  // Add a method to find an operation by name and go to it
  void findAndGoToOperation(String operationName) {
    // Find the operation index by name
    for (int i = 0; i < fileZJsonData.length; i++) {
      if (fileZJsonData[i]["operation"] == operationName) {
        goToOperation(i);
        return;
      }
    }

    // Operation not found
    Get.snackbar(
      'Operation Not Found',
      'Could not find operation: $operationName',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
