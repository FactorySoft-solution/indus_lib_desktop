import 'package:code_g/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:code_g/app/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Required to initialize before runApp
  // Load the .env file
  await dotenv.load(fileName: ".env.developement");
  AppConfig config = await AppConfig.loadConfig(
      'dev'); // Change 'dev' to 'staging' or 'prod' as needed
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

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
