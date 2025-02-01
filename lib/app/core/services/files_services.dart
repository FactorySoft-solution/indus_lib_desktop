import 'dart:io';

class FilesServices {
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

      for (var entity in entities) {
        if (entity is File) {
          print("File: ${entity.path}");
        } else if (entity is Directory) {
          print("Directory: ${entity.path}");
        }
      }
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
      // Get the file extension
      String extension = filePath.split('.').last.toLowerCase();

      // Initialize the list if the extension is not already in the map
      if (!filesByType.containsKey(extension)) {
        filesByType[extension] = [];
      }

      // Add the file path to the corresponding extension list
      filesByType[extension]!.add(filePath);
    }

    return filesByType;
  }
}
