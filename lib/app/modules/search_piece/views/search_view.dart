import 'dart:io';
import 'dart:convert';
import 'package:excel/excel.dart' hide Border, Stack, Row, Column;
import 'package:csv/csv.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:code_g/app/widgets/checkbox_group_widget.dart';
import 'package:code_g/app/widgets/jsonDropDown.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/search_piece_controller.dart';
import '../services/index.dart';
import 'widgets/expandable_directory_tile.dart';

class SearchView extends GetView<SearchPieceController> {
  SearchView({super.key}) {
    // Initialize WebView based on platform
    if (Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    } else if (Platform.isIOS) {
      WebViewPlatform.instance = WebKitWebViewPlatform();
    } else if (Platform.isWindows) {
      _initWindowsWebView();
    }
  }

  // Windows WebView controller
  final _windowsWebViewController = WebviewController();
  bool _windowsWebViewInitialized = false;

  Future<void> _initWindowsWebView() async {
    try {
      if (!_windowsWebViewInitialized) {
        await _windowsWebViewController.initialize();
        await _windowsWebViewController.setBackgroundColor(Colors.transparent);
        await _windowsWebViewController
            .setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
        _windowsWebViewInitialized = true;
      }
    } catch (e) {
      _windowsWebViewInitialized = false;
      Get.snackbar(
        'Erreur',
        'Impossible d\'initialiser le visualiseur de documents: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

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
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type de serrage:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: width,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey.shade50,
              ),
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxGroupWidget(
                        items: const ["Tirage", "Cimblot", "Manchon"],
                        controller: controller.selectedItemsController,
                        spacing: 12.0,
                      ),
                      if (controller.selectedItems.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              const Text(
                                'Filtres actifs:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              for (var item in controller.selectedItems)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Chip(
                                    label: Text(item),
                                    labelStyle: const TextStyle(fontSize: 11),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    deleteIcon:
                                        const Icon(Icons.close, size: 14),
                                    onDeleted: () {
                                      // Remove the item from selected items
                                      final currentItems = controller
                                          .selectedItemsController.text
                                          .split(',')
                                          .map((e) => e.trim())
                                          .toList();
                                      currentItems.remove(item);
                                      controller.selectedItemsController.text =
                                          currentItems.join(', ');
                                      controller.updateSearchFields();
                                      controller.performSearch();
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  )),
            ),
          ],
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
                  // Toggle view button
                  IconButton(
                    icon: Icon(
                      controller.displayTemplate.value == 'list'
                          ? Icons.grid_view
                          : Icons.list,
                      size: 20,
                    ),
                    tooltip: controller.displayTemplate.value == 'list'
                        ? 'Afficher en grille'
                        : 'Afficher en liste',
                    onPressed: () {
                      controller.toggleDisplayTemplate();
                    },
                  ),
                  const SizedBox(width: 8),
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
          // Choose between list and grid view based on displayTemplate
          controller.displayTemplate.value == 'list'
              ? _buildListView(results)
              : _buildGridView(results, width * 0.90),
        ],
      );
    });
  }

  Widget _buildListView(List<Map<String, dynamic>> results) {
    return Container(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chemin: ${project['projectPath']}',
                      style: AppTextStyles.bodyText2,
                    ),
                    if (project['ficheZollerFilename'] != null &&
                        project['ficheZollerFilename'].toString().isNotEmpty)
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
                        Text('Créé le: ${_formatDate(project['createdDate'])}'),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Ouvrir'),
                          onPressed: () {
                            // Get the paths with explicit toString() to ensure they're strings
                            String projectPath = project['projectPath'] != null
                                ? project['projectPath'].toString()
                                : '';
                            String copiedPath =
                                project['copiedFolderPath'] != null
                                    ? project['copiedFolderPath'].toString()
                                    : '';

                            // Use the copied path if it exists, otherwise use project path
                            String folderToOpen = copiedPath.isNotEmpty
                                ? copiedPath
                                : projectPath;

                            if (folderToOpen.isNotEmpty) {
                              // Try to open the folder
                              controller.openFolder(folderToOpen);
                            } else {
                              Get.snackbar(
                                'Erreur',
                                'Aucun chemin de dossier valide trouvé',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            if (project != null) {
                              await PinceSearchService
                                  .searchPinceInProjectArcFiles(
                                      context, project);
                            } else {
                              Get.snackbar(
                                'Erreur',
                                'Aucun projet sélectionné',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Recherche Liste Opérations'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            if (project != null) {
                              final folderPath =
                                  PinceSearchService.getFolderPathFromProject(
                                      project);
                              if (folderPath.isNotEmpty) {
                                try {
                                  PinceSearchService.showLoadingIndicator();
                                  final pinceFiles = await PinceSearchService
                                      .findPinceFilenames(folderPath);
                                  PinceSearchService.hideLoadingIndicator();

                                  if (pinceFiles.isNotEmpty) {
                                    _showFileSelectionDialog(
                                        context, pinceFiles);
                                  } else {
                                    Get.snackbar(
                                      'Information',
                                      'Aucun fichier .arc avec "PINCE" trouvé',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                } catch (e) {
                                  PinceSearchService.hideLoadingIndicator();
                                  Get.snackbar(
                                    'Erreur',
                                    'Erreur lors de la recherche: $e',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              } else {
                                Get.snackbar(
                                  'Erreur',
                                  'Aucun chemin de dossier valide trouvé',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            } else {
                              Get.snackbar(
                                'Erreur',
                                'Aucun projet sélectionné',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Voir Fichier Complet'),
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
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> results, double width) {
    // Calculate available width (80% of page width)
    final tableWidth = width * 0.79;

    // Define column width percentages
    final colWidths = {
      // 'no': 0.04, // 4%
      // 'ref': 0.12, // 12%
      // 'machine': 0.10, // 10%
      // 'matiere': 0.12, // 12%
      // 'diametre': 0.07, // 7%
      // 'serrage': 0.10, // 10%
      // 'forme': 0.25, // 25%
      // 'specifique': 0.20, // 20%
      'no': 0.05,
      'ref': 0.15,
      'machine': 0.12,
      'matiere': 0.15,
      'diametre': 0.08,
      'forme': 0.30,
      'specifique': 0.1479,
    };

    return Container(
      constraints: const BoxConstraints(maxHeight: 600),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Container(
              width: tableWidth,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  _buildGridHeader('N°', tableWidth * colWidths['no']!),
                  _buildGridHeader(
                      'Ref° pièce', tableWidth * colWidths['ref']!),
                  _buildGridHeader(
                      'Machine', tableWidth * colWidths['machine']!),
                  _buildGridHeader(
                      'Matière pièce', tableWidth * colWidths['matiere']!),
                  _buildGridHeader('Ø', tableWidth * colWidths['diametre']!),
                  // _buildGridHeader(
                  //     'Type serrage', tableWidth * colWidths['serrage']!),
                  _buildGridHeader(
                      'Forme de la pièce', tableWidth * colWidths['forme']!),
                  _buildGridHeader(
                      'Spécifique', tableWidth * colWidths['specifique']!),
                ],
              ),
            ),
            // Table rows
            for (int i = 0; i < results.length; i++)
              _buildGridRow(results[i], i, tableWidth, colWidths),
          ],
        ),
      ),
    );
  }

  Widget _buildGridHeader(String title, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGridRow(Map<String, dynamic> project, int index,
      double tableWidth, Map<String, double> colWidths) {
    final form =
        project['form'] != null && project['form'].toString().isNotEmpty
            ? project['form'].toString()
            : '';

    // Parse selected items from the project data
    final selectedItemsText = project['selectedItems'] != null
        ? project['selectedItems'].toString()
        : '';
    final List<String> selectedItems = selectedItemsText.isNotEmpty
        ? selectedItemsText.split(',').map((e) => e.trim()).toList()
        : [];

    return InkWell(
      onTap: () {
        // Show dialog with project details
        _showProjectDetailsDialog(project);
      },
      child: Container(
        width: tableWidth,
        decoration: BoxDecoration(
          color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
            right: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            _buildGridCell(
              (index + 1).toString(),
              tableWidth * colWidths['no']!,
              alignment: Alignment.center,
            ),
            _buildGridCell(
              '${project['pieceRef'] ?? ''} - ${project['pieceIndice'] ?? ''}',
              tableWidth * colWidths['ref']!,
            ),
            _buildGridCell(
                project['machine'] ?? '', tableWidth * colWidths['machine']!),
            _buildGridCell(
                project['materiel'] ?? '', tableWidth * colWidths['matiere']!),
            _buildGridCell(project['pieceDiametre'] ?? '',
                tableWidth * colWidths['diametre']!),
            // _buildGridCell(
            //   '',
            //   tableWidth * colWidths['serrage']!,
            //   customWidget: selectedItems.isNotEmpty
            //       ? Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: selectedItems
            //               .map((item) => Text(
            //                     item,
            //                     style: const TextStyle(fontSize: 11),
            //                     textAlign: TextAlign.center,
            //                   ))
            //               .toList(),
            //         )
            //       : null,
            // ),
            _buildGridCell(
              '',
              tableWidth * colWidths['forme']!,
              customWidget: form.isNotEmpty
                  ? Center(
                      // Center the image
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.file(
                          File(form),
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 40);
                          },
                        ),
                      ),
                    )
                  : null,
            ),
            _buildGridCell(project['specification'] ?? '',
                tableWidth * colWidths['specifique']!),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell(String text, double width,
      {Alignment alignment = Alignment.centerLeft, Widget? customWidget}) {
    return Container(
      width: width,
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      alignment: alignment != Alignment.centerLeft
          ? alignment
          : Alignment.center, // Center all data unless explicitly set
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey),
        ),
      ),
      child: customWidget ??
          Text(
            text,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center, // Center text horizontally
          ),
    );
  }

  void _showProjectDetailsDialog(Map<String, dynamic> project) {
    final bool hasJsonData = project.containsKey('machine') &&
        project['machine'] != null &&
        project['machine'].toString().isNotEmpty;

    // Parse selected items from the project data
    final selectedItemsText = project['selectedItems'] != null
        ? project['selectedItems'].toString()
        : '';
    final List<String> selectedItems = selectedItemsText.isNotEmpty
        ? selectedItemsText.split(',').map((e) => e.trim()).toList()
        : [];

    bool isDetailsView = true; // Initialize view state

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: Get.width * 0.6,
              constraints:
                  BoxConstraints(maxWidth: 800, maxHeight: Get.height * 0.8),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Détails de la pièce: ${project['pieceRef']} - ${project['pieceIndice']}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          // Template switch button
                          IconButton(
                            icon:
                                Icon(isDetailsView ? Icons.folder : Icons.info),
                            tooltip:
                                isDetailsView ? 'Vue dossiers' : 'Vue détails',
                            onPressed: () {
                              setState(() {
                                isDetailsView = !isDetailsView;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: isDetailsView
                        ? SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chemin: ${project['projectPath']}',
                                  style: AppTextStyles.bodyText2,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                if (project['ficheZollerFilename'] != null &&
                                    project['ficheZollerFilename']
                                        .toString()
                                        .isNotEmpty)
                                  Text(
                                    'Fiche Zoller: ${project['ficheZollerFilename']}',
                                    style: AppTextStyles.bodyText2,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                if (hasJsonData) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Détails du projet:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  if (project['pieceName'] != null &&
                                      project['pieceName']
                                          .toString()
                                          .isNotEmpty)
                                    Text(
                                        'Nom de pièce: ${project['pieceName']}'),
                                  if (project['pieceDiametre'] != null &&
                                      project['pieceDiametre']
                                          .toString()
                                          .isNotEmpty)
                                    Text(
                                        'Diamètre: ${project['pieceDiametre']}'),
                                  if (project['materiel'] != null &&
                                      project['materiel'].toString().isNotEmpty)
                                    Text('Matériel: ${project['materiel']}'),
                                  if (project['programmeur'] != null &&
                                      project['programmeur']
                                          .toString()
                                          .isNotEmpty)
                                    Text(
                                        'Programmeur: ${project['programmeur']}'),
                                  if (project['createdDate'] != null &&
                                      project['createdDate']
                                          .toString()
                                          .isNotEmpty)
                                    Text(
                                        'Créé le: ${_formatDate(project['createdDate'])}'),
                                  if (selectedItems.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Text(
                                          'Type de serrage:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(width: 8),
                                        Wrap(
                                          spacing: 4,
                                          children: selectedItems
                                              .map((item) => Chip(
                                                    label: Text(item),
                                                    labelStyle: const TextStyle(
                                                        fontSize: 12),
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ))
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                                const SizedBox(height: 16),
                                if (project['form'] != null &&
                                    project['form'].toString().isNotEmpty) ...[
                                  const Text(
                                    'Forme de la pièce:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: Image.file(
                                      File(project['form']),
                                      height: 200,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.broken_image,
                                            size: 100);
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : FutureBuilder<List<FileSystemEntity>>(
                            future: Directory(
                                    project['projectPath'] + "/copied_folder")
                                .list()
                                .toList(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Text('Erreur: ${snapshot.error}'),
                                );
                              }
                              final files = snapshot.data ?? [];
                              return ListView.builder(
                                itemCount: files.length,
                                itemBuilder: (context, index) {
                                  final file = files[index];
                                  final fileName = path.basename(file.path);
                                  final isDirectory = file is Directory;
                                  final extension =
                                      path.extension(fileName).toLowerCase();

                                  if (isDirectory) {
                                    return _buildDirectoryTile(file, context);
                                  }

                                  // File icon logic
                                  IconData icon;
                                  switch (extension.toLowerCase()) {
                                    case '.pdf':
                                      icon = Icons.picture_as_pdf;
                                      break;
                                    case '.jpg':
                                    case '.jpeg':
                                    case '.png':
                                      icon = Icons.image;
                                      break;
                                    case '.arc':
                                    case '.cam':
                                      icon = Icons.code;
                                      break;
                                    case '.doc':
                                    case '.docx':
                                      icon = Icons.description;
                                      break;
                                    case '.xls':
                                    case '.xlsx':
                                    case '.csv':
                                      icon = Icons.table_chart;
                                      break;
                                    default:
                                      icon = Icons.insert_drive_file;
                                  }

                                  return ListTile(
                                    leading: Icon(icon, color: Colors.blueGrey),
                                    title: Text(
                                      fileName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${(File(file.path).lengthSync() / 1024).toStringAsFixed(1)} KB',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    onTap: () {
                                      final lowerExt = extension.toLowerCase();
                                      if (['.jpg', '.jpeg', '.png']
                                          .contains(lowerExt)) {
                                        _showImagePreview(context, file.path);
                                      } else if (lowerExt == '.pdf') {
                                        _showPdfPreview(context, file.path);
                                      } else if (['.arc', '.cam']
                                          .contains(lowerExt)) {
                                        _showArcFilePreview(context, file.path);
                                      } else if (['.csv'].contains(lowerExt)) {
                                        _showCsvPreview(context, file.path);
                                      } else if (['.xlsx', '.xls']
                                          .contains(lowerExt)) {
                                        _showExcelPreview(context, file.path);
                                      } else if (['.docx'].contains(lowerExt)) {
                                        _showDocxPreview(context, file.path);
                                      } else {}
                                    },
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  const Divider(),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Get.back(),
                          child: const Text('Fermer'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Ouvrir le dossier'),
                          onPressed: () {
                            String projectPath = project['projectPath'] != null
                                ? project['projectPath'].toString()
                                : '';
                            String copiedPath =
                                project['copiedFolderPath'] != null
                                    ? project['copiedFolderPath'].toString()
                                    : '';

                            String folderToOpen = copiedPath.isNotEmpty
                                ? copiedPath
                                : projectPath;

                            if (folderToOpen.isNotEmpty) {
                              controller.openFolder(folderToOpen);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.visibility),
                          label: const Text('Consulter la pièce'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // Implementation for viewing the piece details
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
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

  void _showPdfPreview(BuildContext context, String filePath) {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Aperçu PDF: ${path.basename(filePath)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: 'Ouvrir en plein écran',
                        onPressed: () {
                          Get.back();
                          Get.dialog(
                            Dialog.fullscreen(
                              child: Stack(
                                children: [
                                  SfPdfViewer.file(
                                    File(filePath),
                                    enableDoubleTapZooming: true,
                                    enableTextSelection: true,
                                    enableDocumentLinkAnnotation: true,
                                  ),
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () => Get.back(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final errorNotifier = ValueNotifier<String?>(null);

                    return ValueListenableBuilder<String?>(
                      valueListenable: errorNotifier,
                      builder: (context, error, _) {
                        if (error != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 64, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                                  'Erreur lors du chargement du PDF:\n$error',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        }

                        return SfPdfViewer.file(
                          File(filePath),
                          enableDoubleTapZooming: true,
                          enableTextSelection: true,
                          enableDocumentLinkAnnotation: true,
                          onDocumentLoadFailed: (details) {
                            errorNotifier.value = details.error;
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imagePath) {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aperçu image: ${path.basename(imagePath)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: 'Ouvrir dans une nouvelle fenêtre',
                        onPressed: () {
                          // Open in new window logic
                          Get.back(); // Close current dialog
                          Get.dialog(
                            Dialog.fullscreen(
                              child: Stack(
                                children: [
                                  // Full screen image with zoom capabilities
                                  InteractiveViewer(
                                    panEnabled: true,
                                    boundaryMargin: const EdgeInsets.all(20),
                                    minScale: 0.5,
                                    maxScale: 4,
                                    child: Center(
                                      child: Image.file(
                                        File(imagePath),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  // Close button
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () => Get.back(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Center(
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Impossible de charger l\'image\n${error.toString()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this method to handle directory tiles
  Widget _buildDirectoryTile(Directory directory, BuildContext context) {
    return ExpandableDirectoryTile(
      directory: directory,
      onImageTap: (String path) => _showImagePreview(context, path),
      onPdfTap: (String path) => _showPdfPreview(context, path),
    );
  }

  // Add this new method to simplify the process of showing arc files
  void _showArcFilePreview(BuildContext context, String filePath) {
    FileViewService.showArcFilePreview(context, filePath);
  }

  // Add new methods for file previews
  void _showCsvPreview(BuildContext context, String filePath) {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Aperçu CSV: ${path.basename(filePath)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.open_in_browser),
                        tooltip: 'Ouvrir dans Excel',
                        onPressed: () async {
                          try {
                            final uri = Uri.file(filePath);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else {
                              throw 'Impossible d\'ouvrir le fichier';
                            }
                          } catch (e) {
                            Get.snackbar(
                              'Erreur',
                              'Impossible d\'ouvrir le fichier: $e',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<String>(
                  future: () async {
                    try {
                      final content = await File(filePath).readAsString();
                      return content;
                    } catch (e) {
                      rethrow;
                    }
                  }(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur lors de la lecture du fichier:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Ouvrir dans Excel'),
                              onPressed: () async {
                                try {
                                  final uri = Uri.file(filePath);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    throw 'Impossible d\'ouvrir le fichier';
                                  }
                                } catch (e) {
                                  Get.snackbar(
                                    'Erreur',
                                    'Impossible d\'ouvrir le fichier: $e',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    try {
                      final csvData = const CsvToListConverter(
                        shouldParseNumbers: true,
                        allowInvalid: true,
                        fieldDelimiter: ';', // Try semicolon as delimiter
                      ).convert(snapshot.data!);

                      if (csvData.isEmpty) {
                        // Try with comma delimiter if no data found
                        final csvDataComma = const CsvToListConverter(
                          shouldParseNumbers: true,
                          allowInvalid: true,
                          fieldDelimiter: ',',
                        ).convert(snapshot.data!);

                        if (csvDataComma.isNotEmpty) {
                          csvData.addAll(csvDataComma);
                        }
                      }

                      if (csvData.isEmpty) {
                        return const Center(child: Text('Fichier vide'));
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: List<DataColumn>.generate(
                              csvData[0].length,
                              (index) => DataColumn(
                                label: Text(
                                  csvData[0][index]?.toString() ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            rows: csvData.skip(1).map<DataRow>((row) {
                              return DataRow(
                                cells: List<DataCell>.generate(
                                  row.length,
                                  (index) => DataCell(
                                    Text(
                                      row[index]?.toString() ?? '',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    } catch (e) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur de format CSV:\n$e',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Ouvrir dans Excel'),
                              onPressed: () async {
                                try {
                                  final uri = Uri.file(filePath);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    throw 'Impossible d\'ouvrir le fichier';
                                  }
                                } catch (e) {
                                  Get.snackbar(
                                    'Erreur',
                                    'Impossible d\'ouvrir le fichier: $e',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExcelPreview(BuildContext context, String filePath) {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Aperçu Excel: ${path.basename(filePath)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder<List<List<dynamic>>>(
                  future: () async {
                    final bytes = await File(filePath).readAsBytes();
                    final excel = Excel.decodeBytes(bytes);
                    final sheet = excel.tables[excel.tables.keys.first]!;

                    List<List<dynamic>> data = [];
                    for (var row in sheet.rows) {
                      data.add(row.map((cell) => cell?.value ?? '').toList());
                    }
                    return data;
                  }(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur lors de la lecture du fichier:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    if (data.isEmpty)
                      return const Center(child: Text('Fichier vide'));

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columns: List<DataColumn>.generate(
                            data[0].length,
                            (index) => DataColumn(
                              label: Text(
                                data[0][index].toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          rows: data.skip(1).map<DataRow>((row) {
                            return DataRow(
                              cells: List<DataCell>.generate(
                                row.length,
                                (index) => DataCell(
                                  Text(row[index].toString()),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocxPreview(BuildContext context, String filePath) async {
    try {
      Get.dialog(
        Dialog(
          child: Container(
            width: Get.width * 0.8,
            height: Get.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Aperçu Word: ${path.basename(filePath)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_browser),
                          tooltip: 'Ouvrir dans Word',
                          onPressed: () async {
                            try {
                              final uri = Uri.file(filePath);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                throw 'Impossible d\'ouvrir le fichier';
                              }
                            } catch (e) {
                              Get.snackbar(
                                'Erreur',
                                'Impossible d\'ouvrir le fichier: $e',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.description,
                            size: 64, color: Colors.blue),
                        const SizedBox(height: 16),
                        Text(
                          path.basename(filePath),
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Ouvrir dans Word'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: () async {
                            try {
                              final uri = Uri.file(filePath);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                throw 'Impossible d\'ouvrir le fichier';
                              }
                            } catch (e) {
                              Get.snackbar(
                                'Erreur',
                                'Impossible d\'ouvrir le fichier: $e',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger le document: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _showFileSelectionDialog(BuildContext context, List<String> files) {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.6,
          height: Get.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sélectionner un fichier',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final fileName = path.basename(file);

                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(fileName),
                      subtitle: Text(
                        file,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () async {
                        Get.back(); // Close dialog

                        // Parse blocks first
                        final blocks =
                            await PinceSearchService.parseArcFileBlocks(file);

                        // Show complete file content
                        PinceSearchService.showCompleteFileContent(
                            context, blocks, file);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Annuler'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
