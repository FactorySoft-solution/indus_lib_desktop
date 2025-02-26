import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/DropdownButtonWidget.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:code_g/app/widgets/checkbox_group_widget.dart';
import 'package:code_g/app/widgets/file_picker_widget.dart';
import 'package:code_g/app/widgets/image_picker_widget.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

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
    final logger = new Logger();
    final RxString caoStatus = "pending".obs;
    final RxString faoStatus = "pending".obs;
    final RxString fileZStatus = "pending".obs;
    final RxString planStatus = "pending".obs;
    String _borderColor(controllerName) {
      final emptyFolder = controller.caoFilePath.text.isEmpty;
      final emptyController = controllerName.text.isEmpty;
      var status = "pending";
      if (!emptyFolder && emptyController) {
        status = "error";
      } else if (!emptyFolder && !emptyController) {
        status = "success";
      }
      return status;
    }

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

    void _selectFile(selectedFile, controller) {
      if (selectedFile != null) {
        if (selectedFile.containsKey("file")) {
          // Single file selected
          String filePath = selectedFile["file"]!.first;
          controller.text = filePath;
        } else if (selectedFile.containsKey("files")) {
          // Folder selected
          List<String> filePaths = selectedFile["files"]!;
          // Handle multiple files as needed
          controller.text = filePaths.first; // Example: Take the first file
        }
      }
    }

    void _selectFao(selectedFile) {
      String filePath = selectedFile["file"]!.first;
      String fileName = filePath.split('/').last;
      if ((fileName.endsWith('.arc') || fileName.endsWith('.ARC')) &&
          !fileName.toLowerCase().contains('pince')) {
        _selectFile(selectedFile, controller.faoFilePath);
        faoStatus.value = _borderColor(controller.faoFilePath);
      } else {
        // Show an error message or handle the invalid file case
        print(
            "Invalid file: File must end with '.arc' and not contain 'pince'.");
      }
    }

    void _selectPlan(selectedFile) {
      String filePath = selectedFile["file"]!.first;
      String fileName = filePath.split('/').last;
      if (fileName.toLowerCase().contains("IND") &&
          fileName.toLowerCase().endsWith('.pdf')) {
        _selectFile(selectedFile, controller.planFilePath);
        planStatus.value = _borderColor(controller.planFilePath);
      } else {
        // Show an error message or handle the invalid file case
        print(
            "Invalid file: File must end with '.arc' and not contain 'pince'.");
      }
    }

    String extractedText = "";
    bool isLoading = false;

    /// Saves text content to a file
    Future<void> saveTextToFile(String content, String filePath) async {
      File file = File(filePath);
      logger.i({content, filePath});
      await file.writeAsString(content);
    }

    Map<String, dynamic>? searchInArray(List<String> array, String searchKey) {
      for (int i = 0; i < array.length; i++) {
        if (array[i].contains(searchKey)) {
          return {'value': array[i], 'index': i};
        }
      }
      return null; // Return null if no match is found
    }

    List<Map<String, dynamic>> processCorrecters(String line) {
      var correctersList = line.split("Correcteur");
      final correcters =
          []; // This list is unused in your original code, so it can be removed

      List<Map<String, dynamic>> resultArray = [];

      correctersList.forEach((correcter) {
        if (correcter.trim().isEmpty) return; // Skip empty strings

        var data = correcter.split(':');
        if (data.length < 2) return; // Skip if no ':' is found

        var values = data[1].split(',');
        // Extract correcteur number
        var correcteurNumber =
            values[0].split("X")[0].replaceAll(RegExp(r'[^0-9]'), '');
        if (values.length < 5) return; // Ensure there are enough values

        // Extract X value
        var x = values[0].split("X")[1] + "." + values[1];

        // Extract Z Nominal value
        var ZSerchresult = searchInArray(values, "Z");

        var zIndex = ZSerchresult?["index"];
        var zArray = ZSerchresult?["value"];
        var zPart1Array = zArray.split("Z")[1];
        var zPart2Array = values[zIndex + 1].split("T.s")[0];
        var zNominal = zPart1Array + ',' + zPart2Array;
        logger.i({zPart2Array, zPart1Array, zNominal});
        var result = searchInArray(values, "T.b");
        if (result == null) return; // Skip if "T.b" is not found
        var tbArray = result['value'].split("T.b");
        var rayonExist = tbArray[1][1].toString().toLowerCase() != "z";
        var rayon = '-';
        if (rayonExist) {
          var rayonPart1 = tbArray[1][1];
          var rayonPart2 = values[result['index'] + 1].split("Z")[0];
          rayon = rayonPart1 + "," + rayonPart2;
        }

        // Add to the result list
        resultArray.add({
          "correcteur": correcteurNumber,
          "x": x,
          "z": zNominal,
          "r": rayon,
        });
      });

      return resultArray; // Return the processed data
    }

    /// Parses extracted text into structured JSON format
    Map<String, dynamic> parseExtractedText(String text) {
      List<Map<String, dynamic>> entries = [];
      List<String> lines = text.split('\n');

      Map<String, dynamic>? currentEntry;

      for (String line in lines) {
        if (line.contains("Numéro :")) {
          if (currentEntry != null) {
            entries.add(currentEntry);
          }
          currentEntry = {
            "numero": "",
            "description": line.split("Numéro :")[1].trim(),
            "details": []
          };
        } else if (line.contains("Desc.:")) {
          currentEntry?["numero"] = line.split("Desc.:")[1].trim();
        } else if (line
            .contains("PositionDescriptionQuantitéListe de pièces")) {
          // Skip header
        } else if (line.contains("Correcteur")) {
          var correctersList = line.split("Correcteur");
          var result = processCorrecters(line);
          currentEntry?["details"] = result;
        } else if (RegExp(r"^\d+").hasMatch(line)) {
          List<String> parts = line.split(RegExp(r"\s{2,}"));
          if (parts.length >= 2) {
            currentEntry?["details"].add({
              "position": parts[0].trim(),
              "description": parts[1].trim(),
            });
          }
        }
      }

      if (currentEntry != null) {
        entries.add(currentEntry);
      }

      return {"entries": entries};
    }

    Future<void> pickAndExtractText(path) async {
      // setState(() {
      //   isLoading = true;
      // });

      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['pdf'],
      // );

      // if (result != null) {
      // File file = File(result.files.single.path!);
      File file = File(path!);
      final Uint8List bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      String text = PdfTextExtractor(document).extractText();
      String originalhtmlFilePath =
          "${file.parent.path}/original_extracted_text.html";
      await saveTextToFile(text, originalhtmlFilePath);

      // Convert extracted text to HTML format
      String extractedHtml = text.replaceAll("\n", "<br>");

      // Convert extracted text to structured JSON
      Map<String, dynamic> structuredJson = parseExtractedText(text);

      // Define file paths
      String jsonFilePath = "${file.parent.path}/extracted_text.json";
      String htmlFilePath = "${file.parent.path}/extracted_text.html";

      // Save both HTML and JSON files
      await saveTextToFile(extractedHtml, htmlFilePath);
      await saveTextToFile(jsonEncode(structuredJson), jsonFilePath);

      // setState(() {
      extractedText = extractedHtml; // Store HTML in state
      //   isLoading = false;
      // });
      // } else {
      // setState(() {
      //   isLoading = false;
      // });
      // }
    }

    void _selectFileZ(selectedFile) {
      String filePath = selectedFile["file"]!.first;
      String fileName = filePath.split('/').last;
      // if (
      //   fileName.toLowerCase().contains('fiche z') &&
      //     fileName.toLowerCase().endsWith('.pdf')) {
      logger.e("test");
      // _selectFile(selectedFile, controller.fileZPath);
      pickAndExtractText(filePath);
      // fileZStatus.value = _borderColor(controller.fileZPath);
      // } else {
      //   // Show an error message or handle the invalid file case
      //   print(
      //       "Invalid file: File must end with '.arc' and not contain 'pince'.");
      // }
    }

    void _selectFilesFromFolder(
        Map<String, List<String>>? selectedFolderFiles) {
      if (selectedFolderFiles != null &&
          selectedFolderFiles.containsKey("files")) {
        // Save the root folder path (first directory in the list)
        if (controller.caoFilePath.text.isEmpty) {
          String rootFolderPath = selectedFolderFiles["files"]!.first;
          if (FileSystemEntity.isDirectorySync(rootFolderPath)) {
            controller.caoFilePath.text = rootFolderPath;
            caoStatus.value = _borderColor(controller.planFilePath);
          }
        }

        List<String> filePaths = selectedFolderFiles["files"]!;

        // Iterate through all files in the folder
        for (String filePath in filePaths) {
          if (controller.faoFilePath.text.isEmpty) {
            _selectFao(filePath);
          }
          if (controller.fileZPath.text.isEmpty) {
            _selectFileZ(filePath);
          }
          if (controller.planFilePath.text.isEmpty) {
            _selectPlan(filePath);
          }
        }

        // Recursively check subfolders
        // for (String filePath in filePaths) {
        //   if (FileSystemEntity.isDirectorySync(filePath)) {
        //     // If it's a directory, list its contents and check recursively
        //     List<FileSystemEntity> subFolderFiles =
        //         Directory(filePath).listSync();
        //     List<String> subFolderFilePaths =
        //         subFolderFiles.map((entity) => entity.path).toList();

        //     // Call _selectFilesFromFolder recursively for subfolders
        //     _selectFilesFromFolder({"files": subFolderFilePaths});
        //   }
        // }
        // logger.i({
        //   "caoFilePath == ": controller.caoFilePath,
        //   "fao == ": controller.faoFilePath,
        //   "Z file == ": controller.fileZPath,
        //   "plan == ": controller.planFilePath,
        // });
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
            FilePickerWidget(
              status: caoStatus.value,
              type: "folder",
              buttonText: "CAO*",
              onPick: _selectFilesFromFolder,
            ),
            FilePickerWidget(
              status: faoStatus.value,
              buttonText: "FAO*",
              onPick: _selectFao,
            ),
            FilePickerWidget(
              status: fileZStatus.value,
              buttonText: "File Z*",
              onPick: _selectFileZ,
            ),
            FilePickerWidget(
              status: planStatus.value,
              buttonText: "Plan*",
              onPick: _selectPlan,
            ),
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
