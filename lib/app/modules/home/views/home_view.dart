import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/core/values/app_text_styles.dart';
import 'package:code_g/app/routes/app_pages.dart';
import 'package:code_g/app/widgets/clickable_widget.dart';
import 'package:code_g/app/widgets/icon_botton_widget.dart';
import 'package:code_g/app/widgets/service_card.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  // final LocalStorageService _localStorageService = LocalStorageService();
  HomeView({super.key});

  final paths = [
    {
      "path": "/",
      "image": "assets/cards/db.png",
      "label": "Base de données des pièces fabriquées en atelier",
    },
    {
      "path": "/",
      "image": "assets/cards/files.png",
      "label": "Base de données du catalogue des fournisseurs d’outils",
    },
    {
      "path": "/",
      "image": "assets/cards/folders.png",
      "label":
          "Base de données de catalogues et de spécifications de machines et de Mv",
    },
    {
      "path": "/",
      "image": "assets/cards/association.png",
      "label": "Base de données Robert pour les instructions générales",
    },
    {
      "path": "/",
      "image": "assets/cards/iso.png",
      "label":
          "Base de données de documents et de normes ISO Robert et STTR qualitè & moyen de controle",
    },
    {
      "path": "/",
      "image": "assets/cards/maintainer.png",
      "label":
          "Base de données de stock d’outillage avec mises à jour pour l’atelier STTR ( desktops & mobile )",
    },
    {
      "path": "/",
      "image": "assets/cards/dismensions.png",
      "label": "Générateur et calculateur de dimensions de contrôle moyennes",
    },
    {
      "path": "/",
      "image": "assets/cards/calculator.png",
      "label":
          "Calculateur des opérations spécifiques Robert (tronçage, filetage, taraudage, etc.)",
    },
  ];
  final paths2 = [
    {
      "path": "/",
      "image": "assets/cards/code_generator.png",
      "label": "Générateur de code pour la migration de machine",
    },
    {
      "path": "/",
      "image": "assets/cards/settings.png",
      "label": "Générateur de code pour la migration de machine",
    },
  ];
  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.purpleColor,
      appBar: AppBar(
        backgroundColor:
            AppColors.transparent, // Use a custom color with a hex code
        title: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
            color: AppColors.darkGray,
            width: 2,
          ))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClickableWidget(
                child: Text(
                  "Créer un nouveau compte",
                  style: AppTextStyles.caption.merge(const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  )),
                ),
                onTap: () {},
              ),
              IconButtonWidget(
                onPressed: () => {Get.toNamed(Routes.HOME)},
                imagePath: "assets/sttr/sttr_aerobase.svg",
                size: 15,
              ),
              ClickableWidget(
                child: Text(
                  "Déconnecté",
                  style: AppTextStyles.caption.merge(const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  )),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 500,
                height: 280,
                child: GridView.count(
                  crossAxisCount: 4, // Number of columns
                  crossAxisSpacing: 10, // Horizontal spacing between grid items
                  mainAxisSpacing: 10, // Vertical spacing between grid items
                  childAspectRatio: 1.0, // Aspect ratio (width:height)
                  children: List.generate(
                    paths.length,
                    (index) {
                      return ServiceCardWidget(
                        width: 120,
                        height: 120,
                        imagePath: paths[index]['image'] ?? '',
                        text: paths[index]['label'] ?? '',
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ServiceCardWidget(
                      width: 120,
                      height: 120,
                      onTap: () {},
                      imagePath: paths2[0]['image'] ?? "",
                      text: paths2[0]['label'] ?? "",
                    ),
                    ServiceCardWidget(
                      width: 120,
                      onTap: () {},
                      imagePath: paths2[1]['image'] ?? "",
                      text: paths2[1]['label'] ?? "",
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
