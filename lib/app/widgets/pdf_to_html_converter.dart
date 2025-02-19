import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_html/flutter_html.dart';

class PdfToHtmlConverter extends StatefulWidget {
  @override
  _PdfToHtmlConverterState createState() => _PdfToHtmlConverterState();
}

class _PdfToHtmlConverterState extends State<PdfToHtmlConverter> {
  String extractedText = "";
  bool isLoading = false;
  var logger = Logger(
    printer: PrettyPrinter(),
  );
  Future<void> pickAndExtractText() async {
    setState(() {
      isLoading = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
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

      setState(() {
        extractedText = extractedHtml; // Store HTML in state
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, dynamic>? searchInArray(List<String> array, String searchKey) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].contains(searchKey)) {
        return {'value': array[i], 'index': i};
      }
    }
    return null; // Return null if no match is found
  }

  /// Saves text content to a file
  Future<void> saveTextToFile(String content, String filePath) async {
    File file = File(filePath);
    await file.writeAsString(content);
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
      } else if (line.contains("PositionDescriptionQuantitéListe de pièces")) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF to HTML Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickAndExtractText,
              child: Text("Select PDF"),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      child: Html(data: extractedText),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
