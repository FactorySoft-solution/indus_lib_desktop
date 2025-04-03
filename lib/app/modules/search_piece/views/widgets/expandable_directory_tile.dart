import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class ExpandableDirectoryTile extends StatefulWidget {
  final Directory directory;
  final Function(String) onImageTap;
  final Function(String) onPdfTap;

  const ExpandableDirectoryTile({
    Key? key,
    required this.directory,
    required this.onImageTap,
    required this.onPdfTap,
  }) : super(key: key);

  @override
  ExpandableDirectoryTileState createState() => ExpandableDirectoryTileState();
}

class ExpandableDirectoryTileState extends State<ExpandableDirectoryTile> {
  bool isExpanded = false;
  bool? hasContents;

  @override
  void initState() {
    super.initState();
    _checkContents();
  }

  Future<void> _checkContents() async {
    try {
      final contents = await widget.directory.list().length;
      if (mounted) {
        setState(() {
          hasContents = contents > 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasContents = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.folder, color: Colors.amber),
          title: Text(
            path.basename(widget.directory.path),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          trailing: hasContents == null
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : hasContents == true
                  ? IconButton(
                      icon: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                    )
                  : const SizedBox(width: 40),
          onTap: hasContents == true
              ? () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                }
              : null,
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: FutureBuilder<List<FileSystemEntity>>(
            future: widget.directory.list().toList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(left: 56.0),
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(left: 56.0),
                  child: Text('Dossier vide'),
                );
              }

              final sortedEntities = snapshot.data!
                ..sort((a, b) {
                  // Directories come first
                  final aIsDir = a is Directory;
                  final bIsDir = b is Directory;
                  if (aIsDir && !bIsDir) return -1;
                  if (!aIsDir && bIsDir) return 1;
                  // Then sort by name
                  return path.basename(a.path).compareTo(path.basename(b.path));
                });

              return Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Column(
                  children: sortedEntities.map((entity) {
                    if (entity is Directory) {
                      return ExpandableDirectoryTile(
                        directory: entity,
                        onImageTap: widget.onImageTap,
                        onPdfTap: widget.onPdfTap,
                      );
                    }

                    final fileName = path.basename(entity.path);
                    final extension = path.extension(fileName).toLowerCase();

                    IconData icon;
                    switch (extension) {
                      case '.pdf':
                        icon = Icons.picture_as_pdf;
                        break;
                      case '.jpg':
                      case '.jpeg':
                      case '.png':
                        icon = Icons.image;
                        break;
                      case '.doc':
                      case '.docx':
                        icon = Icons.description;
                        break;
                      case '.xls':
                      case '.xlsx':
                        icon = Icons.table_chart;
                        break;
                      default:
                        icon = Icons.insert_drive_file;
                    }

                    return ListTile(
                      leading: Icon(icon, color: Colors.blueGrey),
                      title: Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      subtitle: Text(
                        '${(File(entity.path).lengthSync() / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        if (['.jpg', '.jpeg', '.png'].contains(extension)) {
                          widget.onImageTap(entity.path);
                        } else if (extension == '.pdf') {
                          widget.onPdfTap(entity.path);
                        }
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
