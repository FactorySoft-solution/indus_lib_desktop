import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:code_g/app/widgets/checkbox_group_widget.dart';
import 'package:code_g/app/widgets/jsonDropDown.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/search_piece_controller.dart';

class SearchView extends GetView<SearchPieceController> {
  SearchView({super.key});

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
          'Recherche avancée',
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
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: CustomButton(
                text: 'Lancer la recherche',
                onPressed: () {
                  // Implement search functionality
                },
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
        JsonDropDown(
          label: "Machine",
          hint: "Choisir la machine que vous l'utiliser",
          controller: controller.machineController,
          future: controller.extractMachineJsonData(),
          keyExtractor: (item) => item["nom"],
          width: width,
          height: height,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: "Diamètre de brute",
          hint: "Choisir le diamètre de brute",
          controller: controller.pieceDiametreController,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Forme Pièce',
          hint: 'Ajouter image pièce',
          controller: controller.formController,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Epaisseur Pièce',
          hint: 'Choisir l\'epaisseur de pièce',
          controller: controller.epaisseurController,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInput(
          width: width,
          height: height,
          label: "Choix de l'opération",
          hint: "Choisir le type de l'opération",
          controller: controller.operationNameController,
        ),
        JsonDropDown(
          label: "Type Outils",
          hint: "Choisir l'outil à utiliser",
          controller: controller.topSolideOperationController,
          future: controller.extractTopSolideOperationsJsonData(),
          keyExtractor: (item) => item["name"],
          width: width,
          height: height,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: "Matière Pièce",
          hint: "Choisir la matière de la pièce",
          controller: controller.materielController,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: "Sélectionner spécificité pièce",
          hint: "Sélectionner s'il y avait s'il y en autre...",
          controller: controller.specificationController,
        ),
      ],
    );
  }
}
