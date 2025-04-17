import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'dart:math' as Math;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'file_view_service.dart';

/// Service for searching "PINCE" in ARC files
class PinceSearchService {
  /// Find all .arc files in directory and subdirectories
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

  /// Find .arc files with "PINCE" or "PINCES" in their filenames
  static Future<List<String>> findPinceFilenames(String folderPath) async {
    final directory = Directory(folderPath);
    final pinceFiles = <String>[];

    await for (var entity in directory.list(recursive: true)) {
      if (entity is File &&
          entity.path.toLowerCase().endsWith('.arc') &&
          (path.basename(entity.path).toUpperCase().contains('PINCE') ||
              path.basename(entity.path).toUpperCase().contains('PINCES'))) {
        pinceFiles.add(entity.path);
      }
    }

    return pinceFiles;
  }

  /// Parse ARC file content and extract blocks separated by T followed by numbers
  static Future<Map<String, List<String>>> parseArcFileBlocks(
      String filePath) async {
    try {
      print('Starting to parse file: $filePath');
      final content = await File(filePath).readAsString();
      final blocks = <String, List<String>>{};

      // Split content by lines
      final lines = content.split('\n');
      print('Total lines in file: ${lines.length}');

      // RegExp to match T followed by numbers (e.g., T1, T2, T10, etc.)
      // Allow T values at the start of a line or after other text like "N260 T3"
      final tRegex = RegExp(r'(^|\s)T\d+');

      // Track current T value
      String currentTValue = '';
      List<String> currentBlockLines = [];

      // Debug counts
      int blockCount = 0;
      List<String> identifiedTValues = [];

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        // Check if line contains a T value
        final tMatches = tRegex.allMatches(line).toList();

        if (tMatches.isNotEmpty) {
          // Found a new T value - save previous block if it exists
          if (currentTValue.isNotEmpty && currentBlockLines.isNotEmpty) {
            blocks[currentTValue] = List.from(currentBlockLines);
            blockCount++;
            print(
                'Saved block $blockCount: $currentTValue with ${currentBlockLines.length} lines');
          }

          // Extract the T value and use it as the key
          String fullMatch = tMatches.first.group(0)!;
          currentTValue = fullMatch.trim().startsWith('T')
              ? fullMatch.trim()
              : fullMatch.trim().substring(fullMatch.trim().indexOf('T'));

          identifiedTValues.add(currentTValue);
          print('Found new T value: $currentTValue in line: $line');
          currentBlockLines = [line];
        } else if (currentTValue.isNotEmpty) {
          // Add line to current block
          currentBlockLines.add(line);
        }
      }

      // Add the last block
      if (currentTValue.isNotEmpty && currentBlockLines.isNotEmpty) {
        blocks[currentTValue] = List.from(currentBlockLines);
        blockCount++;
        print(
            'Saved last block $blockCount: $currentTValue with ${currentBlockLines.length} lines');
      }

      print(
          'Total blocks found: ${blocks.length}, Identified T values: ${identifiedTValues.join(", ")}');

      // If no blocks found, add a fallback to show some content
      if (blocks.isEmpty) {
        print('Warning: No blocks found in file');

        // Scan file for any T values we might have missed
        final allTValues = <String>{};
        for (var line in lines) {
          final matches = RegExp(r'T\d+').allMatches(line);
          for (var match in matches) {
            allTValues.add(match.group(0)!);
          }
        }

        if (allTValues.isNotEmpty) {
          print(
              'Found T values in file that were not extracted as blocks: ${allTValues.join(", ")}');

          // Try alternate extraction algorithm - group lines by their T value references
          for (var tValue in allTValues) {
            final tBlockLines = <String>[];
            for (var line in lines) {
              if (line.contains(tValue)) {
                tBlockLines.add(line);
              }
            }

            if (tBlockLines.isNotEmpty) {
              blocks[tValue] = tBlockLines;
              print(
                  'Created fallback block for $tValue with ${tBlockLines.length} lines');
            }
          }
        }

        // If still no blocks, add entire file as one block
        if (blocks.isEmpty && lines.isNotEmpty) {
          blocks['T0'] = lines;
          print(
              'Added entire file as fallback block T0 with ${lines.length} lines');
        }
      }

      return blocks;
    } catch (e) {
      print('Error parsing ARC file: $e');
      // Try with Latin-1 encoding if UTF-8 fails
      try {
        print('Trying with Latin-1 encoding');
        final bytes = await File(filePath).readAsBytes();
        final content = String.fromCharCodes(bytes);

        final blocks = <String, List<String>>{};
        final lines = content.split('\n');
        print('Total lines in file (Latin-1): ${lines.length}');

        // RegExp to match T values that start a line or appear after a space
        final tRegex = RegExp(r'(^|\s)T\d+');

        String currentTValue = '';
        List<String> currentBlockLines = [];
        int blockCount = 0;
        List<String> identifiedTValues = [];

        for (var i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          // Check if line contains a T value
          final tMatches = tRegex.allMatches(line).toList();

          if (tMatches.isNotEmpty) {
            // Found a new T value - save previous block if it exists
            if (currentTValue.isNotEmpty && currentBlockLines.isNotEmpty) {
              blocks[currentTValue] = List.from(currentBlockLines);
              blockCount++;
              print(
                  'Saved block $blockCount (Latin-1): $currentTValue with ${currentBlockLines.length} lines');
            }

            // Extract the T value and use it as the key
            String fullMatch = tMatches.first.group(0)!;
            currentTValue = fullMatch.trim().startsWith('T')
                ? fullMatch.trim()
                : fullMatch.trim().substring(fullMatch.trim().indexOf('T'));

            identifiedTValues.add(currentTValue);
            print('Found new T value (Latin-1): $currentTValue in line: $line');
            currentBlockLines = [line];
          } else if (currentTValue.isNotEmpty) {
            // Add line to current block
            currentBlockLines.add(line);
          }
        }

        // Add the last block
        if (currentTValue.isNotEmpty && currentBlockLines.isNotEmpty) {
          blocks[currentTValue] = List.from(currentBlockLines);
          blockCount++;
          print(
              'Saved last block $blockCount (Latin-1): $currentTValue with ${currentBlockLines.length} lines');
        }

        print(
            'Total blocks found (Latin-1): ${blocks.length}, Identified T values: ${identifiedTValues.join(", ")}');

        // If no blocks found, add a fallback
        if (blocks.isEmpty) {
          // Scan file for any T values we might have missed
          final allTValues = <String>{};
          for (var line in lines) {
            final matches = RegExp(r'T\d+').allMatches(line);
            for (var match in matches) {
              allTValues.add(match.group(0)!);
            }
          }

          if (allTValues.isNotEmpty) {
            print(
                'Found T values in file that were not extracted as blocks (Latin-1): ${allTValues.join(", ")}');

            // Try alternate extraction algorithm - group lines by their T value references
            for (var tValue in allTValues) {
              final tBlockLines = <String>[];
              for (var line in lines) {
                if (line.contains(tValue)) {
                  tBlockLines.add(line);
                }
              }

              if (tBlockLines.isNotEmpty) {
                blocks[tValue] = tBlockLines;
                print(
                    'Created fallback block for $tValue with ${tBlockLines.length} lines (Latin-1)');
              }
            }
          }

          // If still no blocks, add entire file as one block
          if (blocks.isEmpty && lines.isNotEmpty) {
            blocks['T0'] = lines;
            print(
                'Added entire file as fallback block T0 with ${lines.length} lines (Latin-1)');
          }
        }

        return blocks;
      } catch (e2) {
        print('Error parsing ARC file with alternative encoding: $e2');
        return {
          'Error': ['Impossible de lire le fichier: $e2']
        };
      }
    }
  }

  /// Find all .arc files with "PINCE" or "PINCES" in their filename
  static Future<Map<String, Map<String, List<String>>>>
      findPinceFilenamesInArcFiles(String folderPath) async {
    final pinceFiles = await findPinceFilenames(folderPath);
    final results = <String, Map<String, List<String>>>{};

    for (var filePath in pinceFiles) {
      final blocks = await parseArcFileBlocks(filePath);
      results[filePath] = blocks;
    }

    return results;
  }

  /// Extract folder path from project map
  static String getFolderPathFromProject(Map<String, dynamic> project) {
    String folderPath = '';

    // Try to get the copied folder path first
    if (project['copiedFolderPath'] != null &&
        project['copiedFolderPath'].toString().isNotEmpty) {
      folderPath = project['copiedFolderPath'].toString();
    }
    // Fall back to project path if copied folder path is not available
    else if (project['projectPath'] != null &&
        project['projectPath'].toString().isNotEmpty) {
      folderPath = project['projectPath'].toString();
    }

    return folderPath;
  }

  /// Show loading indicator
  static void showLoadingIndicator() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  /// Hide loading indicator
  static void hideLoadingIndicator() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Search for PINCE in ARC files
  static Future<void> searchPinceInArcFiles(
      BuildContext context, String folderPath) async {
    showLoadingIndicator();

    try {
      final pinceFiles = await findPinceFilenames(folderPath);

      if (pinceFiles.isEmpty) {
        hideLoadingIndicator();
        showNoMatchesFoundMessage();
        return;
      }

      print('Found ${pinceFiles.length} files with PINCE in the name:');
      for (var i = 0; i < Math.min(5, pinceFiles.length); i++) {
        print('  ${i + 1}. ${pinceFiles[i]}');
      }

      // Parse the first file that contains "PINCE" in its name
      final filePath = pinceFiles[0];
      print('Parsing file: $filePath');
      final blocks = await parseArcFileBlocks(filePath);

      hideLoadingIndicator();

      // Show the operations table directly
      _showOperationsTable(context, blocks, filePath);
    } catch (e) {
      hideLoadingIndicator();
      print('Error during search: $e');
      showErrorMessage('Erreur lors de la recherche: $e');
    }
  }

  /// Search for PINCE in project's ARC files
  static Future<void> searchPinceInProjectArcFiles(
      BuildContext context, Map<String, dynamic> project) async {
    final folderPath = getFolderPathFromProject(project);

    if (folderPath.isNotEmpty) {
      await searchPinceInArcFiles(context, folderPath);
    } else {
      showErrorMessage('Aucun chemin de dossier valide trouvé');
    }
  }

  /// Show message when no matches found
  static void showNoMatchesFoundMessage() {
    Get.snackbar(
      'Recherche terminée',
      'Aucun fichier .arc avec "PINCE" ou "PINCES" dans le nom trouvé',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show error message using snackbar
  static void showErrorMessage(String message) {
    Get.snackbar(
      'Erreur',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  /// Show search results dialog
  static void showPinceSearchResults(
      BuildContext context, Map<String, Map<String, List<String>>> results) {
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
                  const Text(
                    'Fichiers .arc avec "PINCE" ou "PINCES" dans le nom',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              Text(
                '${results.length} fichiers trouvés',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: results.keys.length,
                  itemBuilder: (context, index) {
                    final filePath = results.keys.elementAt(index);
                    final blocks = results[filePath]!;
                    final fileName = path.basename(filePath);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(
                          fileName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${blocks.length} blocs trouvés',
                          style: const TextStyle(fontSize: 12),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chemin: $filePath',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Divider(),
                                // Display blocks in a tabular format
                                _buildOperationsTable(blocks),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.list),
                                      label: const Text('Voir Blocs'),
                                      onPressed: () {
                                        _showBlocksList(
                                            context, blocks, filePath);
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      icon: const Icon(Icons.open_in_new),
                                      label:
                                          const Text('Voir le fichier complet'),
                                      onPressed: () {
                                        FileViewService.showArcFilePreview(
                                            context, filePath);
                                      },
                                    ),
                                  ],
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
            ],
          ),
        ),
      ),
    );
  }

  /// Build a table for the operation blocks
  static Widget _buildOperationsTable(Map<String, List<String>> blocks) {
    print('Building operations table with ${blocks.length} blocks');

    // Extract operations data from blocks
    final operations = <Map<String, String>>[];

    // Sort blocks by their T number
    final blockKeys = blocks.keys.toList();
    print('Block keys before sorting: $blockKeys');

    blockKeys.sort((a, b) {
      if (!a.startsWith('T') || !b.startsWith('T')) {
        if (a == 'Header') return -1;
        if (b == 'Header') return 1;
        if (a == 'Error') return -1;
        if (b == 'Error') return 1;
        return a.compareTo(b);
      }

      try {
        final numA = int.parse(a.substring(1));
        final numB = int.parse(b.substring(1));
        return numA.compareTo(numB);
      } catch (e) {
        print('Error sorting block keys: $e');
        return a.compareTo(b);
      }
    });

    print('Block keys after sorting: $blockKeys');

    // Filter out non-T blocks, but keep T0 if it's a fallback
    final tBlocks = blockKeys
        .where((key) => key.startsWith('T') || key == 'Error')
        .toList();
    print('T blocks: $tBlocks');

    // Process each block
    for (var i = 0; i < tBlocks.length; i++) {
      final tKey = tBlocks[i];
      final blockLines = blocks[tKey]!;

      print('Processing block $tKey with ${blockLines.length} lines');
      if (blockLines.isNotEmpty) {
        print('First line: ${blockLines[0]}');
      }

      // Create operation data
      final operation = <String, String>{
        'numeroOP': (i + 1).toString(),
        'correcteurOP': '',
        'titreOP': '',
        'outilOP': '',
        'bpCb': '',
      };

      // First, look for MSG lines with text in quotes - this is the primary approach
      for (var j = 0; j < Math.min(30, blockLines.length); j++) {
        final String line = blockLines[j];

        // Check if it's a MSG line with text in quotes
        if (line.contains('MSG(') && line.contains('"')) {
          print('Found MSG line: $line');

          // Extract everything between quotes
          final msgRegex = RegExp(r'MSG\("([^"]*)"\)');
          final msgMatch = msgRegex.firstMatch(line);

          if (msgMatch != null && msgMatch.group(1) != null) {
            String msgText = msgMatch.group(1)!;
            print('Text inside MSG quotes: "$msgText"');

            // Remove leading slash if present
            if (msgText.startsWith('/')) {
              msgText = msgText.substring(1).trim();
              print('Removed leading slash: "$msgText"');
            }

            // Use this as titre OP
            operation['titreOP'] = msgText;
            print('EXTRACTED TITLE FROM MSG: "${operation['titreOP']}"');

            // Extract D value from the title
            final dMatch = RegExp(r'D\d+').firstMatch(msgText);
            if (dMatch != null) {
              operation['correcteurOP'] = dMatch.group(0)!;
              print(
                  'Extracted correcteur from title: ${operation['correcteurOP']}');
            }

            break;
          }
        }
      }

      // If no MSG found, look for D values in any line
      if (operation['titreOP']!.isEmpty) {
        for (var j = 0; j < Math.min(20, blockLines.length); j++) {
          final String line = blockLines[j];

          // First, get the correcteur D value if it exists
          final dMatch = RegExp(r'D\d+').firstMatch(line);
          if (dMatch != null && operation['correcteurOP']!.isEmpty) {
            final dValue = dMatch.group(0)!;
            operation['correcteurOP'] = dValue;
            print('Found correcteur in line: $dValue');
          }

          // Look for text that might be a title
          if (line.toUpperCase().contains('EBAUCHE') ||
              line.toUpperCase().contains('FINITION') ||
              line.toUpperCase().contains('PERCAGE') ||
              line.toUpperCase().contains('TOURNAGE')) {
            String title = line;
            // Remove any N and T values
            title = title
                .replaceAll(RegExp(r'N\d+'), '')
                .replaceAll(RegExp(r'T\d+'), '');

            // Remove any leading slashes and trim
            if (title.startsWith('/')) {
              title = title.substring(1);
            }

            title = title.trim();
            if (title.isNotEmpty && operation['titreOP']!.isEmpty) {
              operation['titreOP'] = title;
              print('FALLBACK TITLE: "${operation['titreOP']}"');
            }
          }
        }
      }

      // Fallback for correcteur if none found
      if (operation['correcteurOP']!.isEmpty) {
        operation['correcteurOP'] = tKey;
        print('Using T value as correcteur: $tKey');
      }

      // Check for BP/CB in the titre
      String titreOP = operation['titreOP']!.toUpperCase();
      if (titreOP.contains('BROCHE PRINCIPALE')) {
        operation['bpCb'] = 'BP';
        print('Found BP in titre');
      } else if (titreOP.contains('CONTRE BROCHE')) {
        operation['bpCb'] = 'CB';
        print('Found CB in titre');
      }

      // If BP/CB not found in titre, look in other lines
      if (operation['bpCb']!.isEmpty) {
        for (var j = 0; j < Math.min(20, blockLines.length); j++) {
          final String line = blockLines[j].toUpperCase();

          if (line.contains('BROCHE PRINCIPALE')) {
            operation['bpCb'] = 'BP';
            print('Found BP in line');
            break;
          } else if (line.contains('CONTRE BROCHE')) {
            operation['bpCb'] = 'CB';
            print('Found CB in line');
            break;
          } else if (line.contains(' BP') || line.endsWith('BP')) {
            operation['bpCb'] = 'BP';
            print('Found BP abbreviation');
            break;
          } else if (line.contains(' CB') || line.endsWith('CB')) {
            operation['bpCb'] = 'CB';
            print('Found CB abbreviation');
            break;
          }
        }
      }

      // Look for tool information
      for (var j = 0; j < Math.min(20, blockLines.length); j++) {
        final line = blockLines[j];
        if (line.toUpperCase().contains('CNMG') ||
            line.toUpperCase().contains('R050') ||
            line.contains('Ø') ||
            RegExp(r'Ø\s*\d').hasMatch(line) ||
            line.contains('S532')) {
          operation['outilOP'] = line;
          print('Found outilOP: "${operation["outilOP"]}"');
          break;
        }
      }

      operations.add(operation);
    }

    print('Total operations: ${operations.length}');

    // Create a table with the operations
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: operations.isEmpty
            ? Container(
                width: 500,
                height: 200,
                alignment: Alignment.center,
                child: const Text(
                  'Aucune opération trouvée. Vérifiez que le fichier contient des blocs T valides.',
                  textAlign: TextAlign.center,
                ),
              )
            : DataTable(
                headingRowColor:
                    MaterialStateProperty.all(Colors.grey.shade200),
                border: TableBorder.all(color: Colors.grey.shade300),
                columnSpacing: 16,
                columns: const [
                  DataColumn(
                      label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Numéro\nOP', textAlign: TextAlign.center),
                  )),
                  DataColumn(
                      label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Correcteur\nOP', textAlign: TextAlign.center),
                  )),
                  DataColumn(
                      label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Titre OP', textAlign: TextAlign.center),
                  )),
                  DataColumn(
                      label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Outil OP', textAlign: TextAlign.center),
                  )),
                  DataColumn(
                      label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('BP/CB', textAlign: TextAlign.center),
                  )),
                  DataColumn(
                      label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Consulter\nOP', textAlign: TextAlign.center),
                  )),
                ],
                rows: operations.map((op) {
                  final index = int.parse(op['numeroOP']!) - 1;
                  final blockKey = tBlocks[index];

                  return DataRow(
                    cells: [
                      DataCell(Center(child: Text(op['numeroOP'] ?? ''))),
                      DataCell(Center(child: Text(op['correcteurOP'] ?? ''))),
                      DataCell(Text(op['titreOP'] ?? '')),
                      DataCell(Text(op['outilOP'] ?? '')),
                      DataCell(Center(child: Text(op['bpCb'] ?? ''))),
                      DataCell(
                        Center(
                          child: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              _showBlockContent(
                                  blockKey, blocks[blockKey] ?? []);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
      ),
    );
  }

  /// Show the content of a specific block
  static void _showBlockContent(String blockKey, List<String> blockLines) {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Code ARC: $blockKey',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.content_copy),
                        tooltip: 'Copier le code',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                            text: blockLines.join('\n'),
                          ));
                          Get.snackbar(
                            'Copié',
                            'Code copié dans le presse-papiers',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
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
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      blockLines.join('\n'),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: Colors.lightGreenAccent,
                        height: 1.5,
                      ),
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

  /// Show a list of all blocks with buttons to view each one
  static void _showBlocksList(
      BuildContext context, Map<String, List<String>> blocks, String filePath) {
    // Sort blocks by their N number and T value
    final blockKeys = blocks.keys.toList()
      ..sort((a, b) {
        if (a == 'Header') return -1;
        if (b == 'Header') return 1;
        if (a == 'Error') return -1;
        if (b == 'Error') return 1;

        try {
          // Extract N numbers first for major sorting
          final nRegexA = RegExp(r'N(\d+)').firstMatch(a);
          final nRegexB = RegExp(r'N(\d+)').firstMatch(b);

          if (nRegexA != null && nRegexB != null) {
            final nCompare = int.parse(nRegexA.group(1)!)
                .compareTo(int.parse(nRegexB.group(1)!));
            if (nCompare != 0) return nCompare; // Different N values, sort by N

            // Same N values, sort by T if present
            final tRegexA = RegExp(r'T(\d+)').firstMatch(a);
            final tRegexB = RegExp(r'T(\d+)').firstMatch(b);

            if (tRegexA != null && tRegexB != null) {
              return int.parse(tRegexA.group(1)!)
                  .compareTo(int.parse(tRegexB.group(1)!));
            } else if (tRegexA != null) {
              return 1; // A has T, B doesn't, A comes after
            } else if (tRegexB != null) {
              return -1; // B has T, A doesn't, B comes after
            }
          }

          // If we don't have N numbers, try T numbers directly
          final tRegexA = RegExp(r'T(\d+)').firstMatch(a);
          final tRegexB = RegExp(r'T(\d+)').firstMatch(b);

          if (tRegexA != null && tRegexB != null) {
            return int.parse(tRegexA.group(1)!)
                .compareTo(int.parse(tRegexB.group(1)!));
          }

          // Default comparison
          return a.compareTo(b);
        } catch (e) {
          return a.compareTo(b);
        }
      });

    // Group blocks by N value for display
    final groupedBlocks = <String, List<String>>{};

    for (var key in blockKeys) {
      if (key == 'Header' || key == 'Error') {
        groupedBlocks[key] = [key];
        continue;
      }

      final nMatch = RegExp(r'N\d+').firstMatch(key);
      if (nMatch != null) {
        final nValue = nMatch.group(0)!;
        if (!groupedBlocks.containsKey(nValue)) {
          groupedBlocks[nValue] = [];
        }
        groupedBlocks[nValue]!.add(key);
      } else {
        // Standalone block (shouldn't happen with new parser)
        if (!groupedBlocks.containsKey('Other')) {
          groupedBlocks['Other'] = [];
        }
        groupedBlocks['Other']!.add(key);
      }
    }

    // Sort the groupedBlocks keys
    final groupKeys = groupedBlocks.keys.toList()
      ..sort((a, b) {
        if (a == 'Header') return -1;
        if (b == 'Header') return 1;
        if (a == 'Error') return -1;
        if (b == 'Error') return 1;
        if (a == 'Other') return 1;
        if (b == 'Other') return -1;

        try {
          final nRegexA = RegExp(r'N(\d+)').firstMatch(a);
          final nRegexB = RegExp(r'N(\d+)').firstMatch(b);

          if (nRegexA != null && nRegexB != null) {
            return int.parse(nRegexA.group(1)!)
                .compareTo(int.parse(nRegexB.group(1)!));
          }

          return a.compareTo(b);
        } catch (e) {
          return a.compareTo(b);
        }
      });

    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Blocs de code ARC: ${path.basename(filePath)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                child: groupKeys.isEmpty
                    ? const Center(child: Text('Aucun bloc trouvé'))
                    : ListView.builder(
                        itemCount: groupKeys.length,
                        itemBuilder: (context, index) {
                          final groupKey = groupKeys[index];
                          final groupItems = groupedBlocks[groupKey]!;

                          if (groupKey == 'Header' || groupKey == 'Error') {
                            // Special handling for header and error blocks
                            final blockKey = groupItems.first;
                            final blockLines = blocks[blockKey]!;
                            if (blockLines.isEmpty)
                              return const SizedBox.shrink();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              color: groupKey == 'Header'
                                  ? Colors.blue.shade50
                                  : Colors.red.shade50,
                              child: InkWell(
                                onTap: () {
                                  Get.back();
                                  _showBlockContent(blockKey, blockLines);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              blockKey,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              blockLines.take(1).join('\n'),
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 12,
                                                color: Colors.blueGrey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${blockLines.length} lignes',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.code,
                                          color: Colors.blue),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Group of blocks with the same N value
                            return ExpansionTile(
                              title: Text(
                                'Bloc $groupKey',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '${groupItems.length} correcteurs',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              initiallyExpanded:
                                  index == 0, // Expand first group
                              children: groupItems.map((blockKey) {
                                final blockLines = blocks[blockKey]!;
                                if (blockLines.isEmpty)
                                  return const SizedBox.shrink();

                                // Extract T value from the block key
                                final tMatch =
                                    RegExp(r'T\d+').firstMatch(blockKey);
                                final tValue =
                                    tMatch != null ? tMatch.group(0)! : '';

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: InkWell(
                                    onTap: () {
                                      Get.back();
                                      _showBlockContent(blockKey, blockLines);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .blue.shade100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        tValue,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        blockKey,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  blockLines.first,
                                                  style: const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 12,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '${blockLines.length} lignes',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.code,
                                              color: Colors.blue),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.table_rows),
                    label: const Text('Voir tableau d\'opérations'),
                    onPressed: () {
                      Get.back();
                      _showOperationsTable(context, blocks, filePath);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show operations table view
  static void _showOperationsTable(
      BuildContext context, Map<String, List<String>> blocks, String filePath) {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Operations: ${path.basename(filePath)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Expanded(
                child: _buildOperationsTable(blocks),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text('Voir Blocs'),
                    onPressed: () {
                      Get.back();
                      _showBlocksList(context, blocks, filePath);
                    },
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.code),
                    label: const Text('Voir Fichier Complet'),
                    onPressed: () {
                      Get.back();
                      showCompleteFileContent(context, blocks, filePath);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show complete file content in a dialog
  static Future<void> showCompleteFileContent(BuildContext context,
      Map<String, List<String>> blocks, String filePath) async {
    try {
      // Show loading indicator
      showLoadingIndicator();

      // Read file content
      String content;
      try {
        content = await File(filePath).readAsString();
      } catch (e) {
        print('Error reading file with UTF-8: $e');
        // Try with Latin-1 encoding if UTF-8 fails
        try {
          final bytes = await File(filePath).readAsBytes();
          content = String.fromCharCodes(bytes);
        } catch (e2) {
          print('Error reading file with Latin-1: $e2');
          hideLoadingIndicator();
          showErrorMessage('Impossible de lire le fichier: $e2');
          return;
        }
      }

      // Hide loading indicator
      hideLoadingIndicator();

      // Show content in dialog
      Get.dialog(
        Dialog(
          child: Container(
            width: Get.width * 0.9,
            height: Get.height * 0.9,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Fichier complet: ${path.basename(filePath)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.content_copy),
                          tooltip: 'Copier le contenu',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                              text: content,
                            ));
                            Get.snackbar(
                              'Copié',
                              'Contenu copié dans le presse-papiers',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
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
                const SizedBox(height: 8),
                Text(
                  'Chemin: $filePath',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        content,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: Colors.lightGreenAccent,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.table_rows),
                      label: const Text('Voir Tableau d\'Opérations'),
                      onPressed: () {
                        Get.back();
                        _showOperationsTable(context, blocks, filePath);
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.list),
                      label: const Text('Voir Blocs'),
                      onPressed: () {
                        Get.back();
                        _showBlocksList(context, blocks, filePath);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error showing file content: $e');
      showErrorMessage('Erreur lors de l\'affichage du fichier: $e');
    }
  }
}
