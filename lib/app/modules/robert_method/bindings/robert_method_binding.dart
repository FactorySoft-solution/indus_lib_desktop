import 'package:get/get.dart';
import '../controllers/robert_method_controller.dart';

class RobertMethodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RobertMethodController>(
      () => RobertMethodController(),
    );
  }
}
