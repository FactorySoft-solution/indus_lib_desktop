import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:flutter/material.dart';
// import 'package:code_g/app/core/services/local_storage_service.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  // final LocalStorageService _localStorageService = LocalStorageService();
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            AppColors.primaryColor, // Use a custom color with a hex code
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/logo.png', // Update with the actual logo path
              height: 50,
            ),
            const SizedBox(width: 10),
            Text(
              'Home Page',
              style:
                  AppTextStyles.headline2.copyWith(color: AppColors.ligthColor),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: const Center(
          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     ElevatedButton(
          //       onPressed: () {
          //         Get.toNamed(Routes.CREATEPROJECT);
          //       },
          //       child: const Text('create project', style: AppTextStyles.button),
          //     ),
          //     const SizedBox(height: 20),
          //     ElevatedButton(
          //       onPressed: () {
          //         // Action for button 2
          //       },
          //       child: const Text(
          //         'Button 2',
          //         style: AppTextStyles.button,
          //       ),
          //     ),
          //     const SizedBox(height: 20),
          //     ElevatedButton(
          //       onPressed: () {
          //         // Action for button 3
          //       },
          //       child: const Text(
          //         'Button 3',
          //         style: AppTextStyles.button,
          //       ),
          //     ),
          //     FilePickerButton(
          //       buttonText: "file picker",
          //       onPick: () {},
          //     ),
          //   ],
          // ),

          ),
    );
  }
}
