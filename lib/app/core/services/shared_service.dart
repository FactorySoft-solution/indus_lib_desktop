import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SharedService {
  static final SharedService _instance = SharedService._internal();
  factory SharedService() => _instance;

  SharedService._internal();

  /// Load JSON from assets
  Future<Map<String, dynamic>> loadJsonFromAssets(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error loading JSON from assets: $e');
    }
  }

  /// Load JSON from a remote URL
  Future<Map<String, dynamic>> loadJsonFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load JSON from URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading JSON from URL: $e');
    }
  }
}
