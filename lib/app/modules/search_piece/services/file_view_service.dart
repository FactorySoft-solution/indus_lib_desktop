import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

/// Service for handling file preview functionality
class FileViewService {
  /// Show file preview for ARC files
  static void showArcFilePreview(BuildContext context, String filePath) {
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
                      'Code source: ${path.basename(filePath)}',
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
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copier le code',
                        onPressed: () async {
                          final content = await File(filePath).readAsString();
                          await Clipboard.setData(ClipboardData(text: content));
                          Get.snackbar(
                            'Succès',
                            'Code copié dans le presse-papiers',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: 'Ouvrir en plein écran',
                        onPressed: () {
                          Get.back();
                          Get.dialog(
                            Dialog.fullscreen(
                              child: Stack(
                                children: [
                                  FutureBuilder<String>(
                                    future: File(filePath).readAsString(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (snapshot.hasError) {
                                        return Center(
                                          child:
                                              Text('Erreur: ${snapshot.error}'),
                                        );
                                      }
                                      return Container(
                                        color: Colors.grey[900],
                                        padding: const EdgeInsets.all(16),
                                        child: SingleChildScrollView(
                                          child: SelectableText(
                                            snapshot.data ?? '',
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.copy,
                                              color: Colors.white),
                                          tooltip: 'Copier le code',
                                          onPressed: () async {
                                            final content = await File(filePath)
                                                .readAsString();
                                            await Clipboard.setData(
                                                ClipboardData(text: content));
                                            Get.snackbar(
                                              'Succès',
                                              'Code copié dans le presse-papiers',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                              duration:
                                                  const Duration(seconds: 2),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () => Get.back(),
                                        ),
                                      ],
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
                child: FutureBuilder<String>(
                  future: File(filePath).readAsString(),
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
                    return Container(
                      color: Colors.grey[900],
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          snapshot.data ?? '',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: Colors.white,
                          ),
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
}
