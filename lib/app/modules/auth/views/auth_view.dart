import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/widgets/CustomCard.dart';
import 'package:code_g/app/widgets/back_button.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:code_g/app/widgets/icon_botton_widget.dart';
import 'package:code_g/app/widgets/password_input_widget.dart';
import 'package:code_g/app/widgets/text_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsform/gs_form/widget/form.dart';

import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  AuthView({super.key});
  late GSForm form;
  int id = 0;

  @override
  Widget build(BuildContext context) {
    final pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              IconButtonWidget(
                  size: 250,
                  onPressed: () => Get.toNamed("/"),
                  imagePath: "assets/logo.png"),
              CustomCard(
                width: pageWidth * 0.7,
                height: 500,
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
                    width: 550,
                    controller: controller.emailController,
                    label: "Nom d'utilisateur",
                    hint: "Entrez votre nom d'utilisateur",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomPasswordInput(
                    width: 550,
                    controller: controller.passwordController,
                    label: "Technical company name",
                    hint: "Entrez votre mot de passe",
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomButton(
                    text: "Se connecter",
                    onPressed: controller.getAllUsers,
                    // onPressed: controller.login,
                    // onPressed: () =>
                    //     controller.getUserByUsername("ahmahmedmili76@gmail.com"),
                    width: 550,
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
