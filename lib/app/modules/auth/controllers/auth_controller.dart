import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:code_g/app/helpers/modals/user.dart';

class AuthController extends GetxController {
  //TODO: Implement AuthController
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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

  Future<Map<String, dynamic>?> getUserByUsername(String email) async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq(
              'login',
              email
                  .trim()
                  .toLowerCase()) // Handle case sensitivity and whitespace
          .single();

      print("response $response");

      return response;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllUsers() async {
    try {
      final response = await Supabase.instance.client
          .from('users') // Replace 'users' with your table name if different
          .select();

      if (response != null && response.isNotEmpty) {
        print("Users fetched successfully: $response");
        return List<Map<String, dynamic>>.from(response);
      } else {
        print("No users found.");
        return [];
      }
    } catch (e) {
      print('Error fetching users: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> addUser(UserModel user) async {
    final userMap = user.toJson();

    final response =
        await Supabase.instance.client.from('users').insert([userMap]);
    print("response $response");
    return response;
  }

  void login() {
    // Add authentication logic here
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      String email = emailController.text;
      String password = passwordController.text;
      // Navigate to the home page on successful login
      print("email == $email");
      print("password == $password");
      getUserByUsername(email);
      // Get.offNamed('/home');
    } else {
      Get.snackbar('Error', 'Please enter email and password');
    }
  }
}
