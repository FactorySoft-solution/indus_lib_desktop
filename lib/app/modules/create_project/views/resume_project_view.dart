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
        controller.areAllOperationsFilled()) {
      controller.copySelectedFolder();
    } else {
      logger.w("Please fill all fields before submitting.");
    }
  }

  void goToNextOperation() {
    // First ensure current operation data is saved properly
    Map<String, dynamic> operationData = controller
                .currentOperationIndex.value <
            controller.selectedOperations.length
        ? controller.selectedOperations[controller.currentOperationIndex.value]
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

    if (controller.currentOperationIndex.value <
        controller.fileZJsonData.length - 1) {
      // Clear fields for the next operation
      if (controller.currentOperationIndex.value == 0) {
        // If moving from the first operation, clear the main controller fields
        controller.topSolideOperation.clear();
        controller.arrosageType.clear();
      }

      // Move to next operation
      controller.currentOperationIndex.value++;
      controller.update();
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
    if (controller.currentOperationIndex.value > 0) {
      // First ensure current operation data is saved
      Map<String, dynamic> operationData =
          controller.currentOperationIndex.value <
                  controller.selectedOperations.length
              ? controller
                  .selectedOperations[controller.currentOperationIndex.value]
              : {};

      // Allow navigation to previous operation without validation
      controller.currentOperationIndex.value--;
      controller.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageWidth = MediaQuery.of(context).size.width;
    final pageHeight = MediaQuery.of(context).size.height;

    const inputWidth = 450.0;
    const inputHeight = 40.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ajouter une nouvelle pièce',
                style: AppTextStyles.headline1,
              ),
              const SizedBox(height: 15),
              CustomCard(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                width: pageWidth * 0.8,
                height: constraints.maxHeight * 0.85,
                enableScroll: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // File selection row
                        FileSelectionRow(
                          controller: controller,
                          isReadOnly: true,
                        ),

                        // Operation forms
                        GetBuilder<CreateProjectController>(
                          builder: (_) {
                            // This will capture updates from the controller
                            final index =
                                controller.currentOperationIndex.value;

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
                                      if (controller
                                          .areSecandPartFieldsFilled()) {
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
                            bool isLastOperation =
                                index == controller.fileZJsonData.length - 1;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Rest of the form with reduced spacing
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: constraints.maxHeight * 0.65,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Operation navigation indicator
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Opération ${index + 1} / ${controller.fileZJsonData.length}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            // Add dropdown to quickly jump to operations
                                            DropdownButton<int>(
                                              hint: Text("Aller à..."),
                                              underline: Container(
                                                height: 1,
                                                color: Colors.blue,
                                              ),
                                              onChanged: (int? newIndex) {
                                                if (newIndex != null) {
                                                  controller
                                                      .goToOperation(newIndex);
                                                }
                                              },
                                              items: List.generate(
                                                controller.fileZJsonData.length,
                                                (i) {
                                                  String opName = controller
                                                              .fileZJsonData[i]
                                                          ["operation"] ??
                                                      "Operation ${i + 1}";
                                                  bool isConfigured = i <
                                                          controller
                                                              .selectedOperations
                                                              .length &&
                                                      controller
                                                          .selectedOperations[i]
                                                          .isNotEmpty &&
                                                      controller.selectedOperations[
                                                                  i][
                                                              'topSolideOperation'] !=
                                                          null &&
                                                      controller.selectedOperations[
                                                                  i][
                                                              'arrosageType'] !=
                                                          null;

                                                  return DropdownMenuItem<int>(
                                                    value: i,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                            "${i + 1}. $opName"),
                                                        SizedBox(width: 5),
                                                        Icon(
                                                          isConfigured
                                                              ? Icons
                                                                  .check_circle
                                                              : Icons
                                                                  .circle_outlined,
                                                          color: isConfigured
                                                              ? Colors.green
                                                              : Colors.grey,
                                                          size: 16,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Current operation info with status
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Opération: ${controller.fileZJsonData[index]["operation"]}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Builder(builder: (context) {
                                              // Check if there's saved data for this operation
                                              String statusText = "";
                                              Color statusColor = Colors.grey;

                                              if (index <
                                                  controller.selectedOperations
                                                      .length) {
                                                Map<String, dynamic> opData =
                                                    controller
                                                            .selectedOperations[
                                                        index];
                                                if (opData.isNotEmpty &&
                                                    opData['topSolideOperation'] !=
                                                        null &&
                                                    opData['topSolideOperation']
                                                        .toString()
                                                        .isNotEmpty &&
                                                    opData['arrosageType'] !=
                                                        null &&
                                                    opData['arrosageType']
                                                        .toString()
                                                        .isNotEmpty) {
                                                  statusText = " (Configurée)";
                                                  statusColor = Colors.green;
                                                } else if (opData.isNotEmpty) {
                                                  statusText =
                                                      " (Partiellement configurée)";
                                                  statusColor = Colors.orange;
                                                } else {
                                                  statusText =
                                                      " (Non configurée)";
                                                  statusColor = Colors.red;
                                                }
                                              }

                                              return Text(
                                                statusText,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: statusColor,
                                                ),
                                              );
                                            }),
                                          ],
                                        ),

                                        // Operation form
                                        ProjectOperationForm(
                                          controller: controller,
                                          inputWidth: inputWidth,
                                          inputHeight: inputHeight,
                                          operationData:
                                              controller.fileZJsonData[index],
                                          operationIndex: index,
                                        ),

                                        // Navigation buttons
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (index > 0)
                                              CustomButton(
                                                text: 'Précédent',
                                                onPressed:
                                                    goToPreviousOperation,
                                                color: Colors.grey,
                                              ),
                                            const SizedBox(width: 20),
                                            CustomButton(
                                              text: isLastOperation
                                                  ? 'Terminer'
                                                  : 'OK',
                                              onPressed: () {
                                                goToNextOperation();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Preview and submit button
                                Container(
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Display form image
                                      PreviewFormImage(controller: controller),

                                      // Submit button
                                      CustomButton(
                                          text: 'Ajouter le pièce',
                                          onPressed: handleSubmit),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
