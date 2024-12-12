import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/widgets/sidebar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class MainView extends GetView<HomeController> {
  // final LocalStorageService _localStorageService = LocalStorageService();
  MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ligthColor,
      body: Center(
        child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SidebarWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
