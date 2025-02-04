import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_html/flutter_html.dart';

class PdfToHtmlConverter extends StatefulWidget {
  @override
  _PdfToHtmlConverterState createState() => _PdfToHtmlConverterState();
}

class _PdfToHtmlConverterState extends State<PdfToHtmlConverter> {
  String extractedText = "";
  bool isLoading = false;

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
      String jsonFilePath = "${file.parent.path}/extracted_text.json";

      await saveTextAsJson(extractedText, jsonFilePath);

      setState(() {
        extractedText =
            text.replaceAll("\n", "<br>"); // Convert new lines to HTML
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Saves the extracted text as a JSON file
  Future<void> saveTextAsJson(String text, String filePath) async {
    // Convert the extracted text to JSON format
    Map<String, dynamic> jsonData = {
      "extractedText": text,
    };

    // Convert the JSON data to a string
    String jsonString = jsonEncode(jsonData);

    // Save the JSON data to a file
    File jsonFile = File(filePath);
    await jsonFile.writeAsString(jsonString);
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
