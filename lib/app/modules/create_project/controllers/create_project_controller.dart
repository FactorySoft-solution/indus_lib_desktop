import 'package:code_g/app/core/services/shared_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class CreateProjectController extends GetxController {
  final SharedService sharedService = SharedService();

  var imagePlanPdf = Rxn<File>();
  var dossProgFolder = Rxn<String>();
  var programmeFile = Rxn<File>();
  var ficheUtilPdf = Rxn<File>();
  final pieceRef = TextEditingController();
  final pieceIndice = TextEditingController();
  final machine = TextEditingController();
  final pieceDiametre = TextEditingController();
  final pieceEjection = TextEditingController();
  final pieceName = TextEditingController();
  // var indicePieceData = <String>[].obs; // Observable list of strings
  var indicePieceData = <dynamic>[].obs; // Reactive list of strings

  @override
  void onInit() {
    super.onInit();
    // extractDate(); // Automatically load data on widget display
  }

  Future<void> pickFile(String type) async {
    FilePickerResult? result;
    if (type == 'pdf') {
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    } else if (type == 'folder') {
      result =
          await FilePicker.platform.getDirectoryPath() as FilePickerResult?;
    } else {
      result = await FilePicker.platform.pickFiles();
    }

    if (result != null) {
      switch (type) {
        case 'pdf':
          if (result.files.isNotEmpty) {
            imagePlanPdf.value = File(result.files.single.path!);
          }
          break;
        case 'folder':
          dossProgFolder.value = result.files.single.path!;
          break;
        default:
          programmeFile.value = File(result.files.single.path!);
      }
    }
  }

  Future<RxList<dynamic>> extractJsonDate(String fileName) async {
    try {
      final Map<String, dynamic> fetchedJsonData =
          await sharedService.loadJsonFromAssets('assets/json/$fileName.json');
      indicePieceData.value = [...fetchedJsonData["contenu"]];
      return indicePieceData;
    } catch (e) {
      print('Error: $e');
      return indicePieceData;
    }
  }

  List<String> jsonValuesAsList(jsonData) {
    return jsonData.values.map((e) => e.toString()).toList();
  }
}
