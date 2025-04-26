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

  final List<Map<String, String>> serviceCards = [
    {
      "path": "1",
      "image": "assets/cards/db.png",
      "label": "Base de données des pièces fabriquées en atelier",
    },
    // {
    //   "path": "2",
    //   "image": "assets/cards/files.png",
    //   "label": "Base de données du catalogue des fournisseurs d'outils",
    // },
    // {
    //   "path": "3",
    //   "image": "assets/cards/folders.png",
    //   "label":
    //       "Base de données de catalogues et de spécifications de machines et de Mv",
    // },
    // {
    //   "path": "4",
    //   "image": "assets/cards/association.png",
    //   "label": "Base de données Robert pour les instructions générales",
    // },
    // {
    //   "path": "5",
    //   "image": "assets/cards/iso.png",
    //   "label":
    //       "Base de données de documents et de normes ISO Robert et STTR qualitè & moyen de controle",
    // },
    // {
    //   "path": "6",
    //   "image": "assets/cards/maintainer.png",
    //   "label":
    //       "Base de données de stock d'outillage avec mises à jour pour l'atelier STTR ( desktops & mobile )",
    // },
    // {
    //   "path": "7",
    //   "image": "assets/cards/dismensions.png",
    //   "label": "Générateur et calculateur de dimensions de contrôle moyennes",
    // },
    {
      "path": "2",
      "image": "assets/cards/calculator.png",
      "label":
          "Calculateur des opérations spécifiques Robert (tronçage, filetage, taraudage, etc.)",
    },
    {
      "path": "3",
      "image": "assets/cards/calculator.png",
      "label":
          "Calculateur des opérations spécifiques Robert (tronçage, filetage, taraudage, etc.)",
    },
    {
      "path": "4",
      "image": "assets/cards/calculator.png",
      "label":
          "Calculateur des opérations spécifiques Robert (tronçage, filetage, taraudage, etc.)",
    },
    {
      "path": "5",
      "image": "assets/cards/code_generator.png",
      "label": "Générateur de code pour la migration de machine",
    },
  ];
  // final paths2 = [
  //   // {
  //   //   "path": "9",
  //   //   "image": "assets/cards/code_generator.png",
  //   //   "label": "Générateur de code pour la migration de machine",
  //   // },
  //   // {
  //   //   "path": "10",
  //   //   "image": "assets/cards/settings.png",
  //   //   "label": "Générateur de code pour la migration de machine",
  //   // },
  // ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildScaffold(context, constraints);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;

    // Define breakpoints
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;

    // Decreased card sizes for all screen sizes
    final cardSize = isSmallScreen
        ? 70.0
        : isMediumScreen
            ? 80.0
            : 100.0;
    final gridColumns = isSmallScreen
        ? 1
        : isMediumScreen
            ? 2
            : 4;
    final containerWidth = isSmallScreen
        ? screenWidth * 0.95
        : isMediumScreen
            ? screenWidth * 0.9
            : 1000.0;
    final gridPadding = isSmallScreen ? 5.0 : 10.0;

    return Scaffold(
      backgroundColor: AppColors.purpleColor,
      appBar: _buildAppBar(isSmallScreen),
      drawer: isSmallScreen ? _buildDrawer() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: containerWidth,
                    constraints: BoxConstraints(
                      maxHeight:
                          isSmallScreen ? screenWidth * 1.8 : screenWidth * 0.6,
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridColumns,
                        crossAxisSpacing: gridPadding,
                        mainAxisSpacing: gridPadding,
                        childAspectRatio: isSmallScreen ? 1.1 : 1.3,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: serviceCards.length,
                      itemBuilder: (context, index) {
                        return _buildServiceCard(
                          cardSize: cardSize,
                          cardData: serviceCards[index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required double cardSize,
    required Map<String, String> cardData,
  }) {
    return ClickableWidget(
      onTap: () => Get.toNamed(
        Routes.MAIN,
        arguments: {"page": cardData['path']},
      ),
      child: ServiceCardWidget(
        width: cardSize,
        height: cardSize,
        imagePath: cardData['image'] ?? '',
        text: cardData['label'] ?? '',
        onTap: () {},
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isSmallScreen) {
    return AppBar(
      backgroundColor: AppColors.transparent,
      title: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.darkGray,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isSmallScreen)
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
              onPressed: () => Get.toNamed(Routes.HOME),
              imagePath: "assets/sttr/sttr_aerobase.svg",
              size: isSmallScreen ? 20 : 15,
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
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.purpleColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu',
                  style: AppTextStyles.headline2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                IconButtonWidget(
                  onPressed: () => Get.toNamed(Routes.HOME),
                  imagePath: "assets/sttr/sttr_aerobase.svg",
                  size: 20,
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Créer un nouveau compte'),
            onTap: () {
              // Handle navigation
              Get.back();
            },
          ),
          ListTile(
            title: const Text('Déconnecté'),
            onTap: () {
              // Handle logout
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
