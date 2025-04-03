import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/modules/create_project/views/create_project_view.dart';
import 'package:code_g/app/modules/create_project/views/resume_project_view.dart';
import 'package:code_g/app/modules/robert_method/controllers/robert_method_controller.dart';
import 'package:code_g/app/modules/robert_method/views/filtage_calculator.dart';
import 'package:code_g/app/modules/robert_method/views/robert_method_view.dart';
import 'package:code_g/app/modules/search_piece/views/search_view.dart';
import 'package:code_g/app/widgets/pdf_to_html_converter.dart';
import 'package:code_g/app/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../controllers/home_controller.dart';

class MainView extends GetView<HomeController> {
  MainView({super.key});
  final logger = new Logger();
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(
                    () {
                      // logger.i(controller.activePage.value);
                      switch (controller.activePage.value) {
                        case 'Ajouter une mouvelle pièce':
                          return CreateProjectView();
                        case 'Ajouter une mouvelle pièce/resume-project':
                          return ResumeProjectView();
                        case 'Recherche avancée':
                          return SearchView();
                        case 'Calculateur Méthode Robert':
                          // Initialize controller before returning view
                          if (!Get.isRegistered<RobertMethodController>()) {
                            Get.put(RobertMethodController());
                          }
                          return const RobertMethodView();
                        case 'Calculateur Filtage':
                          if (!Get.isRegistered<RobertMethodController>()) {
                            Get.put(RobertMethodController());
                          }
                          return const FiltageCalculatorView();
                        default:
                          return PdfToHtmlConverter();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
