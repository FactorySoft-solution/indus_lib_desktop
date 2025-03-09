import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'shared_service.dart';

class FilesServices {
  Logger logger = new Logger();
  SharedService sharedService = new SharedService();
// Function to ensure a directory exists
  Future<Directory> ensureDirectory(String path) async {
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    return directory;
  }

  Future<String> registerFile(String sourceFilePath,
      [String? destinationDirectoryPath]) async {
    // Get the default desktop path
    String userProfile = Platform.environment['USERPROFILE'] ??
        '/home/${Platform.environment['USER']}';
    String defaultDesktopPath = "$userProfile/Desktop/aerobase";

    // Use the provided destination directory or fallback to the default desktop path
    String destination = destinationDirectoryPath ?? defaultDesktopPath;

    // Construct the destination file path
    String fileName = File(sourceFilePath).uri.pathSegments.last;
    String destinationFilePath = "$destination/$fileName";

    try {
      // Ensure the destination directory exists
      Directory(destination).createSync(recursive: true);

      // Copy the source file to the destination
      File(sourceFilePath).copySync(destinationFilePath);
      return destinationFilePath;
    } catch (e) {
      throw Exception("Error registering file: $e");
    }
  }

  /// Function to check if the selected path is a file, folder, or zip file.
  /// Returns a string indicating the type: "folder", "zip", or "file".
  Future<String> checkFileType(String path) async {
    try {
      FileSystemEntityType type = FileSystemEntity.typeSync(path);

      // Check if the path is a directory
      if (type == FileSystemEntityType.directory) {
        return "folder";
      }

      // Check if the path is a file
      if (type == FileSystemEntityType.file) {
        // Check if the file is a zip file
        if (path.toLowerCase().endsWith(".zip")) {
          return "zip";
        } else {
          return "file";
        }
      }

      // If the path does not exist or is neither a file nor a folder
      return "unknown";
    } catch (e) {
      throw Exception("Error checking file type: $e");
    }
  }

  /// Function to get a list of files inside a folder.
  /// [path] is the folder path.
  /// Returns a list of file paths.
  Future<List<String>> getFilesInFolder(String path) async {
    try {
      // Ensure the path is a directory
      Directory directory = Directory(path);

      if (!directory.existsSync()) {
        throw Exception("The folder does not exist: $path");
      }

      // Get all file system entities in the directory
      List<FileSystemEntity> entities = directory.listSync(recursive: false);

      // Filter to return only files
      List<String> files = entities
          .where((entity) => FileSystemEntity.isFileSync(entity.path))
          .map((entity) => entity.path)
          .toList();

      return files;
    } catch (e) {
      throw Exception("Error retrieving files: $e");
    }
  }

  List<FileSystemEntity> listFilesAndFolders(String directoryPath) {
    Directory directory = Directory(directoryPath);

    if (directory.existsSync()) {
      List<FileSystemEntity> entities = directory.listSync();
      return entities;
    } else {
      print("Directory does not exist");
      return [];
    }
  }

// select files inside provided folder then regroup their files by type
  Map<String, List<String>> regroupDirectoryFilesByType(String directoryPath) {
    // Create a map to store files grouped by their extensions
    Map<String, List<String>> filesByType = {};

    // Get the directory
    Directory directory = Directory(directoryPath);

    // Check if the directory exists
    if (directory.existsSync()) {
      // List all files in the directory
      List<FileSystemEntity> entities = directory.listSync();

      for (var entity in entities) {
        if (entity is File) {
          // Get the file extension
          String extension = entity.path.split('.').last.toLowerCase();

          // Initialize the list if the extension is not already in the map
          if (!filesByType.containsKey(extension)) {
            filesByType[extension] = [];
          }

          // Add the file path to the corresponding extension list
          filesByType[extension]!.add(entity.path);
        }
      }
    } else {
      print("Directory does not exist");
    }

    return filesByType;
  }

// regroupe provided files list by type
  Map<String, List<String>> regroupFilesByType(List<String> filePaths) {
    // Create a map to store files grouped by their extensions
    Map<String, List<String>> filesByType = {};

    for (var filePath in filePaths) {
      if (!FileSystemEntity.isDirectorySync(filePath)) {
        // Get the file extension
        String extension = filePath.split('.').last.toLowerCase();

        // Initialize the list if the extension is not already in the map
        if (!filesByType.containsKey(extension)) {
          filesByType[extension] = [];
        }
        // Add the file path to the corresponding extension list
        filesByType[extension]!.add(filePath);
      } else {
        // Initialize the list if the extension is not already in the map
        if (!filesByType.containsKey("dir")) {
          filesByType["dir"] = [];
        }
        // Add the file path to the corresponding extension list
        filesByType["dir"]!.add(filePath);
      }
    }

    return filesByType;
  }

