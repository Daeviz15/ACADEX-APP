import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exceptions.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.register, data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      // Modern authentication standards dictate OAuth2 Form URLs for password grants!
      final formData = FormData.fromMap({
        'username': email,
        'password': password,
      });
      final response = await _dio.post(
        ApiEndpoints.login,
        data: formData,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      // Extracts the pure JWT scalar
      return response.data['access_token'];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<String> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.verifyOtp, data: {
        'email': email,
        'otp_code': otpCode,
      });
      return response.data['access_token'];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<User> getMe() async {
    try {
      final response = await _dio.get(ApiEndpoints.me);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Exchanges a Google ID Token for an Acadex JWT
  Future<String> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.googleLogin,
        data: {'id_token': idToken},
      );
      return response.data['access_token'];
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Uploads a new avatar file to the backend
  Future<User> updateAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: 'avatar.jpg',
        ),
      });

      final response = await _dio.put(
        ApiEndpoints.updateAvatar,
        data: formData,
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Uploads a new profile banner to the backend
  Future<User> updateBanner(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: 'banner.jpg',
        ),
      });

      final response = await _dio.put(
        ApiEndpoints.updateBanner,
        data: formData,
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
