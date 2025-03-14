import 'package:get/get.dart';

import '../controllers/search_piece_controller.dart';

class SearchPieceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchPieceController>(
      () => SearchPieceController(),
    );
  }
}
