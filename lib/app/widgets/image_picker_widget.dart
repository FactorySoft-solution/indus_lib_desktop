import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final double? height;
  final double? width;
  final String label;
  final String hint;
  final Icon? prefixIcon;
  final TextEditingController controller;

  const ImagePickerWidget({
    Key? key,
    required this.label,
    required this.hint,
    this.height,
    this.width,
    this.prefixIcon,
    required this.controller,
  }) : super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
      widget.controller.text = _selectedImage!.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: widget.width ?? screenWidth * 0.9,
        height: widget.height,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            prefixIcon: widget.prefixIcon,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      )
                    : Text(
                        widget.hint,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.transparent),
                  elevation: WidgetStateProperty.all<double>(
                      0), // Optional: Removes the button shadow
                ),
                child: const Icon(Icons.upload),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
