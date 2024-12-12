import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/icon_widget.dart';
import 'package:flutter/material.dart';

class SidebarListItemWidget extends StatelessWidget {
  final String LabelText; // Path to the image for the button
  final String Icon; // Path to the image for the button
  final bool isActive; // Indicates whether the item is active
  SidebarListItemWidget({
    super.key,
    required this.LabelText,
    this.Icon = 'assets/sidebar/search.svg',
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 285,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.darkPurpleColor, AppColors.purpleColor]),
        border: Border(
          left: BorderSide(
            color: AppColors.ligthColor,
            width: isActive == true ? 5 : 0,
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 25,
                height: 25,
                child: Center(
                  child: IconWidget(
                    imagePath: Icon,
                    size: 10,
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                LabelText,
                style: isActive
                    ? AppTextStyles.button
                    : AppTextStyles.button.merge(const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
