import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class JsonServices {
  static final JsonServices _instance = JsonServices._internal();
  factory JsonServices() => _instance;
  final Logger logger = new Logger();
  JsonServices._internal();

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

  /// Read JSON file from filesystem
  Future<Map<String, dynamic>> readJsonFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }
      final String jsonString = await file.readAsString();
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      logger.e('Error reading JSON file: $e');
      throw Exception('Error reading JSON file: $e');
    }
  }

  Future<Map<String, dynamic>> loadFiltageJson() async {
    final filetageTable =
        await loadJsonFromAssets('assets/json/filtage/filetageTable.json');
    return filetageTable;
  }

  Future<Map<String, dynamic>> loadMachineTable() async {
    final machineTable =
        await loadJsonFromAssets('assets/json/filtage/machineTable.json');
    return machineTable;
  }

  Future<Map<String, dynamic>> loadIndiceJson() async {
    final indiceTable =
        await loadJsonFromAssets('assets/json/filtage/indicePIECE.json');
    return indiceTable;
  }

  Future<Map<String, dynamic>> loadMachineJson() async {
    final machineTable =
        await loadJsonFromAssets('assets/json/filtage/listeMACHINE.json');
    return machineTable;
  }

  Future<Map<String, dynamic>> loadMechoireJson() async {
    final mechoireJson =
        await loadJsonFromAssets('assets/json/filtagemachoireEJECTION.json');
    return mechoireJson;
  }

  Future<Map<String, dynamic>> loadProgrammerJson() async {
    final programmerJson =
        await loadJsonFromAssets('assets/json/filtagelistePROGRAMMEUR.json');
    return programmerJson;
  }

  Future<Map<String, dynamic>> loadArrosageJson() async {
    final arrosageJson =
        await loadJsonFromAssets('assets/json/filtagearrosage_type.json');
    return arrosageJson;
  }

  Future<Map<String, dynamic>> loadTopSolideJson() async {
    final topSolideJson = await loadJsonFromAssets(
        'assets/json/filtagetopSolide_operations.json');
    return topSolideJson;
  }
}
