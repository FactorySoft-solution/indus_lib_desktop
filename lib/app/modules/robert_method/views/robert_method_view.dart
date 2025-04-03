import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:code_g/app/widgets/DropdownButtonWidget.dart';
import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/core/values/app_colors.dart';
import '../controllers/robert_method_controller.dart';

class RobertMethodView extends GetView<RobertMethodController> {
  const RobertMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageWidth = MediaQuery.of(context).size.width;
    final pageHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calculateur Méthode Robert',
          style: AppTextStyles.headline1,
        ),
        const SizedBox(height: 20),
        CustomCard(
          padding: const EdgeInsets.all(24.0),
          width: pageWidth * 0.75,
          height: pageHeight * 0.8,
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cette application est conçue pour simplifier vos calculs de tronçage en utilisant la méthode Robert',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  // Thread type and designation selectors

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Type du Filetage'),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: pageWidth * 0.3,
                            child: CustomDropdown(
                              label: '',
                              hint: 'Choisir le type du filetage',
                              items: const ['Métrique', 'Impérial', 'Autre'],
                              controller: controller.threadTypeController,
                              height: 40.0,
                              onChanged: controller.updateThreadType,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Désignation du Filetage'),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: pageWidth * 0.3,
                            child: CustomDropdown(
                              label: '',
                              hint: 'Choisir la désignation du filetage',
                              items: controller.threadDesignations,
                              controller:
                                  controller.threadDesignationController,
                              height: 40.0,
                              onChanged: controller.updateThreadDesignation,
                            ),
                          ),
                          // )
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Results display area
                  Center(
                    child: SizedBox(
                      width: pageWidth * 0.6,
                      child: CustomCard(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          const Center(
                            child: Text(
                              'Les repère tronçage générer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => controller.hasResults.value
                                ? _buildResultsDisplay()
                                : const Center(
                                    child: Text(
                                      'Sélectionnez un type et une désignation de filetage',
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Buttons for PDF operations
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        text: 'Import du fichier PDF Procédure',
                        onPressed: () => controller.importPdfProcedure(),
                        width: pageWidth * 0.3,
                        height: 50,
                        color: AppColors.ligthColor,
                        textColor: AppColors.darkColor,
                        borderRadius: 8.0,
                      ),
                      CustomButton(
                        text: 'Afficher le fichier procédure',
                        onPressed: () => controller.displayPdfProcedure(),
                        width: pageWidth * 0.3,
                        height: 50,
                        color: AppColors.purpleColor,
                        textColor: AppColors.ligthColor,
                      ),
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

  Widget _buildResultsDisplay() {
    return Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Type: ${controller.selectedThreadType}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Désignation: ${controller.selectedThreadDesignation}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Diamètre nominal (D1): ${controller.threadData.value?.D1 ?? ""}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Diamètre mineur (D3): ${controller.threadData.value?.D3 ?? ""}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Pas (P): ${controller.threadData.value?.P ?? ""}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ));
  }
}
