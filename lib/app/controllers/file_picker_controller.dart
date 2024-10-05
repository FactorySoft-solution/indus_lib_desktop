import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class FilePickerController extends GetxController {
  // Reactive variable to store the selected file path
  var selectedFilePath = ''.obs;

  // Method to pick a file
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      selectedFilePath.value = result.files.single.path ?? '';
      print("Picked file: ${selectedFilePath.value}");
    } else {
      print("No file selected");
    }
  }
}
