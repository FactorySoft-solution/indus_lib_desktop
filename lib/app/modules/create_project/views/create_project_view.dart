import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/DropdownButtonWidget.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/create_project_controller.dart';

class CreateProjectView extends GetView<CreateProjectController> {
  const CreateProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageWidth = MediaQuery.of(context).size.width;
    final pageHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Ajouter une nouvelle pièce',
              style: AppTextStyles.headline1,
            )
          ],
        ),
        const SizedBox(
          height: 30,
        ),
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
                children: [
                  Column(
                    children: [
                      CustomTextInput(
                        width: 300,
                        height: 40,
                        label: 'Pièce ref N’ *',
                        hint: 'Ajouter refº pièce',
                        controller: controller.pieceRef,
                      ),
                      FutureBuilder<RxList<dynamic>>(
                        future: controller.extractJsonDate('indicePIECE'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text('No data available');
                          }
                          return CustomDropdown(
                            controller: controller
                                .pieceIndice, // Bind the TextEditingController
                            value: controller.pieceIndice.text.isEmpty
                                ? null
                                : controller
                                    .pieceIndice.text, // Bind the current value
                            items: controller.indicePieceData
                                .map((item) => item["indice"])
                                .toList(), // Dynamically populated list
                            label: "Indice Piece",
                            hint: controller.pieceIndice.text.isEmpty
                                ? "Select Indice Piece"
                                : controller.pieceIndice.text,
                            width: 300,
                            height: 40,
                          );
                        },
                      ),
                      CustomTextInput(
                        width: 300,
                        height: 40,
                        label: 'Machine *',
                        hint: 'Selectionner une machine',
                        controller: controller.machine,
                      ),
                      CustomTextInput(
                        width: 300,
                        height: 40,
                        label: 'Diamètre de brute *',
                        hint: 'Choisir l’epaisseur de pièce',
                        controller: controller.pieceDiametre,
                      ),
                      CustomTextInput(
                        width: 300,
                        height: 40,
                        label: 'Type du mâchoire éjection *',
                        hint: 'Choisir le type du mâchoire',
                        controller: controller.pieceEjection,
                      ),
                      CustomTextInput(
                        width: 300,
                        height: 40,
                        label: 'Nom de la pièce *',
                        hint: 'Ajouter image pièce',
                        controller: controller.pieceName,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      CustomTextInput(
                        width: 300,
                        height: 40,
                        label: 'Pièce ref N’ *',
                        hint: 'Ajouter refº pièce',
                        controller: controller.pieceRef,
                      ),
                      CustomTextInput(
                        width: 300,
                        height: 40,
                        label: 'Indice de la pièce *',
                        hint: 'Choisir le diamètre de brute',
                        controller: controller.pieceIndice,
                      ),
                      CustomTextInput(
                        width: 300,
                        height: 40,
                        label: 'Machine *',
                        hint: 'Selectionner une machine',
                        controller: controller.machine,
                      ),
                      CustomTextInput(
                        width: 300,
                        height: 40,
                        label: 'Diamètre de brute *',
                        hint: 'Choisir l’epaisseur de pièce',
                        controller: controller.pieceDiametre,
                      ),
                      CustomTextInput(
                        width: 300,
                        height: 40,
                        label: 'Type du mâchoire éjection *',
                        hint: 'Choisir le type du mâchoire',
                        controller: controller.pieceEjection,
                      ),
                      CustomTextInput(
                        width: 300,
                        height: 40,
                        label: 'Nom de la pièce *',
                        hint: 'Ajouter image pièce',
                        controller: controller.pieceName,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}
