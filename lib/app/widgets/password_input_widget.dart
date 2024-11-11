import 'package:flutter/material.dart';

class CustomPasswordInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const CustomPasswordInput({
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
        obscureText: true, // Hide text for password input
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.lock), // Icon for password input
        ),
        validator: validator, // Validation logic for the password
      ),
    );
  }
}
