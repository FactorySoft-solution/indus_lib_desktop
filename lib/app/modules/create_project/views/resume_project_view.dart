import 'dart:io';

import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../controllers/create_project_controller.dart';
import '../widgets/index.dart';

class ResumeProjectView extends GetView<CreateProjectController> {
  ResumeProjectView({super.key});
  Logger logger = Logger();

  void handleSubmit() {
    if (controller.areFirstPartFieldsFilled() &&
        controller.areSecandPartFieldsFilled()) {
      controller.copySelectedFolder();
    } else {
      logger.w("Please fill all fields before submitting.");
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
                  // File selection row
                  FileSelectionRow(
                    controller: controller,
                    isReadOnly: true,
                  ),

                  // Operation form
                  ProjectOperationForm(
                    controller: controller,
                    inputWidth: inputWidth,
                    inputHeight: inputHeight,
                  ),

                  const SizedBox(height: 20),

                  // Preview and submit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Display form image
                      PreviewFormImage(controller: controller),

                      // Submit button
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
