import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/back_button.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:code_g/app/widgets/icon_widget.dart';
import 'package:code_g/app/widgets/password_input_widget.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final logoSize = isSmallScreen ? 150.0 : 250.0;
    final cardWidth = isSmallScreen ? size.width * 0.9 : size.width * 0.7;
    final cardHeight = isSmallScreen ? 450.0 : 500.0;
    final inputWidth = isSmallScreen ? cardWidth * 0.8 : 550.0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              IconWidget(size: logoSize, imagePath: "assets/logo.png"),
              CustomCard(
                width: cardWidth,
                height: cardHeight,
                children: [
                  Row(
                    children: [
                      CostumBackButton(
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Se Connecter",
                    style: AppTextStyles.headline1,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextInput(
                    width: inputWidth,
                    controller: controller.emailController,
                    label: "Nom d'utilisateur",
                    hint: "Entrez votre nom d'utilisateur",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomPasswordInput(
                    width: inputWidth,
                    controller: controller.passwordController,
                    label: "Technical company name",
                    hint: "Entrez votre mot de passe",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    text: "Se connecter",
                    onPressed: controller.login,
                    width: inputWidth,
                    height: 50,
                    color: AppColors.purpleColor,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
