import 'package:code_g/app/core/services/files_services.dart';
import 'package:code_g/app/core/services/shared_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class SearchPieceController extends GetxController {
  final Logger logger = new Logger();
  final SharedService sharedService = SharedService();
  final FilesServices filesServices = new FilesServices();
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
}
