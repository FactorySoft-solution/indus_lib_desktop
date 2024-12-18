import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class CreateProjectController extends GetxController {
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
}
