import 'package:flutter/material.dart';
import 'package:code_g/app/widgets/file_picker_button.dart';
import 'package:get/get.dart';
import '../controllers/create_project_controller.dart';

class CreateProjectView extends StatelessWidget {
  final CreateProjectController controller = Get.put(CreateProjectController());

  CreateProjectView({super.key}) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            FilePickerButton(
              buttonText: 'Upload Image Plan (PDF)',
              onPick: () => controller.pickFile('pdf'),
            ),
            Obx(() => controller.imagePlanPdf.value != null
                ? Text('File Selected: ${controller.imagePlanPdf.value!.path}')
                : const SizedBox.shrink()),
            const SizedBox(height: 20),
            FilePickerButton(
              buttonText: 'Select Dossier Programmation (Folder)',
              onPick: () => controller.pickFile('folder'),
            ),
            Obx(() => controller.dossProgFolder.value != null
                ? Text('Folder Selected: ${controller.dossProgFolder.value!}')
                : const SizedBox.shrink()),
            const SizedBox(height: 20),
            FilePickerButton(
              buttonText: 'Upload Programme (File)',
              onPick: () => controller.pickFile('file'),
            ),
            Obx(() => controller.programmeFile.value != null
                ? Text('File Selected: ${controller.programmeFile.value!.path}')
                : const SizedBox.shrink()),
            const SizedBox(height: 20),
            FilePickerButton(
              buttonText: 'Upload Fiche Util (PDF)',
              onPick: () => controller.pickFile('pdf'),
            ),
            Obx(() => controller.ficheUtilPdf.value != null
                ? Text('File Selected: ${controller.ficheUtilPdf.value!.path}')
                : const SizedBox.shrink()),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Perform form validation and submission
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
