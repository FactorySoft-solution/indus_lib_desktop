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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: controller.diameterController,
              decoration: const InputDecoration(
                labelText: 'Nominal Diameter (mm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: controller.validateNumber,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.pitchController,
              decoration: const InputDecoration(
                labelText: 'Thread Pitch (mm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: controller.validateNumber,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: controller.calculate,
              child: const Text('Calculate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (!controller.showResults.value) return const SizedBox.shrink();

              final results = controller.results.value;
              if (results == null) return const SizedBox.shrink();

              return Column(
                children: [
                  CustomCard(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      const Text(
                        'Root Diameter (mm)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      _buildResultRow(
                          'First pass:', results['rootDiameter']['firstPass']),
                      _buildResultRow('Second pass:',
                          results['rootDiameter']['secondPass']),
                      _buildResultRow(
                          'Third pass:', results['rootDiameter']['thirdPass']),
                      const SizedBox(height: 16),
                      const Text(
                        'Clearance (mm)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      _buildResultRow(
                          'First pass:', results['clearance']['firstPass']),
                      _buildResultRow(
                          'Second pass:', results['clearance']['secondPass']),
                      _buildResultRow(
                          'Third pass:', results['clearance']['thirdPass']),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (controller.showEquation.value)
                    CustomCard(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        const Text(
                          'Clearance Z (mm)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(results['z']),
                      ],
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: controller.reset,
                    child: const Text('Reset'),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value),
      ],
    );
  }
}
