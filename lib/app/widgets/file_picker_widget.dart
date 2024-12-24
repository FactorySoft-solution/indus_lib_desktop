import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class FilePickerWidget extends StatelessWidget {
  final String buttonText;
  final Function(String?) onPick;

  const FilePickerWidget({
    Key? key,
    required this.buttonText,
    required this.onPick,
  }) : super(key: key);

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      String sourceFilePath = result.files.single.path!;
      String fileName = result.files.single.name;

      // Get the desktop directory
      Directory desktopDirectory = Directory(
        "${Platform.environment['USERPROFILE'] ?? '/home/${Platform.environment['USER']}'}/Desktop",
      );

      // Destination file path on the desktop
      String destinationFilePath = "${desktopDirectory.path}/$fileName";

      try {
        // Move the file to the desktop
        File(sourceFilePath).copySync(destinationFilePath);

        // Notify the parent widget with the new file path
        onPick(destinationFilePath);
      } catch (e) {
        // Handle errors if the file move fails
        print("Error moving file: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _pickFile(), // Ensure a parameterless callback
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      ),
      child: Text(buttonText),
    );
  }
}
