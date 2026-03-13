import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OnboardingState {
  final int currentPage;
  final bool isCompleted;

  const OnboardingState({
    this.currentPage = 0,
    this.isCompleted = false,
  });

  OnboardingState copyWith({int? currentPage, bool? isCompleted}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier({bool initialIsCompleted = false})
      : super(OnboardingState(isCompleted: initialIsCompleted));

  static const _storageKey = 'onboarding_completed';
  final _storage = const FlutterSecureStorage();

  void setPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  Future<void> completeOnboarding() async {
    await _storage.write(key: _storageKey, value: 'true');
    state = state.copyWith(isCompleted: true);
  }

  Future<bool> hasCompletedOnboarding() async {
    final value = await _storage.read(key: _storageKey);
    return value == 'true';
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
