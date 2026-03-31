import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_models.dart';
import '../repositories/dashboard_repository.dart';

/// Provider for the overall Dashboard state (motivation + last activity)
final dashboardSummaryProvider = AutoDisposeAsyncNotifierProvider<DashboardNotifier, DashboardSummary>(() {
  return DashboardNotifier();
});

class DashboardNotifier extends AutoDisposeAsyncNotifier<DashboardSummary> {
  @override
  Future<DashboardSummary> build() async {
    return ref.read(dashboardRepositoryProvider).getSummary();
  }

  /// Refreshes the dashboard data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(dashboardRepositoryProvider).getSummary();
    });
  }
}

/// Provider for the Recommended Services carousel
final recommendedServicesProvider = FutureProvider.autoDispose<List<ServiceRecommendation>>((ref) async {
  return ref.read(dashboardRepositoryProvider).getRecommendedServices();
});
