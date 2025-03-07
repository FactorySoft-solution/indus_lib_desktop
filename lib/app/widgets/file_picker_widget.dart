import 'dart:io';

import 'package:code_g/app/core/services/files_services.dart';
import 'package:code_g/app/core/values/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// ignore: must_be_immutable
class FilePickerWidget extends StatelessWidget {
  var logger = Logger();

  final String buttonText;
  final String? type;
  final String? status;
  final Function(Map<String, List<String>>?)
      onPick; // Updated to accept the result

  FilePickerWidget({
    super.key,
    required this.buttonText,
    required this.onPick,
    required this.status,
    this.type = "file",
  });
  FilesServices filesServices = FilesServices();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Select a File",
      type: FileType.any, // Accept any type
      allowMultiple: false, // Single selection
      allowCompression: false, // Optional, prevents compression
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;

      // Return the file path as a map with a single key-value pair
      Map<String, List<String>> fileMap = {
        "file": [filePath],
      };
      onPick(fileMap);
    } else {
      onPick(null); // Notify the parent that the operation was canceled
    }
  }

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      // List files and folders inside the selected directory
      List<FileSystemEntity> filesList =
          filesServices.listFilesAndFolders(selectedDirectory);
      List<String> filePaths = [];
      for (var element in filesList) {
        filePaths.add(element.path);
      }

      Map<String, List<String>> filesByType =
          filesServices.regroupFilesByType(filePaths);

      filesByType['mainDir'] = [selectedDirectory];
      onPick(filesByType);
    } else {
      // User canceled the picker
      print("User canceled the folder picker");
      onPick(null); // Notify the parent that the operation was canceled
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => type == "folder" ? _pickFolder() : _pickFile(),
      style: ElevatedButton.styleFrom(
        backgroundColor: status == "pending"
            ? AppColors.transparent
            : status == "success"
                ? AppColors.accentColor
                : AppColors.errorColor,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      ),
      child: Text(buttonText),
    );
  }
}
