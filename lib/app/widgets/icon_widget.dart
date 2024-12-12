import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconWidget extends StatelessWidget {
  final String imagePath; // Path to the image for the button
  final double size; // Size of the button
  final Color backgroundColor;
  const IconWidget({
    super.key,
    required this.imagePath,
    this.size = 30.0, // Default size of the button
    this.backgroundColor = Colors.transparent, // Default size of the button
  });

  @override
  Widget build(BuildContext context) {
    String extonsion = imagePath.split('.').last;
    print('imagePath == $imagePath');
    print('extonsion == $extonsion');
    if (extonsion == 'svg') {
      return SvgPicture.asset(
        imagePath,
        placeholderBuilder: (context) => CircularProgressIndicator(),
      );
    } else {
      return Image.asset(
        imagePath,
        height: size, // Set size dynamically
        width: size, // Set size dynamically), // Button icon
      );
    }
  }
}
