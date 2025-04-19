import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/DropdownButtonWidget.dart';
import 'package:code_g/app/widgets/jsonDropDown.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import 'package:code_g/app/widgets/checkbox_group_widget.dart';
import '../controllers/create_project_controller.dart';

class ProjectFormLeftColumn extends StatelessWidget {
  final double width;
  final double height;
  final CreateProjectController controller;

  const ProjectFormLeftColumn({
    Key? key,
    required this.width,
    required this.height,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInput(
          width: width,
          height: height,
          label: 'Pièce ref N°',
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
          showReset: true,
          fieldName: 'pieceIndice',
          onReset: () => controller.handleReset('pieceIndice'),
        ),
        JsonDropDown(
          label: "Machine *",
          hint: "Selectionner une machine",
          controller: controller.machine,
          future: controller.extractMachineJsonData(),
          keyExtractor: (item) => item["nom"],
          width: width,
          height: height,
          showReset: true,
          fieldName: 'machine',
          onReset: () => controller.handleReset('machine'),
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Diamètre de brute *',
          hint: "Choisir l'epaisseur de pièce",
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
          showReset: true,
          fieldName: 'pieceEjection',
          onReset: () => controller.handleReset('pieceEjection'),
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
}
