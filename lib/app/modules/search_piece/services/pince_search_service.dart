import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'dart:math' as Math;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'file_view_service.dart';
import 'arc_file_parser.dart';
import 'arc_file_finder.dart';

/// Service for searching "PINCE" in ARC files
class PinceSearchService {
  /// Find all .arc files with "PINCE" or "PINCES" in their filename
  static Future<Map<String, Map<String, List<String>>>>
      findPinceFilenamesInArcFiles(String folderPath) async {
    final pinceFiles = await ArcFileFinder.findPinceFilenames(folderPath);
    final results = <String, Map<String, List<String>>>{};

    for (var filePath in pinceFiles) {
      final blocks = await ArcFileParser.parseArcFileBlocks(filePath);
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
      final pinceFiles = await ArcFileFinder.findPinceFilenames(folderPath);

      if (pinceFiles.isEmpty) {
        hideLoadingIndicator();
        showNoMatchesFoundMessage();
        return;
      }

      // Parse the first file that contains "PINCE" in its name
      final filePath = pinceFiles[0];
      final blocks = await ArcFileParser.parseArcFileBlocks(filePath);
      hideLoadingIndicator();

      // Show the operations table directly
      _showOperationsTable(context, blocks, filePath);
    } catch (e) {
      hideLoadingIndicator();
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

  /// Build a table for the operation blocks
  static Widget _buildOperationsTable(
      Map<String, List<String>> blocks, String filePath) {
    // Extract operations data from blocks
    final operations = <Map<String, String>>[];
    // Sort blocks by their T number
    final blockKeys = blocks.keys.toList();

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
        return a.compareTo(b);
      }
    });

    // Filter out non-T blocks, but keep T0 if it's a fallback
    final tBlocks = blockKeys
        .where((key) => key.startsWith('T') || key == 'Error')
        .toList();
    // Process each block
    for (var i = 0; i < tBlocks.length; i++) {
      final tKey = tBlocks[i];
      final blockLines = blocks[tKey]!;

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
        bool isValidLine = line.toLowerCase().contains('msg(') &&
            line.contains('"') &&
            RegExp(r'D\d+').hasMatch(line);
        if (isValidLine) {
          // Extract everything between quotes
          final msgRegex = RegExp(r'MSG\("([^"]*)"\)');
          final msgMatch = msgRegex.firstMatch(line);

          if (msgMatch != null && msgMatch.group(1) != null) {
            String msgText = msgMatch.group(1)!;

            // Remove leading slash if present
            if (msgText.startsWith('/')) {
              msgText = msgText.substring(1).trim();
            }

            // Use this as titre OP
            operation['titreOP'] = msgText.substring(3);
            // Start background search for matching operations in project.json files
            quickSearchOperations(msgText, filePath).then((matchingOperations) {
              if (matchingOperations.isNotEmpty) {
                operation['matchingProjects'] =
                    matchingOperations.length.toString();

                // Store the results for later use
                Get.put(matchingOperations, tag: 'matchingOps_$msgText');
              }
            });

            // Extract D value from the title
            final dMatch = RegExp(r'D\d+').firstMatch(msgText);
            if (dMatch != null) {
              operation['correcteurOP'] = dMatch.group(0)!;
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
            }
          }
        }
      }

      // Fallback for correcteur if none found
      if (operation['correcteurOP']!.isEmpty) {
        operation['correcteurOP'] = tKey;
      }

      // Check for BP/CB in the titre
      String titreOP = operation['titreOP']!.toUpperCase();
      if (titreOP.contains('BROCHE PRINCIPALE')) {
        operation['bpCb'] = 'BP';
      } else if (titreOP.contains('CONTRE BROCHE')) {
        operation['bpCb'] = 'CB';
      }

      // If BP/CB not found in titre, look in other lines
      if (operation['bpCb']!.isEmpty) {
        for (var j = 0; j < Math.min(20, blockLines.length); j++) {
          final String line = blockLines[j].toUpperCase();

          if (line.contains('BROCHE PRINCIPALE')) {
            operation['bpCb'] = 'BP';
            break;
          } else if (line.contains('CONTRE BROCHE')) {
            operation['bpCb'] = 'CB';
            break;
          } else if (line.contains(' BP') || line.endsWith('BP')) {
            operation['bpCb'] = 'BP';
            break;
          } else if (line.contains(' CB') || line.endsWith('CB')) {
            operation['bpCb'] = 'CB';
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
          break;
        }
      }

      operations.add(operation);
    }

