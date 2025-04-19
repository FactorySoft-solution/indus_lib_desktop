import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_g/app/modules/home/controllers/home_controller.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:code_g/app/widgets/file_picker_widget.dart';
import 'package:code_g/app/widgets/image_picker_widget.dart';
import 'package:code_g/app/widgets/jsonDropDown.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import '../controllers/create_project_controller.dart';

class ProjectFormRightColumn extends StatelessWidget {
  final double width;
  final double height;
  final CreateProjectController controller;
  final Function? onNextStep;

  ProjectFormRightColumn({
    Key? key,
    required this.width,
    required this.height,
    required this.controller,
    this.onNextStep,
  }) : super(key: key);

  final HomeController homeController = Get.find<HomeController>();

  void _nextStep() {
    if (controller.areFirstPartFieldsFilled()) {
      if (onNextStep != null) {
        onNextStep!();
      } else {
        homeController.activePage.value =
            "Ajouter une mouvelle pièce/resume-project";
      }
    }
    controller.update();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextInput(
          width: width,
          height: height,
          label: 'Epaisseur Pièce *',
          hint: "Saisir l'epaisseur de pièce",
          controller: controller.epaisseur,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Matière Pièce *',
          hint: 'Choisir/ saisir la matière de la pièce',
          controller: controller.materiel,
        ),
        ImagePickerWidget(
          width: width,
          height: height,
          label: 'Forme Pièce *',
          hint: "Ajouter l'image de la pièce",
          controller: controller.form,
        ),
        JsonDropDown(
          label: "Programmeur *",
          hint: "Saisir le programmeur de la pièce",
          controller: controller.programmeur,
          future: controller.extractProgrammersJsonData(),
          keyExtractor: (item) => item["nom"],
          width: width,
          height: height,
          showReset: true,
          fieldName: 'programmeur',
          onReset: () => controller.handleReset('programmeur'),
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Régleur machine *',
          hint: 'Saisir le régleur machine',
          controller: controller.regieur,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Sélectionner spécificité pièce',
          hint: 'Sélectionner spécificité pièce',
          controller: controller.specification,
        ),

        // File selection buttons
        GetBuilder(
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
        ),

        CustomButton(text: 'Ajouter le pièce', onPressed: _nextStep),
      ],
    );
  }
}
