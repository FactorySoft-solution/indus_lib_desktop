import 'package:code_g/app/core/services/files_services.dart';
import 'package:code_g/app/core/services/json_services.dart';
import 'package:code_g/app/core/services/shared_service.dart';
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
  final JsonServices jsonServices = JsonServices();
  final FilesServices filesServices = FilesServices();

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
    return checkFilledFields(fields);
  }

  Map<String, String> sideBarInfo() {
    final fields = {
      'Pièce ref º': pieceRef.text,
      'Indice ref º': pieceIndice.text,
      'Machine': machine.text,
      'Matière': materiel.text,
      'Ø Brute': pieceDiametre.text,
      'Type Mâchoire éjection': pieceEjection.text,
      'Tirage': selectedItemsController.text.contains("Tirage").toString(),
      'Cimblot': selectedItemsController.text.contains("Cimblot").toString(),
      'Manchon': selectedItemsController.text.contains("Manchon").toString(),
      'Epaisseur Pièce': epaisseur.text,
      'Programmeur': programmeur.text,
      'Régleur Machine': regieur.text,
      'Piece Name': pieceName.text,
      'Organe BP': organeBP.text,
      'Organe CB': organeCB.text,
    };
    return fields;
  }

  bool areSecandPartFieldsFilled() {
    final fields = {
      'Top Solide Operation': topSolideOperation,
      'Operation Name': operationName,
      'Display Operation': displayOperation,
      'Arrosage Type': arrosageType,
    };
    return checkFilledFields(fields);
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

  Future<List<dynamic>> extractMachineJsonData() async {
    const cacheKey = 'machineJsonData';
    try {
      if (_jsonCache.containsKey(cacheKey)) {
        return _jsonCache[cacheKey];
      }

      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadMachineJson();
      var newData = [...fetchedJsonData["contenu"][0]["machines"]];

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

      final Map<String, dynamic> fetchedJsonData = await jsonServices
          .loadJsonFromAssets('assets/json/machoireEJECTION.json');
      var newData = [...fetchedJsonData["contenu"][0]["types"]];

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

      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadProgrammerJson();
      var newData = [...fetchedJsonData["contenu"]];

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

      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadArrosageJson();
      var newData = [...fetchedJsonData["contenu"]];

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

      final Map<String, dynamic> fetchedJsonData =
          await jsonServices.loadTopSolideJson();
      var newData = [...fetchedJsonData["contenu"]];

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

      final data = fileZJsonData
          .where((element) => element["operation"] == operationToUse)
          .toList();

      if (data.isNotEmpty && data[0].containsKey("description")) {
        displayOperation.text = data[0]["description"];
      } else {
        logger.i("No matching operation found or missing description");
      }
    } catch (e) {
      logger.e("Error updating display operation: $e");
    }
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

  void selectFile(Map<String, List<String>> selectedFile,
      TextEditingController controller) {
    if (selectedFile == null) return;

    try {
      if (selectedFile.containsKey("file")) {
        String filePath = selectedFile["file"]!.first;
        controller.text = filePath;
      } else if (selectedFile.containsKey("files") &&
          selectedFile["files"]!.isNotEmpty) {
        controller.text = selectedFile["files"]!.first;
      }
      update();
    } catch (e) {
      logger.e("Error selecting file: $e");
    }
  }

  void selectFao(Map<String, List<String>> selectedFile) {
    if (selectedFile == null ||
        !selectedFile.containsKey("file") ||
        selectedFile["file"]!.isEmpty) {
      return;
    }

    try {
      String filePath = selectedFile["file"]!.first;
      String fileName = path.basename(filePath);

      if ((fileName.toLowerCase().endsWith('.arc')) &&
          !fileName.toLowerCase().contains('pince')) {
        selectFile(selectedFile, faoFilePath);
        faoStatus.value = _borderColor(faoFilePath);
        update();
      } else {
        logger.w(
            "Invalid file: File must end with '.arc' and not contain 'pince'.");
      }
    } catch (e) {
      logger.e("Error selecting FAO file: $e");
    }
  }

  void selectPlan(Map<String, List<String>> selectedFile) {
    if (selectedFile == null ||
        !selectedFile.containsKey("file") ||
        selectedFile["file"]!.isEmpty) {
      return;
    }

    try {
      String filePath = selectedFile["file"]!.first;
      String fileName = path.basename(filePath);

      if (fileName.toLowerCase().contains("ind") &&
          fileName.toLowerCase().endsWith('.pdf')) {
        selectFile(selectedFile, planFilePath);
        planStatus.value = _borderColor(planFilePath);
        update();
      } else {
        logger.w("Invalid file: File must be PDF and contain 'IND'.");
      }
    } catch (e) {
      logger.e("Error selecting plan file: $e");
    }
  }

  void selectFileZ(Map<String, List<String>> selectedFile) async {
    if (selectedFile == null ||
        !selectedFile.containsKey("file") ||
        selectedFile["file"]!.isEmpty) {
      return;
    }

    try {
      String filePath = selectedFile["file"]!.first;
      String fileName = path.basename(filePath);
      bool isFileZ = fileName.toLowerCase().contains('fiche z');
      bool isPdf = fileName.toLowerCase().endsWith('.pdf');

      if (isFileZ && isPdf) {
        fileZPath.text = filePath;
        fileZStatus.value = _borderColor(fileZPath);
        update();
        await downloadFileZ(filePath);
      } else {
        logger.w("Invalid file: File must be PDF and contain 'fiche z'.");
      }
    } catch (e) {
      logger.e("Error selecting file Z: $e");
    }
  }

  void selectFilesFromFolder(Map<String, List<String>>? selectedFolderFiles) {
    if (selectedFolderFiles == null) return;

    try {
      if (selectedFolderFiles.containsKey("mainDir") &&
          selectedFolderFiles['mainDir']!.isNotEmpty) {
        var mainDir = selectedFolderFiles['mainDir']![0];
        if (FileSystemEntity.isDirectorySync(mainDir)) {
          caoFilePath.text = mainDir;
          caoStatus.value = _borderColor(caoFilePath);
          update();
        }
      }

      if (selectedFolderFiles.containsKey("arc")) {
        List<String> arcFiles =
            List<String>.from(selectedFolderFiles['arc'] ?? []);
        for (var file in arcFiles) {
          selectFao({
            "file": [file]
          });
        }
      }

      if (selectedFolderFiles.containsKey("pdf")) {
        List<String> pdfFiles =
            List<String>.from(selectedFolderFiles['pdf'] ?? []);
        for (var file in pdfFiles) {
          selectFileZ({
            "file": [file]
          });
          selectPlan({
            "file": [file]
          });
        }
      }

      if (selectedFolderFiles.containsKey("dir")) {
        List<String> directories =
            List<String>.from(selectedFolderFiles['dir'] ?? []);
        for (var dir in directories) {
          if (FileSystemEntity.isDirectorySync(dir)) {
            var listGroup = filesServices.regroupDirectoryFilesByType(dir);
            selectFilesFromFolder(listGroup);
          }
        }
      }
    } catch (e) {
      logger.e("Error selecting files from folder: $e");
    }
  }

  Future<void> downloadFileZ(String filePath) async {
    try {
      String fileName = path.basename(filePath);
      String directory = path.dirname(filePath);

      Map<String, dynamic> structuredJson =
          await filesServices.convertFileZHtmlToJson(filePath);

      if (structuredJson.containsKey("entries")) {
        fileZJsonData.value = List<dynamic>.from(structuredJson["entries"]);
      }

      if (structuredJson.containsKey("fileName")) {
        machine.text =
            structuredJson["fileName"].contains("R200") ? "R200" : "G160";
      }

      update();

      await filesServices.saveContentToFile(
          structuredJson, directory, fileName.split(".")[0], "json");
    } catch (e) {
      logger.e("Error downloading file Z: $e");
    }
  }

  void copySelectedFolder() {
    if (caoFilePath.text.isEmpty) {
      logger.w("No CAO file path selected");
      return;
    }

    try {
      String userProfile = Platform.environment['USERPROFILE'] ??
          '\\home\\${Platform.environment['USER']}';
      String defaultDesktopPath = "$userProfile\\Desktop\\aerobase";
      String subPath = "${pieceRef.text}\\${pieceIndice.text}\\copied_folder";
      final sourceDir = Directory(caoFilePath.text);
      final destinationDir = Directory(path.join(defaultDesktopPath, subPath));

      if (!sourceDir.existsSync()) {
        logger.e("Source directory does not exist.");
        return;
      }

      destinationDir.createSync(recursive: true);
      filesServices.copyDirectory(sourceDir, destinationDir);
      logger.i("Files copied successfully.");

      final ficheZollerDir =
          Directory(path.join(destinationDir.path, 'Fiche Zoller'));
      if (!ficheZollerDir.existsSync()) {
        ficheZollerDir.createSync(recursive: true);
        logger.i("Fiche Zoller folder created.");
      }

      ensureFileInDirectory(fileZPath.text, ficheZollerDir);
      ensureFileInDirectory(form.text, ficheZollerDir);

      removeThumbsDb(destinationDir);
      removeJsonFileWithSameName(fileZPath.text);

      if (!containsArcFiles(destinationDir)) {
        ensureFileInDirectory(faoFilePath.text, destinationDir);
      }

      saveProjectDataToJson(
          path.join(destinationDir.parent.path, 'project.json'));

      resetAllControllers();
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
}
