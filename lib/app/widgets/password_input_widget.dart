import 'package:flutter/material.dart';

class CustomPasswordInput extends StatefulWidget {
  final double? height;
  final double? width;
  final String label;
  final String hint;
  final Icon? prefixIcon;

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  const CustomPasswordInput({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.height,
    this.width,
    this.prefixIcon,
  }) : super(key: key);

  @override
  _CustomPasswordInputState createState() => _CustomPasswordInputState();
}

class _CustomPasswordInputState extends State<CustomPasswordInput> {
  bool _isPasswordVisible = false; // Tracks whether the password is visible

  @override
  Widget build(BuildContext context) {
    // Fallback to default screen width if not provided
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width:
            widget.width ?? screenWidth * 0.9, // Default to 90% of screen width
        height: widget.height, // Height can be provided or left as flexible
        child: TextFormField(
          controller: widget.controller,
          obscureText: !_isPasswordVisible, // Hide or show password text
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: const OutlineInputBorder(),
            prefixIcon: widget.prefixIcon, // Icon for password input
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                // Toggle the visibility state
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          validator: widget.validator, // Validation logic for the password
        ),
      ),
    );
  }
}
