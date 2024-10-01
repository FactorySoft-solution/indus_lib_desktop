import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert'; // For JSON decoding

class AppConfig {
  String appName;
  String apiBaseUrl;
  bool debugMode;
  String appVersion;

  AppConfig({
    required this.appName,
    required this.apiBaseUrl,
    required this.debugMode,
    required this.appVersion,
  });

  static Future<AppConfig> loadConfig(String environment) async {
    // Load the JSON file
    String jsonString =
        await rootBundle.loadString('assets/config/config.json');
    Map<String, dynamic> json = jsonDecode(jsonString);

    // Get the environment-specific config
    Map<String, dynamic> config = json[environment];

    return AppConfig(
      appName: config['appName'],
      apiBaseUrl: config['apiBaseUrl'],
      debugMode: config['debugMode'],
      appVersion: config['appVersion'],
    );
  }
}
