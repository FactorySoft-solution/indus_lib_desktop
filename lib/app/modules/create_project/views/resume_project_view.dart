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

  // Current operation index
  final RxInt currentOperationIndex = 0.obs;

  void handleSubmit() {
    if (controller.areFirstPartFieldsFilled() &&
        controller.areAllOperationsFilled()) {
      controller.copySelectedFolder();
    } else {
      logger.w("Please fill all fields before submitting.");
    }
  }

  void goToNextOperation() {
    // First ensure current operation data is saved properly
    Map<String, dynamic> operationData =
        currentOperationIndex.value < controller.selectedOperations.length
            ? controller.selectedOperations[currentOperationIndex.value]
            : {};

    if (operationData.isEmpty ||
        operationData['operation']?.isEmpty == true ||
        operationData['topSolideOperation']?.isEmpty == true ||
        operationData['arrosageType']?.isEmpty == true) {
      // Show error if data is not complete
      Get.snackbar(
        "Missing Data",
        "Please fill all required fields for this operation.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (currentOperationIndex.value < controller.fileZJsonData.length - 1) {
      // Clear fields for the next operation
      if (currentOperationIndex.value == 0) {
        // If moving from the first operation, clear the main controller fields
        controller.topSolideOperation.clear();
        controller.arrosageType.clear();
      }

      // Move to next operation
      currentOperationIndex.value++;
    } else {
      // If we're at the last operation, prepare to submit
      Get.snackbar(
        "Operations Completed",
        "All operations have been configured. You can now submit the form.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void goToPreviousOperation() {
    if (currentOperationIndex.value > 0) {
      // First ensure current operation data is saved
      Map<String, dynamic> operationData =
          currentOperationIndex.value < controller.selectedOperations.length
              ? controller.selectedOperations[currentOperationIndex.value]
              : {};

      // Allow navigation to previous operation without validation
      currentOperationIndex.value--;
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

                  // Operation forms
                  Obx(() {
                    // If no operations are available, display a single empty form
                    if (controller.fileZJsonData.isEmpty) {
                      return Column(
                        children: [
                          ProjectOperationForm(
                            controller: controller,
                            inputWidth: inputWidth,
                            inputHeight: inputHeight,
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            text: 'OK',
                            onPressed: () {
                              if (controller.areSecandPartFieldsFilled()) {
                                Get.snackbar(
                                  "Operation Saved",
                                  "Operation data has been saved successfully.",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } else {
                                Get.snackbar(
                                  "Missing Data",
                                  "Please fill all required fields.",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                          ),
                        ],
                      );
                    }

                    // Show the current operation index
                    int index = currentOperationIndex.value;
                    bool isLastOperation =
                        index == controller.fileZJsonData.length - 1;

                    return Column(
                      children: [
                        // Operation navigation indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Opération ${index + 1} / ${controller.fileZJsonData.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Current operation info
                        Text(
                          'Opération: ${controller.fileZJsonData[index]["operation"]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        // Operation form
                        ProjectOperationForm(
                          controller: controller,
                          inputWidth: inputWidth,
                          inputHeight: inputHeight,
                          operationData: controller.fileZJsonData[index],
                          operationIndex: index,
                        ),

                        // Navigation buttons
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (index > 0)
                              CustomButton(
                                text: 'Précédent',
                                onPressed: goToPreviousOperation,
                                color: Colors.grey,
                              ),
                            const SizedBox(width: 20),
                            CustomButton(
                              text: isLastOperation ? 'Terminer' : 'OK',
                              onPressed: () {
                                goToNextOperation();
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  }),

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
