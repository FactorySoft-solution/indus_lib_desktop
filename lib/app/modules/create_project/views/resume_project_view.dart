import 'package:code_g/app/core/services/files_services.dart';
import 'package:code_g/app/core/values/app_text_styles.dart';
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
import 'dart:io';

import '../controllers/create_project_controller.dart';

class ResumeProjectView extends GetView<CreateProjectController> {
  ResumeProjectView({super.key});
  Logger logger = Logger();
  final filesServices = new FilesServices();
  void handleSubmit() {
    if (controller.areFirstPartFieldsFilled() &&
        controller.areSecandPartFieldsFilled()) {
      controller.copySelectedFolder();
    } else {
      print("Please fill all fields before submitting.");
    }
  }

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
              child: Column(
                children: [
                  Flex(
                    direction: Axis.horizontal,
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // const Spacer(),
                      const SizedBox(
                        width: 20,
                      ),
                      FilePickerWidget(
                        status: "pending",
                        type: "folder",
                        buttonText: "CAO*",
                        onPick: (selectedFile) => {},
                      ),
                      // const Spacer(),
                      const SizedBox(
                        width: 20,
                      ),
                      FilePickerWidget(
                        status: "pending",
                        buttonText: "FAO*",
                        onPick: (selectedFile) => {},
                      ),
                      // const Spacer(),
                      const SizedBox(
                        width: 20,
                      ),
                      FilePickerWidget(
                        status: "pending",
                        buttonText: "File Z*",
                        onPick: (selectedFile) => {},
                      ),
                      // const Spacer(),
                      const SizedBox(
                        width: 20,
                      ),
                      FilePickerWidget(
                        status: "pending",
                        buttonText: "Plan*",
                        onPick: (selectedFile) => {},
                      ),
                      // const Spacer(),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  CustomCard(
                    children: [
                      Row(
                        children: [
                          JsonDropDown(
                            onChanged: (value) =>
                                controller.updateDisplayOperation(value),
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
                            future:
                                controller.extractTopSolideOperationsJsonData(),
                            keyExtractor: (item) => item["name"],
                            width: inputWidth - 10,
                            height: inputHeight,
                          ),
                        ],
                      ),
                      Row(children: [
                        CustomTextInput(
                          width: inputWidth - 10,
                          height: inputHeight,
                          label: '',
                          hint:
                              'Choisir une opération pour l\'Affichage de l\'Outil',
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
                        ),
                      ])
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Display image from controller.form
                      controller.form.text.isNotEmpty
                          ? Container(
                              width: 500,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.file(
                                File(controller.form.text),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const SizedBox.shrink(),
                      CustomButton(
                          text: 'Ajouter le pièce', onPressed: handleSubmit),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
