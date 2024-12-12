import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController() {}
  var activePage = 'Recherche avancée'.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Update the active page
  void updateActivePage(String pageName) {
    activePage.value = pageName;
  }

  void fetchData() async {}
}
