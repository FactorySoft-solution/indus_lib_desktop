import 'package:code_g/app/core/services/local_storage_service.dart';
import 'package:code_g/app/helpers/enums.dart';
import 'package:code_g/app/helpers/modals/user.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final obscurePassword = true.obs;

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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
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

      if (response.isNotEmpty) {
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

  Future<void> login() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        isLoading.value = true;
        String email = emailController.text;
        String password = passwordController.text;

        final localStorage = LocalStorageService();
        final UserModel user = UserModel(
          login: email,
          company: Company.ROBERT,
          workstation: Workstation.REGLEUR_MACHINE,
        );

        await localStorage.saveString("user_data", user.toString());
        Get.offAllNamed('/home');
      } catch (e) {
        Get.snackbar('Error', 'An error occurred during login');
      } finally {
        isLoading.value = false;
      }
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
}
