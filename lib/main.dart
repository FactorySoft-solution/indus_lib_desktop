import 'package:code_g/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_g/app/core/config/app_config.dart';

// import 'app/routes/app_routes.dart';
void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Required to initialize before runApp
  AppConfig config = await AppConfig.loadConfig(
      'dev'); // Change 'dev' to 'staging' or 'prod' as needed

  runApp(MyApp(config: config));
}

class MyApp extends StatelessWidget {
  final AppConfig config;

  const MyApp({super.key, required this.config});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: config.debugMode, // Enable/Disable debug mode
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
