import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:code_g/app/widgets/checkbox_group_widget.dart';
import 'package:code_g/app/widgets/jsonDropDown.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import '../controllers/search_piece_controller.dart';

class SearchView extends GetView<SearchPieceController> {
  SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageWidth = MediaQuery.of(context).size.width;
    final pageHeight = MediaQuery.of(context).size.height;

    const inputWidth = 450.0;
    const inputHeight = 40.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recherche avancée',
            style: AppTextStyles.headline1,
          ),
          const SizedBox(height: 30),
          CustomCard(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            width: pageWidth * 0.8,
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
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: CustomButton(
                  text: 'Lancer la recherche',
                  onPressed: () async {
                    await controller.performSearch();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search results section
          _buildSearchResults(pageWidth),
          const SizedBox(height: 30), // Add padding at the bottom
        ],
      ),
    );
  }

  Widget _buildLeftColumn(double width, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JsonDropDown(
          label: "Machine",
          hint: "Choisir la machine que vous l'utiliser",
          controller: controller.machineController,
          future: controller.extractMachineJsonData(),
          keyExtractor: (item) => item["nom"],
          width: width,
          height: height,
          showReset: true,
          fieldName: 'machine',
          onReset: () => controller.handleReset('machine'),
        ),
        CustomTextInput(
          width: width,
          height: height,
          label: "Diamètre de brute",
          hint: "Choisir le diamètre de brute",
          controller: controller.pieceDiametreController,
        ),
        // CustomTextInput(
        //   width: width,
        //   height: height,
        //   label: 'Forme Pièce',
        //   hint: 'Ajouter image pièce',
        //   controller: controller.formController,
        // ),
        CustomTextInput(
          width: width,
          height: height,
          label: 'Epaisseur Pièce',
          hint: 'Choisir l\'epaisseur de pièce',
          controller: controller.epaisseurController,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JsonDropDown(
          label: "Choix de l'opération",
          hint: "Choisir le type de l'opération",
          controller: controller.topSolideOperationController,
          future: controller.extractTopSolideOperationsJsonData(),
          keyExtractor: (item) => item["name"],
          width: width,
          height: height,
          showReset: true,
          fieldName: 'operation',
          onReset: () => controller.handleReset('operation'),
        ),
        //  JsonDropDown(
        //   label: "Type Outils",
        //   hint: "Choisir l'outil à utiliser",
        //   controller: controller.topSolideOperationController,
        //   future: controller.extractTopSolideOperationsJsonData(),
        //   keyExtractor: (item) => item["name"],
        //   width: width,
        //   height: height,
        // ),
        // CustomTextInput(
        //   width: width,
        //   height: height,
        //   label: "Choix de l'opération",
        //   hint: "Choisir le type de l'opération",
        //   controller: controller.operationNameController,
        // ),

        CustomTextInput(
          width: width,
          height: height,
          label: "Matière Pièce",
          hint: "Choisir la matière de la pièce",
          controller: controller.materielController,
        ),
        // CustomTextInput(
        //   width: width,
        //   height: height,
        //   label: "Sélectionner spécificité pièce",
        //   hint: "Sélectionner s'il y avait s'il y en autre...",
        //   controller: controller.specificationController,
        // ),
      ],
    );
  }

  Widget _buildSearchResults(double width) {
    return Obx(() {
      final results = controller.searchResults;

      if (results.isEmpty) {
        return const SizedBox.shrink(); // Hide when no results
      }

      return CustomCard(
        padding: const EdgeInsets.all(16.0),
        width: width * 0.8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Résultats de recherche',
                style: AppTextStyles.headline2,
              ),
              Row(
                children: [
                  // Sort dropdown
                  _buildSortDropdown(),
                  const SizedBox(width: 16),
                  Text(
                    '${results.length} projets trouvés',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: results.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final project = results[index];
                final bool hasJsonData = project.containsKey('machine') &&
                    project['machine'] != null &&
                    project['machine'].toString().isNotEmpty;

                return ExpansionTile(
                  leading: const Icon(Icons.folder, color: Colors.amber),
                  title: Text(
                    '${project['pieceRef']} - ${project['pieceIndice']}',
                    style: AppTextStyles.subtitle1,
                  ),
                  subtitle: Text(
                    hasJsonData
                        ? 'Machine: ${project['machine']}'
                        : 'Dossier: ${path.basename(project['copiedFolderPath'])}',
                    style: AppTextStyles.bodyText2,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chemin: ${project['projectPath']}',
                            style: AppTextStyles.bodyText2,
                          ),
                          if (project['ficheZollerFilename'] != null &&
                              project['ficheZollerFilename']
                                  .toString()
                                  .isNotEmpty)
                            Text(
                              'Fiche Zoller: ${project['ficheZollerFilename']}',
                              style: AppTextStyles.bodyText2,
                            ),
                          if (hasJsonData) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Détails du projet:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (project['pieceName'] != null &&
                                project['pieceName'].toString().isNotEmpty)
                              Text('Nom de pièce: ${project['pieceName']}'),
                            if (project['pieceDiametre'] != null &&
                                project['pieceDiametre'].toString().isNotEmpty)
                              Text('Diamètre: ${project['pieceDiametre']}'),
                            if (project['materiel'] != null &&
                                project['materiel'].toString().isNotEmpty)
                              Text('Matériel: ${project['materiel']}'),
                            if (project['programmeur'] != null &&
                                project['programmeur'].toString().isNotEmpty)
                              Text('Programmeur: ${project['programmeur']}'),
                            if (project['createdDate'] != null &&
                                project['createdDate'].toString().isNotEmpty)
                              Text(
                                  'Créé le: ${_formatDate(project['createdDate'])}'),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.folder_open),
                                label: const Text('Ouvrir'),
                                onPressed: () {
                                  // Add detailed logging
                                  // Get the paths with explicit toString() to ensure they're strings
                                  String projectPath =
                                      project['projectPath'] != null
                                          ? project['projectPath'].toString()
                                          : '';
                                  String copiedPath =
                                      project['copiedFolderPath'] != null
                                          ? project['copiedFolderPath']
                                              .toString()
                                          : '';

                                  // Use the copied path if it exists, otherwise use project path
                                  String folderToOpen = copiedPath.isNotEmpty
                                      ? copiedPath
                                      : projectPath;

                                  if (folderToOpen.isNotEmpty) {
                                    // Try to open the folder
                                    controller.openFolder(folderToOpen);
                                  } else {
                                    print("No valid folder path found to open");
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    });
  }

  // Build sort dropdown widget
  Widget _buildSortDropdown() {
    return Obx(() {
      // Create simple sort options with display names
      final sortDisplayOptions = [
        'Référence (${controller.sortField.value == 'pieceRef' && !controller.sortAscending.value ? "Z-A" : "A-Z"})',
        'Indice (${controller.sortField.value == 'pieceIndice' && !controller.sortAscending.value ? "Z-A" : "A-Z"})',
        'Machine (${controller.sortField.value == 'machine' && !controller.sortAscending.value ? "Z-A" : "A-Z"})',
        'Nom de pièce (${controller.sortField.value == 'pieceName' && !controller.sortAscending.value ? "Z-A" : "A-Z"})',
        'Date (${controller.sortField.value == 'createdDate' && controller.sortAscending.value ? "Plus ancien" : "Plus récent"})',
      ];

      // Determine which option is selected
      String currentOption = sortDisplayOptions[0]; // Default to first option

      if (controller.sortField.value == 'pieceRef') {
        currentOption = sortDisplayOptions[0];
      } else if (controller.sortField.value == 'pieceIndice') {
        currentOption = sortDisplayOptions[1];
      } else if (controller.sortField.value == 'machine') {
        currentOption = sortDisplayOptions[2];
      } else if (controller.sortField.value == 'pieceName') {
        currentOption = sortDisplayOptions[3];
      } else if (controller.sortField.value == 'createdDate') {
        currentOption = sortDisplayOptions[4];
      }

      return Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentOption,
            icon: Icon(
              controller.sortAscending.value
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              size: 16,
            ),
            isDense: true,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            items: sortDisplayOptions
                .map<DropdownMenuItem<String>>((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue == null) return;

              // Determine which field was selected
              String field = 'pieceRef'; // Default
              bool shouldToggle = false;

              if (newValue.startsWith('Référence')) {
                field = 'pieceRef';
                shouldToggle = controller.sortField.value == 'pieceRef';
              } else if (newValue.startsWith('Indice')) {
                field = 'pieceIndice';
                shouldToggle = controller.sortField.value == 'pieceIndice';
              } else if (newValue.startsWith('Machine')) {
                field = 'machine';
                shouldToggle = controller.sortField.value == 'machine';
              } else if (newValue.startsWith('Nom de pièce')) {
                field = 'pieceName';
                shouldToggle = controller.sortField.value == 'pieceName';
              } else if (newValue.startsWith('Date')) {
                field = 'createdDate';
                shouldToggle = controller.sortField.value == 'createdDate';
              }

              // If the same field is selected, toggle direction
              if (shouldToggle) {
                controller.sortAscending.value =
                    !controller.sortAscending.value;
              } else {
                // For a new field, set sort direction
                // Default: A-Z (ascending) for text, newest first (descending) for dates
                controller.sortAscending.value = field != 'createdDate';
                controller.sortField.value = field;
              }

              controller.sortResults();
            },
          ),
        ),
      );
    });
  }

  // Helper method to format ISO date
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return isoDate;
    }
  }
}
