import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  factory ApiException.fromDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout || 
        error.type == DioExceptionType.receiveTimeout) {
      return ApiException('Connection timed out. Please check your internet.');
    }
    
    if (error.response != null) {
      final data = error.response?.data;
      if (data != null && data is Map<String, dynamic>) {
        // FastAPI validation errors return highly nested `detail` arrays
        if (data['detail'] is List) {
          final firstError = data['detail'][0];
          return ApiException(firstError['msg'] ?? 'Validation error', error.response?.statusCode);
        }
        // FastAPI standard HTTPExceptions return a string `detail`
        if (data['detail'] is String) {
          return ApiException(data['detail'], error.response?.statusCode);
        }
      }
      return ApiException('Server returned an error', error.response?.statusCode);
    }

    return ApiException('Network error occurred. Please try again later.');
  }

  @override
  String toString() => message;
}
