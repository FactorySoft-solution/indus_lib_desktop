import 'package:flutter/material.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/jsonDropDown.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import '../controllers/create_project_controller.dart';

class ProjectOperationForm extends StatelessWidget {
  final CreateProjectController controller;
  final double inputWidth;
  final double inputHeight;

  const ProjectOperationForm({
    Key? key,
    required this.controller,
    required this.inputWidth,
    required this.inputHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      children: [
        Row(
          children: [
            JsonDropDown(
              onChanged: (value) => controller.updateDisplayOperation(value),
              label: "Saisir une opération *",
              hint: "Sélectionner une opération",
              controller: controller.operationName,
              future: controller.extractOperationsData(),
              keyExtractor: (item) => item,
              width: inputWidth - 10,
              height: inputHeight,
            ),
            const SizedBox(width: 10),
            JsonDropDown(
              label: "Ajouter un type pour l'operation *",
              hint:
                  "Choisir une opération puis Sélectionner un type de la liste TopSolid",
              controller: controller.topSolideOperation,
              future: controller.extractTopSolideOperationsJsonData(),
              keyExtractor: (item) => item["name"],
              width: inputWidth - 10,
              height: inputHeight,
              showReset: true,
              fieldName: 'topSolideOperation',
              onReset: () => controller.handleReset('topSolideOperation'),
            ),
          ],
        ),
        Row(
          children: [
            CustomTextInput(
              width: inputWidth - 10,
              height: inputHeight,
              label: '',
              hint: 'Choisir une opération pour l\'Affichage de l\'Outil',
              controller: controller.displayOperation,
            ),
            const SizedBox(width: 10),
            JsonDropDown(
              label: "Ajouter l\'arrosage *",
              hint:
                  "Choisir une opération puis Sélectionner un arrosage pour l\'outil",
              controller: controller.arrosageType,
              future: controller.extractArrosageTypesJsonData(),
              keyExtractor: (item) => item["name"],
              width: inputWidth - 10,
              height: inputHeight,
              showReset: true,
              fieldName: 'arrosageType',
              onReset: () => controller.handleReset('arrosageType'),
            ),
          ],
        )
      ],
    );
  }
}
