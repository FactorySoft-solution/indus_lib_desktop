import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FC),
      body: Stack(
        children: [
          // Background dots pattern (optional, can be replaced with a Container if you have an asset)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                // You can use an image or a custom painter for dots
                // image: DecorationImage(
                //   image: AssetImage('assets/dots_bg.png'),
                //   fit: BoxFit.cover,
                // ),
                color: Color(0xFFF9F8FC),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ),

                  const SizedBox(height: 32),
                  Container(
                    width: pageWidth < 600 ? pageWidth * 0.95 : 540,
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Back button
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.black, size: 20),
                                label: const Text('Retour',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500)),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(60, 36),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Title
                          Text(
                            'Se Connecter',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 32,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          // Username
                          CustomTextField(
                            controller: controller.emailController,
                            label: "Nom d'utilisateur",
                            hint: "Entrez votre nom d'utilisateur",
                            prefix: const Icon(Icons.person_outline),
                            validator: controller.validateEmail,
                          ),
                          const SizedBox(height: 24),
                          // Password
                          Obx(() => CustomTextField(
                                controller: controller.passwordController,
                                label: "Technical company name",
                                hint: "Entrez votre mot de passe",
                                obscureText: controller.obscurePassword.value,
                                prefix: const Icon(Icons.lock_outline),
                                validator: controller.validatePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => controller.login(),
                                suffix: IconButton(
                                  icon: Icon(
                                    controller.obscurePassword.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed:
                                      controller.togglePasswordVisibility,
                                ),
                              )),
                          const SizedBox(height: 32),
                          // Login button
                          Obx(() => CustomButton(
                                text: "Se connecter",
                                onPressed: controller.login,
                                isLoading: controller.isLoading.value,
                                width: double.infinity,
                                height: 48,
                                backgroundColor: const Color(0xFF7B2FF2),
                                textColor: Colors.white,
                              )),
                          const SizedBox(height: 12),
                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Mot de passe oublié',
                                style: TextStyle(
                                  color: Color(0xFF7B2FF2),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(60, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // What is AeroBase STTR
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Qu'est-ce qu'AeroBase STTR ?",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(60, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Footer
                  Text(
                    '© 2024 AeroBase STTR. Pour toute question, contactez Amri Ahmed à : Amri.ahmed.sttr@gmail.com',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black38,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
