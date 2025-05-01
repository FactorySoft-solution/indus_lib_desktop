import 'dart:io';

class ArcFileParser {
  static Future<Map<String, List<String>>> parseArcFileBlocks(
      String filePath) async {
    try {
      print("try block ...");
      final content = await File(filePath).readAsString();
      final blocks = <String, List<String>>{};
      final lines = content.split('\n');
      final tRegex = RegExp(r'(^|\s)T\d+');
      String currentTValue = '';
      List<String> currentBlockLines = [];
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final tMatches = tRegex.allMatches(line).toList();
        bool validBlock = false;
        if (tMatches.isNotEmpty) {
          // Check next line for MSG("/CY or MSG("/PU and D\d+
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1].trim();
            if ((nextLine.contains('MSG("/CY') ||
                    nextLine.contains('MSG("/PU')) &&
                RegExp(r'D\d+').hasMatch(nextLine)) {
              validBlock = true;
            }
          }
        }
        if (tMatches.isNotEmpty && validBlock) {
          if (currentTValue.isNotEmpty && currentBlockLines.isNotEmpty) {
            String blockKey = currentTValue;
            int suffix = 1;
            while (blocks.containsKey(blockKey)) {
              blockKey = '${currentTValue}_T_$suffix';
              suffix++;
            }
            blocks[blockKey] = List.from(currentBlockLines);
          }
          String fullMatch = tMatches.first.group(0)!;
          currentTValue = fullMatch.trim().startsWith('T')
              ? fullMatch.trim()
              : fullMatch.trim().substring(fullMatch.trim().indexOf('T'));
          currentBlockLines = [line];
        } else if (currentTValue.isNotEmpty) {
          currentBlockLines.add(line);
        }
      }
      if (currentTValue.isNotEmpty && currentBlockLines.isNotEmpty) {
        String blockKey = currentTValue;
        int suffix = 1;
        while (blocks.containsKey(blockKey)) {
          blockKey = '${currentTValue}_T_$suffix';
          suffix++;
        }
        blocks[blockKey] = List.from(currentBlockLines);
      }
      if (blocks.isEmpty) {
        final allTValues = <String>{};
        for (var line in lines) {
          final matches = RegExp(r'T\d+').allMatches(line);
          for (var match in matches) {
            allTValues.add(match.group(0)!);
          }
        }
        if (allTValues.isNotEmpty) {
          for (var tValue in allTValues) {
            final tBlockLines = <String>[];
            for (var line in lines) {
              if (line.contains(tValue)) {
                tBlockLines.add(line);
              }
            }
            if (tBlockLines.isNotEmpty) {
              blocks[tValue] = tBlockLines;
            }
          }
        }
        // if (blocks.isEmpty && lines.isNotEmpty) {
        //   blocks['T0'] = lines;
        // }
      }
      return blocks;
    } catch (e) {
      print("catch block 1 ...");
      try {
        print("try block 2 ...");
        print("filePath $filePath");
        bool isR200 = filePath.toUpperCase().contains("R200");
        bool isG160 = filePath.toUpperCase().contains("G160");
        final bytes = await File(filePath).readAsBytes();
        final content = String.fromCharCodes(bytes);
        final blocks = <String, List<String>>{};
        final lines = content.split('\n');
        final tRegex = isG160 ? RegExp(r'(^|\s)T\d+') : RegExp(r'STEP_\d+');
        String currentTValue = '';
        List<String> currentBlockLines = [];
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final tMatches = tRegex.allMatches(line).toList();

          if (tMatches.isNotEmpty) {
            if (currentTValue.isNotEmpty && currentBlockLines.isNotEmpty) {
              String blockKey = currentTValue;
              int suffix = 1;
              while (blocks.containsKey(blockKey)) {
                blockKey = '${currentTValue}_T_$suffix';
                suffix++;
              }
              blocks[blockKey] = List.from(currentBlockLines);
            }
            String fullMatch = tMatches.first.group(0)!;
            currentTValue = fullMatch.trim().startsWith('T')
                ? fullMatch.trim()
                : fullMatch.trim().substring(fullMatch.trim().indexOf('T'));
            currentBlockLines = [line];
          } else if (currentTValue.isNotEmpty) {
            currentBlockLines.add(line);
          }
        }
        if (currentTValue.isNotEmpty && currentBlockLines.isNotEmpty) {
          String blockKey = currentTValue;
          int suffix = 1;
          while (blocks.containsKey(blockKey)) {
            blockKey = '${currentTValue}_T_$suffix';
            suffix++;
          }
          blocks[blockKey] = List.from(currentBlockLines);
        }
        // if (blocks.isEmpty) {
        //   final allTValues = <String>{};
        //   for (var line in lines) {
        //     final matches = RegExp(r'T\d+').allMatches(line);
        //     for (var match in matches) {
        //       allTValues.add(match.group(0)!);
        //     }
        //   }
        //   if (allTValues.isNotEmpty) {
        //     for (var tValue in allTValues) {
        //       final tBlockLines = <String>[];
        //       for (var line in lines) {
        //         if (line.contains(tValue)) {
        //           tBlockLines.add(line);
        //         }
        //       }
        //       if (tBlockLines.isNotEmpty) {
        //         blocks[tValue] = tBlockLines;
        //       }
        //     }
        //   }
        //   if (blocks.isEmpty && lines.isNotEmpty) {
        //     blocks['T0'] = lines;
        //   }
        // }

        return blocks;
      } catch (e2) {
        print("catch block 2 ... ");
        return {
          'Error': ['Impossible de lire le fichier: $e2']
        };
      }
    }
  }
}
