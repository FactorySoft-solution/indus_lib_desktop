import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/modules/create_project/views/create_project_view.dart';
import 'package:code_g/app/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class MainView extends GetView<HomeController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageWidth = MediaQuery.of(context).size.width;
    final pageHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.ligthColor,
      body: Center(
        child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SidebarWidget(),
              SizedBox(
                width: pageWidth * 0.79,
                height: pageHeight,
                // decoration: BoxDecoration(color: Colors.black45),
                child: const Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CreateProjectView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
