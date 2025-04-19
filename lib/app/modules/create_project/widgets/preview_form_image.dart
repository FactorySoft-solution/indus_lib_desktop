import 'dart:io';
import 'package:flutter/material.dart';
import '../controllers/create_project_controller.dart';

class PreviewFormImage extends StatelessWidget {
  final CreateProjectController controller;
  final double width;
  final double height;

  const PreviewFormImage({
    Key? key,
    required this.controller,
    this.width = 500,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.form.text.isEmpty) {
      return const SizedBox.shrink();
    }

    try {
      final file = File(controller.form.text);
      if (!file.existsSync()) {
        return const SizedBox.shrink();
      }

      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.file(
          file,
          fit: BoxFit.cover,
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}