    // Create a table with the operations
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 900,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
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
                        child:
                            Text('Correcteur\nOP', textAlign: TextAlign.center),
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
                        child: Text('Actions', textAlign: TextAlign.center),
                      )),
                    ],
                    rows: operations
                        .where((op) =>
                            op['titreOP'] != null &&
                            op['titreOP']!.isNotEmpty &&
                            op['bpCb'] != null &&
                            op['bpCb']!.isNotEmpty)
                        .map((op) {
                      final index = int.parse(op['numeroOP']!) - 1;
                      final blockKey = tBlocks[index];
                      return DataRow(
                        cells: [
                          DataCell(Center(child: Text(op['numeroOP'] ?? ''))),
                          DataCell(
                              Center(child: Text(op['correcteurOP'] ?? ''))),
                          DataCell(Text(op['titreOP']!)),
                          DataCell(Text(op['outilOP'] ?? '_')),
                          DataCell(Center(child: Text(op['bpCb'] ?? ''))),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.view_list),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Voir le contenu du bloc',
                                  onPressed: () {
                                    _showBlockContent(
                                        blockKey, blocks[blockKey] ?? []);
                                  },
                                ),
                                const SizedBox(width: 8),
                                if (op['titreOP'] != null &&
                                    op['titreOP']!.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.find_in_page,
                                        color: Colors.blue),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip:
                                        'Rechercher cette opération dans le project.json',
                                    onPressed: () {
                                      searchOperationInProjectJson(
                                          op['titreOP']!, filePath);
                                    },
                                  ),
                                if (op['matchingProjects'] != null)
                                  const SizedBox(width: 8),
                                if (op['matchingProjects'] != null)
                                  InkWell(
                                    onTap: () {
                                      final matchingOps =
                                          Get.find<List<Map<String, dynamic>>>(
                                        tag: 'matchingOps_${op['titreOP']}',
                                      );
                                      if (matchingOps.isNotEmpty) {
                                        Get.dialog(
                                          AlertDialog(
                                            title: Text(
                                                'Opérations correspondant à "${op['titreOP']}"'),
                                            content: SizedBox(
                                              width: 900,
                                              height: 500,
                                              child: SingleChildScrollView(
                                                child:
                                                    _buildStaticProjectOperationsTable(
                                                        matchingOps,
                                                        op['titreOP']!),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Get.back(),
                                                child: const Text('Fermer'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.green.shade600),
                                      ),
                                      child: Text(
                                        '${op['matchingProjects']} projets',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
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
                child: _buildOperationsTable(blocks, filePath),
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
        // Try with Latin-1 encoding if UTF-8 fails
        try {
          final bytes = await File(filePath).readAsBytes();
          content = String.fromCharCodes(bytes);
        } catch (e2) {
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
      showErrorMessage('Erreur lors de l\'affichage du fichier: $e');
    }
  }

  /// Load and search operations in project.json files
  static Future<List<Map<String, dynamic>>> findOperationsInProjectJson(
      String titreOp, String projectPath) async {
    try {
      // Look for project.json file in the folder or parent folder
      final directory = Directory(projectPath);
      String? projectJsonPath;
      print('projectPath $projectPath');
      // Check if the folder exists
      if (await directory.exists()) {
        // First check in current directory
        var projectFile = File(path.join(directory.path, 'project.json'));
        if (await projectFile.exists()) {
          projectJsonPath = projectFile.path;
        } else {
          // Check in parent directory
          var parentDir = directory.parent;
          projectFile = File(path.join(parentDir.path, 'project.json'));
          if (await projectFile.exists()) {
            projectJsonPath = projectFile.path;
          }
        }
      }

      // If project.json not found, return empty list
      if (projectJsonPath == null) {
        return [];
      }

      // Read and parse the project.json file
      final jsonContent = await File(projectJsonPath).readAsString();
      final projectData = jsonDecode(jsonContent) as Map<String, dynamic>;

      // Extract operations data
      List<Map<String, dynamic>> results = [];

      if (projectData.containsKey('operations') &&
          projectData['operations'] is List) {
        final operations =
            List<Map<String, dynamic>>.from(projectData['operations']);

        // Find operations matching the titre
        for (var operation in operations) {
          if (operation.containsKey('operation') &&
              operation['operation']
                  .toString()
                  .toLowerCase()
                  .contains(titreOp.toLowerCase())) {
            // Add project context to the operation
            final result = {
              ...operation,
              'projectInfo': {
                'pieceRef': projectData['pieceRef'] ?? '',
                'pieceIndice': projectData['pieceIndice'] ?? '',
                'pieceName': projectData['pieceName'] ?? '',
                'machine': projectData['machine'] ?? '',
                'projectPath': projectJsonPath,
              }
            };

            results.add(result);
          }
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Open project.json file and search for matching operations
  static void searchOperationInProjectJson(
      String titreOp, String? projectPath) async {
    print("titreOp: $titreOp");
    try {
      // Show a loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      String userProfile = Platform.environment['USERPROFILE'] ??
          '\\home\\${Platform.environment['USER']}';
      String searchPath;
      if (projectPath != null) {
        var parts = projectPath.split(RegExp(r'[\\/]+'));
        if (parts.length > 2) {
          searchPath =
              parts.sublist(0, parts.length - 2).join(Platform.pathSeparator);
        } else {
          searchPath = projectPath;
        }
      } else {
        searchPath = "$userProfile\\Desktop\\aerobase";
      }

      // Search for operations in project.json
      final operations = await findOperationsInProjectJson(titreOp, searchPath);
      print("operations: $operations");
      // Close the loading indicator
      Get.back();

      if (operations.isEmpty) {
        Get.snackbar(
          'Aucune opération trouvée',
          'Aucune opération correspondant à "$titreOp" n\'a été trouvée dans le fichier project.json',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Show the results in a dialog
      Get.dialog(
        AlertDialog(
          title: Text('Opérations correspondant à "$titreOp"'),
          content: SizedBox(
            width: 900,
            height: 500,
            child: SingleChildScrollView(
              child: _buildStaticProjectOperationsTable(operations, titreOp),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close the loading indicator in case of error
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Erreur',
        'Impossible de rechercher l\'opération dans le fichier project.json: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Build a table for operations found in project.json
  static Widget _buildStaticProjectOperationsTable(
      List<Map<String, dynamic>> operations, String searchQuery) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: operations.isEmpty
          ? Container(
              width: 500,
              height: 50,
              alignment: Alignment.center,
              child: Text(
                'Aucune opération correspondant à "$searchQuery" trouvée dans le fichier project.json',
                textAlign: TextAlign.center,
              ),
            )
          : DataTable(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnSpacing: 16,
              columns: const [
                DataColumn(
                    label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Pièce Ref', textAlign: TextAlign.center),
                )),
                DataColumn(
                    label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Indice', textAlign: TextAlign.center),
                )),
                DataColumn(
                    label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Opération', textAlign: TextAlign.center),
                )),
                DataColumn(
                    label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Display Operation', textAlign: TextAlign.center),
                )),
                DataColumn(
                    label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Type TopSolide', textAlign: TextAlign.center),
                )),
                DataColumn(
                    label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Arrosage', textAlign: TextAlign.center),
                )),
                DataColumn(
                    label: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Actions', textAlign: TextAlign.center),
                )),
              ],
              rows: operations.map((op) {
                return DataRow(
                  cells: [
                    DataCell(Text(op['projectInfo']['pieceRef'] ?? '')),
                    DataCell(Text(op['projectInfo']['pieceIndice'] ?? '')),
                    DataCell(Text(op['operation'] ?? '')),
                    DataCell(Text(op['displayOperation'] ?? '')),
                    DataCell(Text(op['topSolideOperation'] ?? '')),
                    DataCell(Text(op['arrosageType'] ?? '')),
                    DataCell(
                      Center(
                        child: IconButton(
                          icon: const Icon(Icons.folder_open),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _openProjectFolder(
                                op['projectInfo']['projectPath']);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  /// Open the folder containing the project file
  static void _openProjectFolder(String? projectFilePath) {
    if (projectFilePath == null || projectFilePath.isEmpty) return;

    try {
      final dir = path.dirname(projectFilePath);
      Process.run('explorer.exe', [dir]);
    } catch (e) {
      print('Error opening project folder: $e');
    }
  }

  /// Directly search for matching operations in all project.json files
  static Future<List<Map<String, dynamic>>> quickSearchOperations(
      String operationTitle, String filePath) async {
    try {
      // Extract directory path from file path
      List<String> pathParts = filePath.split('\\');
      pathParts.removeLast(); // Remove the file name (last element)
      pathParts.removeLast(); // Remove the file name (last element)
      String baseSearchPath = pathParts.join('\\');
      final results = <Map<String, dynamic>>[];
      final directory = Directory(baseSearchPath);

      // Find all project.json files
      final projectFiles = <String>[];
      await for (var entity in directory.list(recursive: true)) {
        if (entity is File &&
            path.basename(entity.path).toLowerCase() == 'project.json') {
          projectFiles.add(entity.path);
        }
      }
      // Process each project file
      for (var projectFile in projectFiles) {
        try {
          final content = await File(projectFile).readAsString();
          final projectData = jsonDecode(content) as Map<String, dynamic>;

          // Check if the project has operations data
          if (projectData.containsKey('operations') &&
              projectData['operations'] is List) {
            final operations =
                List<Map<String, dynamic>>.from(projectData['operations']);

            // Match operation data with operationTitle
            for (var operation in operations) {
              String operationTitleLower =
                  operationTitle.toLowerCase().substring(3);
              String operationLower =
                  operation['operation'].toString().toLowerCase();
              bool isMatch = operationLower.contains(operationTitleLower);
              if (isMatch) {
                // Add project context to the operation data
                final result = {
                  ...operation,
                  'projectInfo': {
                    'pieceRef': projectData['pieceRef'] ?? '',
                    'pieceIndice': projectData['pieceIndice'] ?? '',
                    'pieceName': projectData['pieceName'] ?? '',
                    'machine': projectData['machine'] ?? '',
                    'projectPath': projectFile,
                  }
                };
                results.add(result);
              }
            }
          }
        } catch (e) {
          print("Error processing project file: $projectFile - $e");
        }
      }

      return results;
    } catch (e) {
      print("Error searching for operations: $e");
      return [];
    }
  }

  /// Find specific file path in search results
  static Map<String, List<String>>? findFilePathInResults(
      Map<String, Map<String, List<String>>> results, String searchPath) {
    // Exact match
    if (results.containsKey(searchPath)) {
      return results[searchPath];
    }

    // Case insensitive partial match
    final lowerSearchPath = searchPath.toLowerCase();
    for (var filePath in results.keys) {
      if (filePath.toLowerCase().contains(lowerSearchPath)) {
        return results[filePath];
      }
    }

    return null;
  }

  /// Search for a specific file path and display its contents
  static Future<void> searchAndDisplayFilePath(
      BuildContext context, String folderPath, String specificFilePath) async {
    showLoadingIndicator();

    try {
      final file = File(specificFilePath);

      if (await file.exists() && file.path.toLowerCase().endsWith('.arc')) {
        final blocks = await ArcFileParser.parseArcFileBlocks(specificFilePath);

        hideLoadingIndicator();

        // Show the operations table directly
        _showOperationsTable(context, blocks, specificFilePath);
      } else {
        // If exact file not found, try to find files with similar name
        final pinceFiles = await ArcFileFinder.findPinceFilenames(folderPath);
        final fileName = path.basename(specificFilePath);

        // Filter files that contain the specified filename
        final matchingFiles = pinceFiles
            .where((filePath) => path.basename(filePath).contains(fileName))
            .toList();

        if (matchingFiles.isNotEmpty) {
          final blocks =
              await ArcFileParser.parseArcFileBlocks(matchingFiles[0]);

          hideLoadingIndicator();
          _showOperationsTable(context, blocks, matchingFiles[0]);
        } else {
          hideLoadingIndicator();
          showErrorMessage('Fichier "$fileName" non trouvé');
        }
      }
    } catch (e) {
      hideLoadingIndicator();
      showErrorMessage('Erreur lors de la recherche du fichier: $e');
    }
  }

  /// Search all ARC files in a specific folder and display them
  static Future<void> searchArcFilesInFolder(
      BuildContext context, String folderPath) async {
    showLoadingIndicator();

    try {
      final directory = Directory(folderPath);

      if (!await directory.exists()) {
        hideLoadingIndicator();
        showErrorMessage('Dossier introuvable: $folderPath');
        return;
      }

      final arcFiles = await ArcFileFinder.findArcFiles(folderPath);

      hideLoadingIndicator();

      if (arcFiles.isEmpty) {
        showNoMatchesFoundMessage();
        return;
      }

      // Show file selection dialog
      _showFileSelectionDialog(context, arcFiles);
    } catch (e) {
      hideLoadingIndicator();
      showErrorMessage('Erreur lors de la recherche: $e');
    }
  }

  /// Show file selection dialog to choose which ARC file to view
  static void _showFileSelectionDialog(
      BuildContext context, List<String> arcFiles) {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.7,
          height: Get.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Fichiers ARC trouvés',
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
                '${arcFiles.length} fichiers trouvés',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Filtrer les fichiers...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                ),
                onChanged: (value) {
                  // Could implement filtering functionality here
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: arcFiles.length,
                  itemBuilder: (context, index) {
                    final filePath = arcFiles[index];
                    final fileName = path.basename(filePath);
                    return Card(
                      child: ListTile(
                        leading:
                            const Icon(Icons.description, color: Colors.blue),
                        title: Text(fileName),
                        subtitle: Text(
                          filePath,
                          style: const TextStyle(fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async {
                          Get.back(); // Close the dialog
                          showLoadingIndicator();
                          try {
                            final blocks =
                                await ArcFileParser.parseArcFileBlocks(
                                    filePath);
                            hideLoadingIndicator();
                            _showOperationsTable(context, blocks, filePath);
                          } catch (e) {
                            hideLoadingIndicator();
                            showErrorMessage(
                                'Erreur lors de l\'analyse du fichier: $e');
                          }
                        },
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
}
