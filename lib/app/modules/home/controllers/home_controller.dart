import 'package:get/get.dart';
import 'package:code_g/app/core/services/api_service.dart';

class HomeController extends GetxController {
  final ApiService apiService;

  HomeController({required this.apiService}) {}

  //TODO: Implement HomeController
  final count = 0.obs;
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

  void increment() => count.value++;

  void fetchData() async {
    try {
      final response = await apiService.get('/your-endpoint');
      // Process the response data
      print(response.data);
    } catch (e) {
      // Handle the error appropriately in the UI
      print('Error fetching data: $e');
    }
  }
}
