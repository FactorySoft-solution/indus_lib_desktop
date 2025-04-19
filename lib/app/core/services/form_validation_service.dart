import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class FormValidationService {
  static final FormValidationService _instance =
      FormValidationService._internal();
  factory FormValidationService() => _instance;
  FormValidationService._internal();

  final Logger logger = Logger();

  /// Check if all provided fields are filled
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

  /// Reset a list of controllers
  void resetControllers(List<TextEditingController> controllers) {
    for (var controller in controllers) {
      controller.clear();
    }
  }

  /// Determine status color based on controller state
  String getFieldStatus(
      TextEditingController controllerName, String referenceText) {
    final emptyReference = referenceText.isEmpty;
    final emptyController = controllerName.text.isEmpty;

    if (emptyReference || emptyController) {
      return "error";
    } else if (!emptyReference && !emptyController) {
      return "success";
    }
    return "pending";
  }

  /// Create a map with sidebar information from controllers
  Map<String, String> getSideBarInfo({
    required String pieceRef,
    required String pieceIndice,
    required String machine,
    required String materiel,
    required String pieceDiametre,
    required String pieceEjection,
    required String selectedItems,
    required String epaisseur,
    required String programmeur,
    required String regieur,
    required String pieceName,
    required String organeBP,
    required String organeCB,
  }) {
    final fields = {
      'Pièce ref º': pieceRef,
      'Indice ref º': pieceIndice,
      'Machine': machine,
      'Matière': materiel,
      'Ø Brute': pieceDiametre,
      'Type Mâchoire éjection': pieceEjection,
      'Tirage': selectedItems.contains("Tirage").toString(),
      'Cimblot': selectedItems.contains("Cimblot").toString(),
      'Manchon': selectedItems.contains("Manchon").toString(),
      'Epaisseur Pièce': epaisseur,
      'Programmeur': programmeur,
      'Régleur Machine': regieur,
      'Piece Name': pieceName,
      'Organe BP': organeBP,
      'Organe CB': organeCB,
    };
    return fields;
  }

  /// Prepare project data for saving
  Map<String, dynamic> prepareProjectData({
    required String pieceRef,
    required String pieceIndice,
    required String machine,
    required String pieceDiametre,
    required String pieceEjection,
    required String pieceName,
    required String epaisseur,
    required String materiel,
    required String form,
    required String programmeur,
    required String regieur,
    required String specification,
    required String organeBP,
    required String organeCB,
    required String selectedItems,
    required String caoFilePath,
    required String faoFilePath,
    required String fileZPath,
    required String planFilePath,
    required String topSolideOperation,
    required String operationName,
    required String displayOperation,
    required String arrosageType,
    required String fileZStatus,
    required String caoStatus,
    required String faoStatus,
    required String planStatus,
  }) {
    return {
      'pieceRef': pieceRef,
      'pieceIndice': pieceIndice,
      'machine': machine,
      'pieceDiametre': pieceDiametre,
      'pieceEjection': pieceEjection,
      'pieceName': pieceName,
      'epaisseur': epaisseur,
      'materiel': materiel,
      'form': form,
      'programmeur': programmeur,
      'regieur': regieur,
      'specification': specification,
      'organeBP': organeBP,
      'organeCB': organeCB,
      'selectedItems': selectedItems,
      'caoFilePath': caoFilePath,
      'faoFilePath': faoFilePath,
      'fileZPath': fileZPath,
      'planFilePath': planFilePath,
      'topSolideOperation': topSolideOperation,
      'operationName': operationName,
      'displayOperation': displayOperation,
      'arrosageType': arrosageType,
      'fileZStatus': fileZStatus,
      'caoStatus': caoStatus,
      'faoStatus': faoStatus,
      'planStatus': planStatus,
      'createdDate': DateTime.now().toIso8601String(),
    };
  }
}
