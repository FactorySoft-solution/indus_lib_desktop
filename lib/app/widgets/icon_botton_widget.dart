import 'package:flutter/material.dart';

class IconButtonWidget extends StatelessWidget {
  final VoidCallback onPressed; // The callback function to be triggered on tap
  final String imagePath; // Path to the image for the button
  final double size; // Size of the button
  final Color backgroundColor;
  const IconButtonWidget({
    super.key,
    required this.onPressed,
    required this.imagePath,
    this.size = 30.0, // Default size of the button
    this.backgroundColor = Colors.transparent, // Default size of the button
  });

  @override
  Widget build(BuildContext context) {
    // return GestureDetector(

    //   onTap: onPressed,
    //   child: Image.asset(
    //     imagePath, // Use the passed image path
    //     height: size, // Set size dynamically
    //     width: size, // Set size dynamically
    //   ),
    // );
    return Material(
      color: backgroundColor, // Set background color dynamically
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        child: Image.asset(
          imagePath,
          height: size, // Set size dynamically
          width: size, // Set size dynamically), // Button icon
        ),
      ),
    );
  }
}
