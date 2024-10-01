// lib/app/core/services/api_service.dart
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:code_g/app/core/config/app_config.dart';

class ApiService {
  final dio.Dio _dio;

  // Constructor with a nullable dio.Dio parameter
  ApiService({dio.Dio? dioInstance, required AppConfig config})
      : _dio = dioInstance ??
            dio.Dio(dio.BaseOptions(
              baseUrl: config.apiBaseUrl, // Replace with your API base URL
              connectTimeout: 5000.seconds,
              receiveTimeout: 3000.seconds,
            ));

  Future<dio.Response> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } on dio.DioError catch (e) {
      // Handle errors
      print(
          'GET request error: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  Future<dio.Response> post(String endpoint,
      {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on dio.DioError catch (e) {
      print(
          'POST request error: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  Future<dio.Response> put(String endpoint,
      {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } on dio.DioError catch (e) {
      print(
          'PUT request error: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }

  Future<dio.Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } on dio.DioError catch (e) {
      print(
          'DELETE request error: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    }
  }
}
