import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:flutter/material.dart';

class ServiceCardWidget extends StatelessWidget {
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final double? imageSize;
  final String imagePath;
  final String text;

  const ServiceCardWidget({
    super.key,
    required this.onTap,
    this.width,
    this.height,
    this.imageSize = 55,
    required this.imagePath,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [AppColors.lightPurple, AppColors.ligthColor],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: imageSize,
                width: imageSize,
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 250,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.blueLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
