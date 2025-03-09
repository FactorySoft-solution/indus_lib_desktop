import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class SharedService {
  static final SharedService _instance = SharedService._internal();
  factory SharedService() => _instance;
  final Logger logger = new Logger();
  SharedService._internal();

  /// Load JSON from assets
  Future<Map<String, dynamic>> loadJsonFromAssets(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return jsonData;
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

  Map<String, dynamic>? searchInArray(List<String> array, String searchKey) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].contains(searchKey)) {
        return {'value': array[i], 'index': i};
      }
    }
    return null; // Return null if no match is found
  }

  List<String> searchDataFromMapToArray(String jsonString, String dataName) {
    List<dynamic> data = jsonDecode(jsonString);

    return data.map((item) => item[dataName].toString()).toList();
  }

  List<dynamic> searchInList(List<dynamic> data, String keyword) {
    return data.where((item) {
      var dataSource = item["operation"]
          .toString()
          .toLowerCase()
          .contains(keyword.toLowerCase());
      return dataSource;
    }).toList();
  }

  List<String> extractAllOperations(List<dynamic> data, String key) {
    return data.map((obj) => obj[key].toString()).toList();
  }

  bool stringStartsWithDAndNumber(String input) {
    final regex = RegExp(r'^D\d'); // ^D -> Starts with D, \d -> Digit (0-9)
    return regex.hasMatch(input);
  }

  bool stringStartsWithLetterAndNumber(String input) {
    final regex =
        RegExp(r'^[A-Za-z]\d'); // ^[A-Za-z] -> 1 letter, \d -> 1 digit (0-9)
    return regex.hasMatch(input);
  }
}