  Future<FilePickerResult?> pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    return result;
  }

  Future<String> pickAndExtractPdfToHtml() async {
    FilePickerResult? result = await pickPdf();
    String extractedHtml = "";
    if (result != null) {
      extractedHtml = await ExtractPdfToHtml(result.files.single.path!);
    }
    return extractedHtml;
  }

  Future<String> ExtractPdfToHtml(String path) async {
    File file = File(path);
    final Uint8List bytes = await file.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    String text = PdfTextExtractor(document).extractText();
    // Convert extracted text to HTML format
    String extractedHtml = text.replaceAll("\n", "<br>");
    return extractedHtml;
  }

  List<Map<String, dynamic>> FileZProcessCorrecters(String line) {
    SharedService sharedService = new SharedService();
    var correctersList = line.split("Correcteur");

    List<Map<String, dynamic>> resultArray = [];
    correctersList.forEach((correcter) {
      if (correcter.trim().isEmpty) return; // Skip empty strings

      var data = correcter.split(':');
      if (data.length < 2) return; // Skip if no ':' is found

      var values = data[1].split(',');

      // Extract correcteur number
      var correcteurNumber =
          values[0].split("X")[0].replaceAll(RegExp(r'[^0-9]'), '');
      // if (values.length < 5) return; // Ensure there are enough values

      // Extract X value
      var x = values[0].split("X")[1] + "," + values[1];

      // Extract Z Nominal value
      var ZSerchresult = sharedService.searchInArray(values, "Z");

      var zIndex = ZSerchresult?["index"];
      var zArray = ZSerchresult?["value"];
      var zPart1Array = zArray.split("Z")[1];
      var zPart2Array =
          values[zIndex + 1].split("T.s")[0].replaceAll(RegExp(r'[^0-9]'), '');
      var zNominal = zPart1Array + ',' + zPart2Array;
      var result = sharedService.searchInArray(values, "T.b");
      var rayon = '-';

      if (result == null) {
        x = values[0].split("X")[1] + "," + zArray[1];
      } else {
        var tbArray = result['value'].split("T.b");
        bool containZ = result['value'].toString().toLowerCase().contains('z');
        var rayonExist = !containZ;
        if (rayonExist) {
          var rayonPart1 = tbArray[1].replaceAll(RegExp(r'[^0-9]'), '');
          var rayonPart2 = values[result['index'] + 1].split("Z")[0];
          rayon = rayonPart1 + "," + rayonPart2;
        }
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

  /// Saves content to a file
  Future<void> saveContentToFile(
    dynamic content,
    String filePath,
    String fileName,
    String extention,
  ) async {
    String path = "${filePath}/${fileName}.${extention}";
    File file = File(path);
    await file.writeAsString(jsonEncode(content));
  }

  /// Parses extracted text into structured JSON format
  Map<String, dynamic> parseExtractedFileZText(String text) {
    List<Map<String, dynamic>> entries = [];
    List<String> lines = text.split('<br>');

    Map<String, dynamic>? currentEntry;

    for (String line in lines) {
      if (line.contains("Numéro :")) {
        if (currentEntry != null) {
          entries.add(currentEntry);
        }
        currentEntry = {
          "numero": "",
          "operation": "-",
          "description": line.split("Numéro :")[1].trim(),
          "details": []
        };
      } else if (line.contains("Desc.:")) {
        currentEntry?["numero"] = line.split("Desc.:")[1].trim();
      } else if (line.contains("PositionDescriptionQuantitéListe de pièces")) {
        // Skip header
      } else if (line.contains("Correcteur")) {
        var result = FileZProcessCorrecters(line);
        currentEntry?["details"] = result;
      } else if (RegExp(r"^\d+").hasMatch(line)) {
        List<String> parts = line.split(RegExp(r"\s{2,}"));
        if (parts.length >= 2) {
          currentEntry?["details"].add({
            "position": parts[0].trim(),
            "description": parts[1].trim(),
          });
        }
      } else if (sharedService.stringStartsWithDAndNumber(line)) {
        var operation = line;
        if (line.contains(":")) {
          operation = operation.substring(0, operation.length - 3);
        } else {
          operation = operation.substring(0, operation.length - 2);
        }
        currentEntry?["operation"] = operation;
      }
    }

    if (currentEntry != null) {
      entries.add(currentEntry);
    }

    return {"entries": entries};
  }

  Future<Map<String, dynamic>> convertFileZHtmlToJson(path) async {
    // Convert extracted HTML format
    String extractedHtml = await ExtractPdfToHtml(path);
    // Convert extracted text to structured JSON
    Map<String, dynamic> structuredJson =
        parseExtractedFileZText(extractedHtml);
    final fileName = path.toString().split('\\').last.split('.').first;
    structuredJson['fileName'] = fileName;
    return structuredJson;
  }
}
