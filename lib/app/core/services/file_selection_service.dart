import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:code_g/app/core/services/files_services.dart';
import 'package:code_g/app/core/services/project_service.dart';
import 'package:code_g/app/core/services/form_validation_service.dart';

class FileSelectionService {
  static final FileSelectionService _instance =
      FileSelectionService._internal();
  factory FileSelectionService() => _instance;
  FileSelectionService._internal();

  final Logger logger = Logger();
  final FilesServices filesServices = FilesServices();
  final ProjectService projectService = ProjectService();
  final FormValidationService formValidationService = FormValidationService();

  /// Generic method to select a file and update controller
  void selectFile(Map<String, List<String>>? selectedFile,
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
    } catch (e) {
      logger.e("Error selecting file: $e");
    }
  }

  /// Select FAO file
  void selectFao(Map<String, List<String>>? selectedFile,
      TextEditingController faoFilePath, ValueChanged<String> updateStatus) {
    if (selectedFile == null ||
        !selectedFile.containsKey("file") ||
        selectedFile["file"]!.isEmpty) {
      return;
    }

    try {
      String filePath = selectedFile["file"]!.first;

      if (projectService.isValidFaoFile(filePath)) {
        selectFile(selectedFile, faoFilePath);
        updateStatus(formValidationService.getFieldStatus(
            faoFilePath, faoFilePath.text));
      } else {
        logger.w(
            "Invalid file: File must end with '.arc' and not contain 'pince'.");
      }
    } catch (e) {
      logger.e("Error selecting FAO file: $e");
    }
  }

  /// Select plan file
  void selectPlan(Map<String, List<String>>? selectedFile,
      TextEditingController planFilePath, ValueChanged<String> updateStatus) {
    if (selectedFile == null ||
        !selectedFile.containsKey("file") ||
        selectedFile["file"]!.isEmpty) {
      return;
    }

    try {
      String filePath = selectedFile["file"]!.first;

      if (projectService.isValidPlanFile(filePath)) {
        selectFile(selectedFile, planFilePath);
        updateStatus(formValidationService.getFieldStatus(
            planFilePath, planFilePath.text));
      } else {
        logger.w("Invalid file: File must be PDF and contain 'IND'.");
      }
    } catch (e) {
      logger.e("Error selecting plan file: $e");
    }
  }

  /// Select file Z and process it
  Future<Map<String, dynamic>> selectFileZ(
      Map<String, List<String>>? selectedFile,
      TextEditingController fileZPath,
      ValueChanged<String> updateStatus) async {
    if (selectedFile == null ||
        !selectedFile.containsKey("file") ||
        selectedFile["file"]!.isEmpty) {
      return {};
    }

    try {
      String filePath = selectedFile["file"]!.first;

      if (projectService.isValidFileZ(filePath)) {
        fileZPath.text = filePath;
        updateStatus(
            formValidationService.getFieldStatus(fileZPath, fileZPath.text));

        // Process the file Z
        return await projectService.processFileZ(filePath);
      } else {
        logger.w("Invalid file: File must be PDF and contain 'fiche z'.");
      }
    } catch (e) {
      logger.e("Error selecting file Z: $e");
    }

    return {};
  }

  /// Select files from folder
  void selectFilesFromFolder(
      Map<String, List<String>>? selectedFolderFiles,
      TextEditingController caoFilePath,
      TextEditingController faoFilePath,
      TextEditingController fileZPath,
      TextEditingController planFilePath,
      ValueChanged<String> updateCaoStatus,
      ValueChanged<String> updateFaoStatus,
      ValueChanged<String> updateFileZStatus,
      ValueChanged<String> updatePlanStatus,
      Function(Map<String, dynamic>) onFileZProcessed) {
    if (selectedFolderFiles == null) return;

    try {
      // Save the root folder path
      if (selectedFolderFiles.containsKey("mainDir") &&
          selectedFolderFiles['mainDir']!.isNotEmpty) {
        var mainDir = selectedFolderFiles['mainDir']![0];
        if (FileSystemEntity.isDirectorySync(mainDir)) {
          caoFilePath.text = mainDir;
          updateCaoStatus(formValidationService.getFieldStatus(
              caoFilePath, caoFilePath.text));
        }
      }

      // Process ARC files
      if (selectedFolderFiles.containsKey("arc")) {
        List<String> arcFiles =
            List<String>.from(selectedFolderFiles['arc'] ?? []);
        for (var file in arcFiles) {
          selectFao({
            "file": [file]
          }, faoFilePath, updateFaoStatus);
        }
      }

      // Process PDF files
      if (selectedFolderFiles.containsKey("pdf")) {
        List<String> pdfFiles =
            List<String>.from(selectedFolderFiles['pdf'] ?? []);
        for (var file in pdfFiles) {
          selectFileZ({
            "file": [file]
          }, fileZPath, updateFileZStatus)
              .then((result) {
            if (result.isNotEmpty) {
              onFileZProcessed(result);
            }
          });
          selectPlan({
            "file": [file]
          }, planFilePath, updatePlanStatus);
        }
      }

      // Process subdirectories
      if (selectedFolderFiles.containsKey("dir")) {
        List<String> directories =
            List<String>.from(selectedFolderFiles['dir'] ?? []);
        for (var dir in directories) {
          if (FileSystemEntity.isDirectorySync(dir)) {
            var listGroup = filesServices.regroupDirectoryFilesByType(dir);
            selectFilesFromFolder(
                listGroup,
                caoFilePath,
                faoFilePath,
                fileZPath,
                planFilePath,
                updateCaoStatus,
                updateFaoStatus,
                updateFileZStatus,
                updatePlanStatus,
                onFileZProcessed);
          }
        }
      }
    } catch (e) {
      logger.e("Error selecting files from folder: $e");
    }
  }
}
