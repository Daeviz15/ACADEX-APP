import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages bookmark (saved) state for recommended services.
/// Key = service id (String), Value = isBookmarked (bool).
class ServiceBookmarkNotifier extends StateNotifier<Map<String, bool>> {
  ServiceBookmarkNotifier() : super({});

  void toggle(String serviceId) {
    final current = state[serviceId] ?? false;
    state = {...state, serviceId: !current};
  }

  bool isBookmarked(String serviceId) => state[serviceId] ?? false;
}

final serviceBookmarkProvider =
    StateNotifierProvider<ServiceBookmarkNotifier, Map<String, bool>>(
  (ref) => ServiceBookmarkNotifier(),
);
