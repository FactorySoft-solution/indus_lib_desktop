import 'package:code_g/app/core/values/app_colors.dart';
import 'package:code_g/app/modules/home/controllers/home_controller.dart';
import 'package:code_g/app/modules/create_project/controllers/create_project_controller.dart';
import 'package:code_g/app/widgets/clickable_widget.dart';
import 'package:code_g/app/widgets/icon_widget.dart';
import 'package:code_g/app/widgets/sidebar-list-item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SidebarWidget extends StatelessWidget {
  SidebarWidget({Key? key}) : super(key: key);

  final HomeController controller = Get.put(HomeController());
  final CreateProjectController createProjectController =
      Get.put(CreateProjectController());

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
          child: Obx(
            () => Column(
              children: [
                const SidebarHeader(),
                const SidebarDivider(),
                if (controller.activePage.value ==
                    "Ajouter une mouvelle pièce/resume-project") ...[
                  const SizedBox(height: 20),
                  CreateProjectResumeSidebarContent(
                      createProjectController: createProjectController),
                  const SizedBox(height: 20),
                ] else ...[
                  SidebarTopMenu(controller: controller),
                  const SizedBox(height: 50),
                ],
                const SidebarFooter(),
                const SizedBox(height: 50),
                SidebarBottomMenu(controller: controller),
              ],
            ),
          ),
        ));
  }
}

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      child: IconWidget(
        imagePath: "assets/arobase-sttr.svg",
      ),
    );
  }
}

class SidebarDivider extends StatelessWidget {
  const SidebarDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class SidebarTopMenu extends StatelessWidget {
  final HomeController controller;
  final List<Map<String, dynamic>> sideBarItems1 = [
    {"text": 'Recherche avancée', "icon": 'assets/sidebar/search.svg'},
    {"text": 'Formes de pièces', "icon": 'assets/sidebar/piece_forms.svg'},
    {"text": 'Matières premières', "icon": 'assets/sidebar/material.svg'},
    {"text": 'Liste des programmes', "icon": 'assets/sidebar/programs.svg'},
  ];

  SidebarTopMenu({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                      final isActive =
                          controller.activePage.value.contains(item['text']);
                      return ClickableWidget(
                        onTap: () {
                          controller.updateActivePage(item['text'] as String);
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
          const SizedBox(height: 50),
          Obx(() {
            final isActive = controller.activePage.value == 'Paramètres';
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
    );
  }
}

class SidebarBottomMenu extends StatelessWidget {
  final HomeController controller;

  SidebarBottomMenu({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClickableWidget(
          onTap: () {
            controller.updateActivePage('Ajouter une mouvelle pièce');
          },
          child: SidebarListItemWidget(
            Icon: 'assets/sidebar/new.svg',
            isActive: controller.activePage.value
                .contains('Ajouter une mouvelle pièce'),
            LabelText: 'Ajouter une mouvelle pièce',
          ),
        ),
        const SizedBox(height: 15),
        ClickableWidget(
          onTap: () {
            controller.updateActivePage('Acceder a la base STTR');
          },
          child: SidebarListItemWidget(
            Icon: 'assets/sidebar/sttr_db.svg',
            isActive:
                controller.activePage.value.contains('Acceder a la base STTR'),
            LabelText: 'Acceder a la base STTR',
          ),
        ),
      ],
    );
  }
}

class SidebarFooter extends StatelessWidget {
  const SidebarFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class CreateProjectResumeSidebarContent extends StatelessWidget {
  final CreateProjectController createProjectController;

  const CreateProjectResumeSidebarContent(
      {super.key, required this.createProjectController});

  @override
  Widget build(BuildContext context) {
    final sideBarData = createProjectController.sideBarInfo();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sideBarData.entries
          .map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: RichText(
                  text: TextSpan(
                    text: "${entry.key} : ",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: "${entry.value}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
