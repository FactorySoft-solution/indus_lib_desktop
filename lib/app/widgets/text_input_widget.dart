import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const CustomTextInput({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.text_fields), // Icon for text input
        ),
        validator: validator, // Validation logic for the field
      ),
    );
  }
}
