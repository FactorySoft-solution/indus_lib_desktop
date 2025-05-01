import 'dart:io';

class ArcFileFinder {
  static Future<List<String>> findArcFiles(String folderPath) async {
    final directory = Directory(folderPath);
    final arcFiles = <String>[];
    await for (var entity in directory.list(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.arc')) {
        arcFiles.add(entity.path);
      }
    }
    return arcFiles;
  }

  static Future<List<String>> findPinceFilenames(String folderPath) async {
    final directory = Directory(folderPath);
    final pinceFiles = <String>[];
    await for (var entity in directory.list(recursive: true)) {
      bool isFile = entity is File;
      bool isPince = entity.path.toLowerCase().contains('pince');
      bool isArc = entity.path.toLowerCase().endsWith('.arc');
      bool isCb = entity.path.toLowerCase().contains('cb');
      bool isValid = isFile && isArc && !isCb;
      if (isValid) {
        pinceFiles.add(entity.path);
      }
    }
    return pinceFiles;
  }
}
