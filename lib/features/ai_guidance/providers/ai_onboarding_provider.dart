import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiOnboardingNotifier extends StateNotifier<bool> {
  AiOnboardingNotifier({bool initialCompleted = false}) : super(initialCompleted);

  static const _storageKey = 'ai_onboarding_completed';
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> completeOnboarding() async {
    await _storage.write(key: _storageKey, value: 'true');
    state = true;
  }
}

final aiOnboardingProvider = StateNotifierProvider<AiOnboardingNotifier, bool>(
  (ref) => AiOnboardingNotifier(),
);
