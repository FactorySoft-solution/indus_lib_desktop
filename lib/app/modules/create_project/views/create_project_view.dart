import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
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

    // ListView(
    //   children: [
    //     FilePickerButton(
    //       buttonText: 'Upload Image Plan (PDF)',
    //       onPick: () => controller.pickFile('pdf'),
    //     ),
    //     Obx(() => controller.imagePlanPdf.value != null
    //         ? Text('File Selected: ${controller.imagePlanPdf.value!.path}')
    //         : const SizedBox.shrink()),
    //     const SizedBox(height: 20),
    //     FilePickerButton(
    //       buttonText: 'Select Dossier Programmation (Folder)',
    //       onPick: () => controller.pickFile('folder'),
    //     ),
    //     Obx(() => controller.dossProgFolder.value != null
    //         ? Text('Folder Selected: ${controller.dossProgFolder.value!}')
    //         : const SizedBox.shrink()),
    //     const SizedBox(height: 20),
    //     FilePickerButton(
    //       buttonText: 'Upload Programme (File)',
    //       onPick: () => controller.pickFile('file'),
    //     ),
    //     Obx(() => controller.programmeFile.value != null
    //         ? Text('File Selected: ${controller.programmeFile.value!.path}')
    //         : const SizedBox.shrink()),
    //     const SizedBox(height: 20),
    //     FilePickerButton(
    //       buttonText: 'Upload Fiche Util (PDF)',
    //       onPick: () => controller.pickFile('pdf'),
    //     ),
    //     Obx(() => controller.ficheUtilPdf.value != null
    //         ? Text('File Selected: ${controller.ficheUtilPdf.value!.path}')
    //         : const SizedBox.shrink()),
    //     const SizedBox(height: 40),
    //     ElevatedButton(
    //       onPressed: () {
    //         // Perform form validation and submission
    //       },
    //       child: const Text('Submit'),
    //     ),
    //   ],
    // );
  }
}
