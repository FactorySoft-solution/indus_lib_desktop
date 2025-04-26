import 'dart:async';

import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/routes/app_pages.dart';
import 'package:code_g/app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      // Get.to(HomeView());
      // print(Routes.HOME);
      // Get.offAllNamed(Routes.CREATEPROJECT);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.ligthColor,
        body: Padding(
          padding: const EdgeInsets.all(28.0),
          child: SingleChildScrollView(
              child: Center(
            child: Column(
              children: [
                Image.asset(
                  "assets/logo.png",
                  height: 100,
                  width: 100,
                ),
                const SizedBox(
                  height: 50,
                ),
                const AuthCard(),
              ],
            ),
          )),
        ));
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 800;

    void toUserLogin() {
      Get.toNamed(Routes.LOGIN, arguments: {"role": "user"});
    }

    void toAdminLogin() {
      Get.toNamed(Routes.LOGIN, arguments: {"role": "admin"});
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: 1000, // Max width for large screens
      ),
      decoration: const BoxDecoration(
        color: AppColors.ligthColor,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000), // Color with 20% opacity (#00000033)
            blurRadius: 8, // Softens the shadow
            offset: Offset(0, 0), // Offset in x and y direction
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 30 : 70,
          vertical: isSmallScreen ? 50 : 100,
        ),
        child: Column(
          children: [
            const Text(
              'Se Connecter',
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: String.fromEnvironment("SF Pro Display"),
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 45,
            ),
            isSmallScreen
                ? _buildVerticalLayout(toUserLogin, toAdminLogin)
                : _buildHorizontalLayout(toUserLogin, toAdminLogin),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(
      VoidCallback toUserLogin, VoidCallback toAdminLogin) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildUserSection(toUserLogin),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            width: 1,
            height: 200,
            decoration: const BoxDecoration(
              color: AppColors.darkColor,
            ),
          ),
        ),
        Expanded(
          child: _buildAdminSection(toAdminLogin),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(
      VoidCallback toUserLogin, VoidCallback toAdminLogin) {
    return Column(
      children: [
        _buildUserSection(toUserLogin),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Divider(
            color: AppColors.darkColor,
            thickness: 1,
          ),
        ),
        _buildAdminSection(toAdminLogin),
      ],
    );
  }

  Widget _buildUserSection(VoidCallback toUserLogin) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/auth/user.svg",
          semanticsLabel: 'user image',
          height: 150,
        ),
        const SizedBox(
          height: 15,
        ),
        CustomButton(
          color: AppColors.purpleColor,
          text: "Se connecter en tant qu'utilisateur",
          onPressed: toUserLogin,
        )
      ],
    );
  }

  Widget _buildAdminSection(VoidCallback toAdminLogin) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/auth/admin.svg",
          semanticsLabel: 'admin image',
          height: 150,
        ),
        const SizedBox(
          height: 15,
        ),
        CustomButton(
          text: "Se connecter en tant qu'administrateur",
          onPressed: toAdminLogin,
          color: AppColors.orangeColor,
        ),
      ],
    );
  }
}
