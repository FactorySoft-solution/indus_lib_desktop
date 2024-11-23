import 'dart:async';

import 'package:code_g/app/core/services/local_storage_service.dart';
import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/routes/app_pages.dart';
import 'package:code_g/app/widgets/icon_botton_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalStorageService _storageController = LocalStorageService();
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  _startAnimation() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _opacity = 1.0;
    });
    await Future.delayed(Duration(seconds: 2));
    navigateBasedOnFirstTime();
  }

  Future<void> navigateBasedOnFirstTime() async {
    bool isFirstTime = await _storageController.getFirstTime();
    if (isFirstTime) {
      Get.offAllNamed(Routes.AUTH);
    } else {
      await _storageController.saveFirstTime(true);
      _showWelcomeBackModal();
    }
  }

  void _showWelcomeBackModal() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        showDialog(
          context: context,
          barrierColor:
              const Color.fromARGB(148, 0, 0, 0), // Soft transparent background
          builder: (context) {
            final contextWidth = MediaQuery.of(context)
                .size
                .width; // Set width to 80% of the screen width
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16), // Optional, for rounded corners
              ),
              child: Stack(
                clipBehavior: Clip.none, // Allow overflow from the Dialog
                children: [
                  Container(
                    padding: const EdgeInsets.all(70),
                    constraints: BoxConstraints(
                        maxWidth:
                            contextWidth * 0.8), // Set max width of dialog
                    child: const SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Optimisez vos processus de fabrication avec AeroBase STTR",
                              style: TextStyle(
                                color: AppColors.darkColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          const Text(
                            "AeroBase STTR est une solution logicielle complète et personnalisée, conçue spécifiquement pour répondre aux besoins de tous les départements de STTR, y compris le bureau des méthodes, ainsi que pour les entreprises du groupe Rebert. Développée comme une application de bureau avec JavaScript et le Framework Flutter par une équipe de quatre personnes, AeroBase STTR centralise et simplifie la gestion des programmes machines liés à la fabrication des pièces. Cette application permet une gestion fluide des programmes, avec des outils de recherche avancés facilitant l'accès à l’historique des programmes, des versions et des modifications. En outre, elle intègre des fonctionnalités essentielles telles que la gestion des fiches outils Zoller et une interconnexion transparente avec les systèmes CAO (Conception Assistée par Ordinateur) et FAO (Fabrication Assistée par Ordinateur). Cette synergie entre la conception et la fabrication assure une meilleure coordination des processus. AeroBase STTR ne se limite pas à la gestion des programmes ; elle est également conçue pour résoudre les problèmes récurrents rencontrés dans l'entreprise, en optimisant les méthodes de travail dans tous les services. L'application facilite la collaboration et améliore la productivité globale, contribuant ainsi au maintien de la conformité avec les normes ISO, indispensables pour préserver la compétitivité de l’entreprise dans son secteur. En termes de sécurité, AeroBase STTR garantit une protection maximale des données sensibles, grâce à une base de données sécurisée et des protocoles stricts de confidentialité. Cette approche assure que les données clients sont traitées de manière confidentielle, en conformité avec les normes internationales de sécurité des informations. Conçue pour évoluer avec les besoins futurs de l’entreprise, AeroBase STTR est un outil flexible et scalable, offrant la possibilité d'ajouter de nouvelles fonctionnalités afin de répondre aux défis émergents et aux besoins croissants de l’industrie.",
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      right:
                          -10, // Position the button/image 10px from the right edge
                      top:
                          -10, // Position the button/image 10px from the top edge
                      child: IconButtonWidget(
                          backgroundColor: Colors.white,
                          onPressed: () => navigateBasedOnFirstTime(),
                          imagePath: "assets/bouton-fermer.png")),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ligthColor,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(seconds: 2), // Duration of the fade-in effect
          child: Image.asset(
            'assets/logo.png', // Replace with your image path
            height: 200,
            width: 200,
          ),
        ),
      ),
    );
  }
}
