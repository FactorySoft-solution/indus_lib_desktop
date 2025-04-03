import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:code_g/app/widgets/DropdownButtonWidget.dart';
import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/core/values/app_colors.dart';
import '../controllers/robert_method_controller.dart';

class FiltageCalculatorView extends GetView<RobertMethodController> {
  const FiltageCalculatorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calculateur Méthode Robert',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Type du Filetage'),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: CustomDropdown(
                        label: '',
                        hint: 'Choisir le type du filetage',
                        items: const ['Métrique'],
                        controller: controller.threadTypeController,
                        height: 40.0,
                        onChanged: (value) =>
                            controller.updateThreadType(value),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Désignation du Filetage'),
                    const SizedBox(height: 5),
                    Obx(() => SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: CustomDropdown(
                            label: '',
                            hint: 'Choisir la désignation du filetage',
                            items: controller.threadDesignations,
                            controller: controller.threadDesignationController,
                            height: 40.0,
                            onChanged: (value) =>
                                controller.updateThreadDesignation(value),
                          ),
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() => controller.hasResults.value
                ? _buildResults()
                : const Center(
                    child: Text(
                        'Sélectionnez un type et une désignation de filetage'),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return CustomCard(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('Type: ${controller.selectedThreadType.value}'),
        const SizedBox(height: 10),
        Text('Désignation: ${controller.selectedThreadDesignation.value}'),
        const SizedBox(height: 10),
        Text('Diamètre nominal (D1): ${controller.threadData.value?.D1 ?? ""}'),
        const SizedBox(height: 10),
        Text('Diamètre mineur (D3): ${controller.threadData.value?.D3 ?? ""}'),
        const SizedBox(height: 10),
        Text('Pas (P): ${controller.threadData.value?.P ?? ""}'),
      ],
    );
  }
}
