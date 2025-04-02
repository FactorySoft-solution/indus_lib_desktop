import 'package:code_g/app/core/services/files_services.dart';
import 'package:code_g/app/core/services/shared_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class CreateProjectController extends GetxController {
  final Logger logger = new Logger();
  final SharedService sharedService = SharedService();
  final FilesServices filesServices = new FilesServices();

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

  // Method to check if all TextEditingController fields are filled
  bool checkFilledFields(fields) {
    bool isAllFieldsFilled = true;
    fields.forEach((name, controller) {
      if (controller.text.isEmpty) {
        print("Missing field: $name");
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
  }

  Future<List<dynamic>> extractIndicesJsonData() async {
    try {
      final Map<String, dynamic> fetchedJsonData = await sharedService
          .loadJsonFromAssets('assets/json/indicePIECE.json');
      // indicePieceData.value = [...fetchedJsonData["contenu"]];
      var newData = [...fetchedJsonData["contenu"]];

      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
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
    try {
      var newData =
          sharedService.extractAllOperations(fileZJsonData.value, "operation");
      return newData;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  updateDisplayOperation(String value) {
    if (value.isEmpty) {
      final data = fileZJsonData
          .where((element) => element["operation"] == operationName.text)
          .toList();
      if (data.isNotEmpty) {
        // Access description from the filtered result
        final description = data[0]["description"];
        displayOperation.text = description;
      } else {
        logger.i("No matching operation found");
      }
    } else {
      final data = fileZJsonData
          .where((element) => element["operation"] == value)
          .toList();
      if (data.isNotEmpty) {
        // Access description from the filtered result
        final description = data[0]["description"];
        displayOperation.text = description;
      } else {
        logger.i("No matching operation found");
      }
    }
  }

  String _borderColor(controllerName) {
    final emptyFolder = caoFilePath.text.isEmpty;
    final emptyController = controllerName.text.isEmpty;
    var status = "pending";
    if (emptyFolder || emptyController) {
      status = "error";
    } else if (!emptyFolder && !emptyController) {
      status = "success";
    }
    return status;
  }

  void selectFile(selectedFile, controller) {
    if (selectedFile != null) {
      if (selectedFile.containsKey("file")) {
        String filePath = selectedFile["file"]!.first;
        controller.text = filePath;
      } else if (selectedFile.containsKey("files")) {
        List<String> filePaths = selectedFile["files"]!;
        controller.text = filePaths.first; // Example: Take the first file
        update();
      }
    }
  }

  void selectFao(selectedFile) {
    String filePath = selectedFile["file"]!.first;
    String fileName = filePath.split('/').last;
    if ((fileName.endsWith('.arc') || fileName.endsWith('.ARC')) &&
        !fileName.toLowerCase().contains('pince')) {
      selectFile(selectedFile, faoFilePath);
      faoStatus.value = _borderColor(faoFilePath);
      update();
    } else {
      // Show an error message or handle the invalid file case
      print("Invalid file: File must end with '.arc' and not contain 'pince'.");
    }
  }

  void selectPlan(selectedFile) {
    String filePath = selectedFile["file"]!.first;
    String fileName = filePath.split('/').last;
    if (fileName.toLowerCase().contains("ind") &&
        fileName.toLowerCase().endsWith('.pdf')) {
      selectFile(selectedFile, planFilePath);
      planStatus.value = _borderColor(planFilePath);
      update();
    } else {
      // Show an error message or handle the invalid file case
      print("Invalid file: File must be pdf and contain 'IND'.");
    }
  }

  void selectFileZ(selectedFile) async {
    String filePath = selectedFile["file"]!.first;

    String fileName = filePath.split('\\').last;
    bool isFileZ = fileName.toLowerCase().contains('fiche z');
    bool isPdf = fileName.toLowerCase().endsWith('.pdf');
    if (isFileZ && isPdf) {
      selectFile(selectedFile, fileZPath);
      fileZStatus.value = _borderColor(fileZPath);
      update();
      downloadFileZ(filePath);
    } else {
      print("Invalid file: File must be pdf and contain 'fiche z'.");
    }
  }

  void selectFilesFromFolder(Map<String, List<String>>? selectedFolderFiles) {
    if (selectedFolderFiles != null) {
      // Save the root folder path (first directory in the list)
      if (selectedFolderFiles.containsKey("mainDir")) {
        var mainDir = selectedFolderFiles['mainDir']![0];
        if (FileSystemEntity.isDirectorySync(mainDir)) {
          caoFilePath.text = mainDir;
          caoStatus.value = _borderColor(planFilePath);
          update();
        }
      }
      if (selectedFolderFiles.containsKey("arc")) {
        var arcData = selectedFolderFiles['arc'];
        if (arcData is List) {
          // Ensure it's a List before iterating
          List<String> arc = List<String>.from(arcData!);
          for (var file in arc) {
            selectFao({
              "file": [file]
            });
          }
          update();
        } else {
          print("Error: 'arc' is not a list!");
        }
      }

      if (selectedFolderFiles.containsKey("pdf")) {
        var pdfData = selectedFolderFiles['pdf'];
        if (pdfData is List) {
          List<String> pdf = List<String>.from(pdfData!);
          for (var file in pdf) {
            selectFileZ({
              "file": [file]
            });
            selectPlan({
              "file": [file]
            });
          }
        } else {
          print("Error: 'pdf' is not a list!");
        }
      }
      // Iterate through all files in the folder
      if (selectedFolderFiles.containsKey("dir")) {
        var dirData = selectedFolderFiles['dir'];
        if (dirData is List) {
          List<String> dir = List<String>.from(dirData!);
          for (var file in dir) {
            if (FileSystemEntity.isDirectorySync(file)) {
              // Call selectFilesFromFolder recursively for subfolders
              var listGroup = filesServices.regroupDirectoryFilesByType(file);
              selectFilesFromFolder(listGroup);
            }
          }
        } else {
          print("Error: 'pdf' is not a list!");
        }
      }
    }
  }

  void downloadFileZ(filePath) async {
    String fileName = filePath.split('\\').last;
    String directory = path.dirname(filePath);
    Map<String, dynamic> structuredJson =
        await filesServices.convertFileZHtmlToJson(filePath);
    fileZJsonData.value = List<dynamic>.from(structuredJson["entries"]);

    await filesServices.saveContentToFile(
        structuredJson, directory, fileName.split(".")[0], "json");
  }

  // Method to copy the selected folder to a new location
  void copySelectedFolder() {
    if (caoFilePath.text.isNotEmpty) {
      String userProfile = Platform.environment['USERPROFILE'] ??
          '\\home\\${Platform.environment['USER']}';
      String defaultDesktopPath = "$userProfile\\Desktop\\aerobase";
      String subPath = "${pieceRef.text}\\${pieceIndice.text}\\copied_folder";
      final sourceDir = Directory(caoFilePath.text);

      final destinationDir = Directory(path.join(defaultDesktopPath, subPath));
      if (sourceDir.existsSync()) {
        try {
          destinationDir.createSync(recursive: true);
          filesServices.copyDirectory(sourceDir, destinationDir);
          logger.i("All fields are filled. Files copied successfully.");

          // Check for "Fiche Zoller" folder
          final ficheZollerDir =
              Directory(path.join(destinationDir.path, 'Fiche Zoller'));
          if (!ficheZollerDir.existsSync()) {
            ficheZollerDir.createSync(recursive: true);
            logger.i("Fiche Zoller folder created.");
          }

          // Ensure fileZPath and form are copied into "Fiche Zoller"
          ensureFileInDirectory(fileZPath.text, ficheZollerDir);
          ensureFileInDirectory(form.text, ficheZollerDir);

          // Remove Thumbs.db if it exists
          removeThumbsDb(destinationDir);

          // Remove JSON file with the same name if it exists
          filesServices.copyDirectory(sourceDir, ficheZollerDir);
          removeJsonFileWithSameName(fileZPath.text);

          // Check for .arc or .ARC files in the destination directory
          if (!containsArcFiles(destinationDir)) {
            // Copy faoFilePath into the destination directory if no .arc or .ARC files are found
            ensureFileInDirectory(faoFilePath.text, destinationDir);
          }

          // Reset all controllers on success
          resetAllControllers();
        } catch (e) {
          logger.e("Error copying files: $e");
        }
      } else {
        logger.e("Source directory does not exist.");
      }
    }
  }

  void resControllers(controllers) {
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
    resetFirstPartControllers();
    resetSecandPartControllers();
  }

  bool containsArcFiles(Directory directory) {
    final arcFiles = directory.listSync().where((entity) {
      if (entity is File) {
        final extension = path.extension(entity.path).toLowerCase();
        return extension == '.arc';
      }
      return false;
    }).toList();
    return arcFiles.isNotEmpty;
  }

  void removeJsonFileWithSameName(String filePath) {
    final fileNameWithoutExtension = path.basenameWithoutExtension(filePath);
    final directory = path.dirname(filePath);
    final jsonFile =
        File(path.join(directory, '$fileNameWithoutExtension.json'));
    if (jsonFile.existsSync()) {
      jsonFile.deleteSync();
      logger.i("Removed JSON file: ${jsonFile.path}");
    }
  }

  void removeThumbsDb(Directory directory) {
    final thumbsDbFile = File(path.join(directory.path, 'Thumbs.db'));
    if (thumbsDbFile.existsSync()) {
      thumbsDbFile.deleteSync();
      logger.i("Thumbs.db file removed from ${directory.path}");
    }
  }

  void ensureFileInDirectory(String filePath, Directory destinationDir) {
    final file = File(filePath);
    final destinationFile =
        File(path.join(destinationDir.path, path.basename(file.path)));
    print("destinationFile: ${destinationFile.existsSync()}");
    if (!destinationFile.existsSync()) {
      if (file.existsSync()) {
        file.copySync(destinationFile.path);
        logger.i("Copied ${file.path} to ${destinationFile.path}");
        // Remove Thumbs.db if it exists
        removeThumbsDb(destinationDir);
      } else {
        logger.w("Source file ${file.path} does not exist.");
      }
    } else {
      logger
          .i("File ${destinationFile.path} already exists in the destination.");
    }
  }

  bool checkForFicheZoller(Directory destinationDir) {
    final ficheZollerDir =
        Directory(path.join(destinationDir.path, 'Fiche Zoller'));
    return ficheZollerDir.existsSync();
  }
}
