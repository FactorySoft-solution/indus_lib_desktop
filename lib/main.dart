import 'dart:io';

import 'package:code_g/app/core/config/app_config.dart';
import 'package:code_g/app/routes/app_pages.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.developement");
  AppConfig config = await AppConfig.loadConfig(
      'dev'); // Change 'dev' to 'staging' or 'prod' as needed

  // Set initial window size but allow resizing
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(900, 650)); // Smaller minimum size
    // Let's set a good default size but allow resizing
    setWindowFrame(const Rect.fromLTWH(0, 0, 1400, 900));
  }

  runApp(MyApp(config: config));
}

class MyApp extends StatelessWidget {
  final AppConfig config;

  const MyApp({super.key, required this.config});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      key: GlobalKey(debugLabel: 'GetMaterialAppKey'),
      debugShowCheckedModeBanner: config.debugMode, // Enable/Disable debug mode
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: ThemeData(
        useMaterial3: true,
        // Add responsive padding/spacing here if needed
      ),
    );
  }
}
