import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/icon_botton_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CostumBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const CostumBackButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);
  back() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButtonWidget(
            onPressed: onPressed ?? back(),
            imagePath: "assets/black-arrow.svg"),
        const SizedBox(
          width: 10,
        ),
        Text(
          'Retour',
          style: AppTextStyles.subtitle1.merge(
            const TextStyle(
              color: AppColors.darkColor, // Override the color
            ),
          ),
        ),
      ],
    );
  }
}
