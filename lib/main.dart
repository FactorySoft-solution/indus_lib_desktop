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
  DesktopWindow.setWindowSize(const Size(1700, 1000));
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowMinSize(const Size(1700, 1000));
    setWindowMaxSize(const Size(1700, 1000));
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
      debugShowCheckedModeBanner: config.debugMode, // Enable/Disable debug mode
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
