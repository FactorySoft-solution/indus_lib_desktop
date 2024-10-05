import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerButton extends StatefulWidget {
  final String buttonText;
  final Color buttonColor;
  final TextStyle? textStyle;
  final Function(String?)?
      onFilePicked; // Callback to handle the selected file path

  const FilePickerButton({
    super.key,
    required this.buttonText,
    this.buttonColor = Colors.blue,
    this.textStyle,
    this.onFilePicked,
  });

  @override
  _FilePickerButtonState createState() => _FilePickerButtonState();
}

class _FilePickerButtonState extends State<FilePickerButton> {
  String? _selectedFilePath;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });

      // Trigger the callback with the selected file path
      if (widget.onFilePicked != null) {
        widget.onFilePicked!(_selectedFilePath);
      }
    } else {
      // User canceled the picker
      setState(() {
        _selectedFilePath = null;
      });

      if (widget.onFilePicked != null) {
        widget.onFilePicked!(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.buttonColor, // Custom button color
          ),
          child: Text(
            widget.buttonText,
            style: widget.textStyle ?? const TextStyle(color: Colors.white),
          ),
        ),
        if (_selectedFilePath != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Selected file: $_selectedFilePath',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          )
      ],
    );
  }
}
