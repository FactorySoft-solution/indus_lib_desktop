import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final double? height;
  final double? width;
  final String label;
  final String hint;
  final Icon? prefixIcon;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const CustomTextInput({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.height,
    this.width,
    this.validator,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fallback to default screen width if not provided
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: width ?? screenWidth * 0.9, // Default to 90% of screen width
        height: height, // Height can be provided or left as flexible
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(),
            prefixIcon: prefixIcon, // Use the dynamic or default prefix icon
          ),
          validator: validator, // Validation logic for the field
        ),
      ),
    );
  }
}
