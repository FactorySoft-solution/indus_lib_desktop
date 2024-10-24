import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilePickerButton extends StatelessWidget {
  final String buttonText;
  final void Function() onPick;

  const FilePickerButton({
    Key? key,
    required this.buttonText,
    required this.onPick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPick,
      child: Text(buttonText),
    );
  }
}
