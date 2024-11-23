import 'package:flutter/material.dart';
import 'package:code_g/app/core/values/app_colors.dart';

class AppTextStyles {
  // Headline text style (e.g., for titles or headings)
  static const TextStyle headline1 = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.darkColor,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: AppColors.darkColor,
  );

  // Subtitle text style
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
  );

  // Body text style (e.g., for general content)
  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.darkColor,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.darkColor,
  );

  // Button text style
  static const TextStyle button = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Caption text style (e.g., for small, secondary information)
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: Colors.grey,
  );
  static const TextStyle blueLabel = TextStyle(
    fontSize: 7.0,
    fontWeight: FontWeight.w700,
    color: AppColors.purpleColor,
  );
}
