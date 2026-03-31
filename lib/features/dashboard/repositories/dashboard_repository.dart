import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exceptions.dart';
import '../models/dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(dioProvider));
});

class DashboardRepository {
  final Dio _dio;

  DashboardRepository(this._dio);

  Future<DashboardSummary> getSummary() async {
    try {
      final response = await _dio.get(ApiEndpoints.dashboardSummary);
      return DashboardSummary.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<ServiceRecommendation>> getRecommendedServices() async {
    try {
      final response = await _dio.get(ApiEndpoints.recommendedServices);
      final List data = response.data;
      return data.map((e) => ServiceRecommendation.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> logActivity({
    required String type,
    required String title,
    String? statusText,
    required double progress,
  }) async {
    try {
      await _dio.post(ApiEndpoints.logActivity, data: {
        'activity_type': type,
        'title': title,
        'status_text': statusText,
        'progress': progress,
      });
    } catch (e) {
      // Background activity logging failures shouldn't break the app flow
      debugPrint('Failed to log activity: $e');
    }
  }
}
