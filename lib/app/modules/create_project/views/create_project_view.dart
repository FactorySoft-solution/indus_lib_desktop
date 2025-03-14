import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/modules/home/controllers/home_controller.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/DropdownButtonWidget.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:code_g/app/widgets/checkbox_group_widget.dart';
import 'package:code_g/app/widgets/file_picker_widget.dart';
import 'package:code_g/app/widgets/image_picker_widget.dart';
import 'package:code_g/app/widgets/jsonDropDown.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../controllers/create_project_controller.dart';

class CreateProjectView extends GetView<CreateProjectController> {
  CreateProjectView({super.key});
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final pageWidth = MediaQuery.of(context).size.width;
    final pageHeight = MediaQuery.of(context).size.height;

    const inputWidth = 450.0;
    const inputHeight = 40.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ajouter une nouvelle pièce',
          style: AppTextStyles.headline1,
        ),
        const SizedBox(height: 30),
        CustomCard(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          width: pageWidth * 0.8,
          height: pageHeight * 0.7,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeftColumn(inputWidth, inputHeight),
                  _buildRightColumn(inputWidth, inputHeight),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeftColumn(double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInput(
          width: width,
          height: height,
          label: 'Pièce ref N’ *',
          hint: 'Ajouter refº pièce',
          controller: controller.pieceRef,
        ),
        JsonDropDown(
          label: "Indice Piece",
          hint: "Select Indice Piece",
          controller: controller.pieceIndice,
          future: controller.extractIndicesJsonData(),
          keyExtractor: (item) => item["indice"],
          width: width,
          height: height,
        ),
        JsonDropDown(
          label: "Machine *",
          hint: "Selectionner une machine",
          controller: controller.machine,
          future: controller.extractMachineJsonData(),
          keyExtractor: (item) => item["nom"],
          width: width,
          height: height,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Diamètre de brute *',
          hint: 'Choisir l’epaisseur de pièce',
          controller: controller.pieceDiametre,
        ),
        JsonDropDown(
          label: "Type du mâchoire éjection *",
          hint: "Choisir le type du mâchoire",
          controller: controller.pieceEjection,
          future: controller.extractMechoireJsonData(),
          keyExtractor: (item) => item["type"],
          width: width,
          height: height,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Nom de la pièce *',
          hint: 'Ajouter image pièce',
          controller: controller.pieceName,
        ),
        SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomDropdown(
                label: "Organe de serrage Broche principale *",
                hint: "Selection Organe BP",
                controller: controller.organeBP,
                items: ["1", "2", "3"],
                width: (width / 2) - 5,
                height: height,
              ),
              CustomDropdown(
                label: "Organe de serrage contre Broche *",
                hint: "Selection Organe CB",
                controller: controller.organeCB,
                items: ["1", "2", "3"],
                width: (width / 2) - 5,
                height: height,
              ),
            ],
          ),
        ),
        CheckboxGroupWidget(
          items: ["Tirage", "Cimblot", "Manchon"],
          controller: controller.selectedItemsController,
          spacing: 12.0,
        ),
      ],
    );
  }

  Widget _buildRightColumn(double width, double height) {
    void nextStep() {
      if (controller.areFirstPartFieldsFilled()) {
        homeController.activePage.value =
            "Ajouter une mouvelle pièce/resume-project";
      }

      controller.update();
    }

    return Column(
      children: [
        CustomTextInput(
          width: width,
          height: height,
          label: 'Epaisseur Pièce *',
          hint: 'Saisir l’epaisseur de pièce',
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
          hint: 'Ajouter l’image de la pièce',
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
        // select files

        GetBuilder(
          init: CreateProjectController(),
          builder: (controller) => Row(
            children: [
              FilePickerWidget(
                status: controller.caoStatus.value,
                type: "folder",
                buttonText: "CAO*",
                onPick: controller.selectFilesFromFolder,
              ),
              if (controller.caoFilePath.text.isNotEmpty) ...[
                FilePickerWidget(
                  status: controller.faoStatus.value,
                  buttonText: "FAO*",
                  onPick: controller.selectFao,
                ),
                FilePickerWidget(
                  status: controller.fileZStatus.value,
                  buttonText: "File Z*",
                  onPick: controller.selectFileZ,
                ),
                FilePickerWidget(
                  status: controller.planStatus.value,
                  buttonText: "Plan*",
                  onPick: controller.selectPlan,
                ),
              ]
            ],
          ),
        ),
        CustomButton(text: 'Ajouter le pièce', onPressed: nextStep),
      ],
    );
  }
}
