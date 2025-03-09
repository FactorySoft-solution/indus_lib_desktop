import 'dart:convert';

import 'package:code_g/app/core/services/files_services.dart';
import 'package:code_g/app/core/services/shared_service.dart';
// import 'package:file_picker/file_picker.dart';
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

// void _handleFolderPicked(Map<String, List<String>>? filesByType) {
//   if (filesByType != null) {
//     // caoFilePath.text = selectedFile
//     print("Files grouped by type received in parent:");
//     filesByType.forEach((extension, files) {
//       print("Files with extension .$extension:");
//       for (var file in files) {
//         print(" - $file");
//       }
//     });
//   } else {
//     print("Folder picker was canceled.");
//   }
// }

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
}
