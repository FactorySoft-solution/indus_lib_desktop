import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_g/app/widgets/file_picker_widget.dart';
import '../controllers/create_project_controller.dart';

class FileSelectionRow extends StatelessWidget {
  final CreateProjectController controller;
  final bool isReadOnly;

  const FileSelectionRow({
    Key? key,
    required this.controller,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      return Row(
        children: [
          FilePickerWidget(
            status: "pending",
            type: "folder",
            buttonText: "CAO*",
            onPick: (_) {},
          ),
          const SizedBox(width: 20),
          FilePickerWidget(
            status: "pending",
            buttonText: "FAO*",
            onPick: (_) {},
          ),
          const SizedBox(width: 20),
          FilePickerWidget(
            status: "pending",
            buttonText: "File Z*",
            onPick: (_) {},
          ),
          const SizedBox(width: 20),
          FilePickerWidget(
            status: "pending",
            buttonText: "Plan*",
            onPick: (_) {},
          ),
        ],
      );
    }

    return GetBuilder(
      init: controller,
      builder: (controller) => Row(
        children: [
          FilePickerWidget(
            status: controller.caoStatus.value,
            type: "folder",
            buttonText: "CAO*",
            onPick: (selectedFolder) {
              if (selectedFolder != null) {
                controller.selectFilesFromFolder(selectedFolder);
              }
            },
          ),
          if (controller.caoFilePath.text.isNotEmpty) ...[
            FilePickerWidget(
              status: controller.faoStatus.value,
              buttonText: "FAO*",
              onPick: (selectedFile) {
                if (selectedFile != null) {
                  controller.selectFao(selectedFile);
                }
              },
            ),
            FilePickerWidget(
              status: controller.fileZStatus.value,
              buttonText: "File Z*",
              onPick: (selectedFile) {
                if (selectedFile != null) {
                  controller.selectFileZ(selectedFile);
                }
              },
            ),
            FilePickerWidget(
              status: controller.planStatus.value,
              buttonText: "Plan*",
              onPick: (selectedFile) {
                if (selectedFile != null) {
                  controller.selectPlan(selectedFile);
                }
              },
            ),
          ]
        ],
      ),
    );
  }
}
