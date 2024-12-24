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
  final epaisseur = TextEditingController();
  final materiel = TextEditingController();
  final TextEditingController form = TextEditingController();
  final programmeur = TextEditingController();
  final regieur = TextEditingController();
  final specification = TextEditingController();
  final organeBP = TextEditingController();
  final organeCB = TextEditingController();
  final TextEditingController selectedItemsController = TextEditingController();
  String? selectedFile;
  final caoFilePath = TextEditingController(); // Add this

  @override
  void onInit() {
    super.onInit();
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

  Future<List<dynamic>> extractIndicesJsonDate() async {
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

  Future<List<dynamic>> extractMachineJsonDate() async {
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

  Future<List<dynamic>> extractMechoireJsonDate() async {
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

  Future<List<dynamic>> extractProgrammersJsonDate() async {
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

  List<String> jsonValuesAsList(jsonData) {
    return jsonData.values.map((e) => e.toString()).toList();
  }
}
