import 'package:code_g/app/modules/create_project/controllers/create_project_controller.dart';
import 'package:code_g/app/modules/search_piece/controllers/search_piece_controller.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import 'package:code_g/app/core/config/app_config.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() async {
    final AppConfig config =
        await AppConfig.loadConfig('dev'); // Change environment as needed

    Get.put(config); // Register AppConfig as a dependency
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<CreateProjectController>(
      () => CreateProjectController(),
    );
    Get.lazyPut<SearchPieceController>(
      () => SearchPieceController(),
    );
  }
}
