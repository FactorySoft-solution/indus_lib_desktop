import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/DropdownButtonWidget.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:code_g/app/widgets/checkbox_group_widget.dart';
import 'package:code_g/app/widgets/file_picker_widget.dart';
import 'package:code_g/app/widgets/image_picker_widget.dart';
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeftColumn(inputWidth, inputHeight),
                  _buildRightColumn(inputWidth, inputHeight),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeftColumn(double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextInput(
          width: width,
          height: height,
          label: 'Pièce ref N’ *',
          hint: 'Ajouter refº pièce',
          controller: controller.pieceRef,
        ),
        _buildDropdown(
          label: "Indice Piece",
          hint: "Select Indice Piece",
          controller: controller.pieceIndice,
          future: controller.extractIndicesJsonDate(),
          keyExtractor: (item) => item["indice"],
          width: width,
          height: height,
        ),
        _buildDropdown(
          label: "Machine *",
          hint: "Selectionner une machine",
          controller: controller.machine,
          future: controller.extractMachineJsonDate(),
          keyExtractor: (item) => item["nom"],
          width: width,
          height: height,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Diamètre de brute *',
          hint: 'Choisir l’epaisseur de pièce',
          controller: controller.pieceDiametre,
        ),
        _buildDropdown(
          label: "Type du mâchoire éjection *",
          hint: "Choisir le type du mâchoire",
          controller: controller.pieceEjection,
          future: controller.extractMechoireJsonDate(),
          keyExtractor: (item) => item["type"],
          width: width,
          height: height,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Nom de la pièce *',
          hint: 'Ajouter image pièce',
          controller: controller.pieceName,
        ),
        SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomDropdown(
                label: "Organe de serrage Broche principale *",
                hint: "Selection Organe BP",
                controller: controller.organeBP,
                items: ["1", "2", "3"],
                width: (width / 2) - 5,
                height: height,
              ),
              CustomDropdown(
                label: "Organe de serrage contre Broche *",
                hint: "Selection Organe CB",
                controller: controller.organeCB,
                items: ["1", "2", "3"],
                width: (width / 2) - 5,
                height: height,
              ),
            ],
          ),
        ),
        CheckboxGroupWidget(
          items: ["Tirage", "Cimblot", "Manchon"],
          controller: controller.selectedItemsController,
          spacing: 12.0,
        ),
      ],
    );
  }

  Widget _buildRightColumn(double width, double height) {
    void _handleFolderPicked(Map<String, List<String>>? filesByType) {
      if (filesByType != null) {
        // controller.caoFilePath.text = selectedFile
        print("Files grouped by type received in parent:");
        filesByType.forEach((extension, files) {
          print("Files with extension .$extension:");
          for (var file in files) {
            print(" - $file");
          }
        });
      } else {
        print("Folder picker was canceled.");
      }
    }

    return Column(
      children: [
        CustomTextInput(
          width: width,
          height: height,
          label: 'Epaisseur Pièce *',
          hint: 'Saisir l’epaisseur de pièce',
          controller: controller.epaisseur,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Matière Pièce *',
          hint: 'Choisir/ saisir la matière de la pièce',
          controller: controller.materiel,
        ),
        ImagePickerWidget(
          width: width,
          height: height,
          label: 'Forme Pièce *',
          hint: 'Ajouter l’image de la pièce',
          controller: controller.form,
        ),
        _buildDropdown(
          label: "Programmeur *",
          hint: "Saisir le programmeur de la pièce",
          controller: controller.programmeur,
          future: controller.extractProgrammersJsonDate(),
          keyExtractor: (item) => item["nom"],
          width: width,
          height: height,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Régleur machine *',
          hint: 'Saisir le régleur machine',
          controller: controller.regieur,
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Sélectionner spécificité pièce',
          hint: 'Sélectionner spécificité pièce',
          controller: controller.specification,
        ),
        // select files
        Row(
          children: [
            // FilePickerWidget(
            //   buttonText: "CAO*",
            //   onPick: (selectedFile) {
            //     if (selectedFile != null) {
            // controller.caoFilePath.text = selectedFile;
            //     }
            //   },
            // ),
            // FilePickerWidget(
            //   buttonText: "FAO*",
            //   onPick: (selectedFile) {
            //     if (selectedFile != null) {
            //       controller.faoFilePath.text = selectedFile;
            //     }
            //   },
            // ),
            // FilePickerWidget(
            //   buttonText: "File Z*",
            //   onPick: (selectedFile) {
            //     if (selectedFile != null) {
            //       controller.fileZPath.text = selectedFile;
            //     }
            //   },
            // ),

            FilePickerWidget(buttonText: "Plan*", onPick: _handleFolderPicked),
          ],
        ),

        CustomButton(text: 'Ajouter le pièce', onPressed: () => {})
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Future<List<dynamic>> future,
    required String Function(dynamic) keyExtractor,
    required double width,
    required double height,
  }) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No data available');
        }

        final value = controller.text;
        final items = snapshot.data!.map(keyExtractor).toList();

        return CustomDropdown(
          controller: controller,
          value: value.isEmpty ? null : value,
          items: items,
          label: label,
          hint: value.isEmpty ? hint : value,
          width: width,
          height: height,
        );
      },
    );
  }
}
