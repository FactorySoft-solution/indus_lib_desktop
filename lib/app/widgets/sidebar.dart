import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/modules/home/controllers/home_controller.dart';
import 'package:code_g/app/widgets/clickable_widget.dart';
import 'package:code_g/app/widgets/icon_widget.dart';
import 'package:code_g/app/widgets/sidebar-list-item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SidebarWidget extends StatelessWidget {
  SidebarWidget({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> sideBarItems1 = [
    {"text": 'Recherche avancée', "icon": 'assets/sidebar/search.svg'},
    {"text": 'Formes de pièces', "icon": 'assets/sidebar/piece_forms.svg'},
    {"text": 'Matières premières', "icon": 'assets/sidebar/material.svg'},
    {"text": 'Liste des programmes', "icon": 'assets/sidebar/programs.svg'},
  ];

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final contextHeight = MediaQuery.of(context).size.height;

    return Container(
      height: contextHeight,
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.purpleColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: SingleChildScrollView(
          child: Column(
        children: [
          const Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: IconWidget(
              imagePath: "assets/arobase-sttr.svg",
            ),
          ),
          Container(
            height: 15,
            width: 250,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.softPurpleColor,
                  width: 1,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 370,
                child: Column(
                  children: [
                    SizedBox(
                      height: 270,
                      child: ListView.builder(
                        itemCount: sideBarItems1.length,
                        itemBuilder: (context, index) {
                          final item = sideBarItems1[index];
                          return Column(
                            children: [
                              const SizedBox(height: 15),
                              Obx(() {
                                final isActive = controller.activePage.value
                                    .contains(item['text']);
                                return ClickableWidget(
                                  onTap: () {
                                    controller.updateActivePage(
                                        item['text'] as String);
                                  },
                                  child: SidebarListItemWidget(
                                    Icon: item['icon'] as String,
                                    isActive: isActive,
                                    LabelText: item['text'] as String,
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Obx(() {
                      final isActive =
                          controller.activePage.value == 'Paramètres';
                      return ClickableWidget(
                        onTap: () {
                          controller.updateActivePage('Paramètres');
                        },
                        child: SidebarListItemWidget(
                          Icon: 'assets/sidebar/params.svg',
                          isActive: isActive,
                          LabelText: 'Paramètres',
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 70,
                      width: 250,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.softPurpleColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: const IconWidget(
                        imagePath: "assets/arobase-sttr.svg",
                      ),
                    ),
                    Expanded(
                      // height: 220,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Obx(() {
                            final isActive = controller.activePage.value ==
                                'Ajouter une mouvelle pièce';
                            return ClickableWidget(
                              onTap: () {
                                controller.updateActivePage(
                                    'Ajouter une mouvelle pièce');
                              },
                              child: SidebarListItemWidget(
                                Icon: 'assets/sidebar/new.svg',
                                isActive: isActive,
                                LabelText: 'Ajouter une mouvelle pièce',
                              ),
                            );
                          }),
                          const SizedBox(height: 15),
                          Obx(() {
                            final isActive = controller.activePage.value ==
                                'Acceder a la base STTR';
                            return ClickableWidget(
                              onTap: () {
                                controller
                                    .updateActivePage('Acceder a la base STTR');
                              },
                              child: SidebarListItemWidget(
                                Icon: 'assets/sidebar/sttr_db.svg',
                                isActive: isActive,
                                LabelText: 'Acceder a la base STTR',
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }
}
