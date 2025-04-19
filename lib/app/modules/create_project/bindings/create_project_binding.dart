import 'package:code_g/app/core/services/file_selection_service.dart';
import 'package:code_g/app/core/services/form_validation_service.dart';
import 'package:code_g/app/core/services/project_service.dart';
import 'package:get/get.dart';

import '../controllers/create_project_controller.dart';

class CreateProjectBinding extends Bindings {
  @override
  void dependencies() {
    // Register services
    Get.lazyPut<ProjectService>(() => ProjectService());
    Get.lazyPut<FormValidationService>(() => FormValidationService());
    Get.lazyPut<FileSelectionService>(() => FileSelectionService());

    // Register controllers
    Get.lazyPut<CreateProjectController>(
      () => CreateProjectController(),
    );
  }
}
