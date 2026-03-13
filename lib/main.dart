import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/ai_guidance/providers/ai_onboarding_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read persistent states before app launch to prevent flickering
  const storage = FlutterSecureStorage();
  final onboardingCompleted = await storage.read(key: 'onboarding_completed');
  final aiOnboardingCompleted = await storage.read(key: 'ai_onboarding_completed');

  runApp(
    ProviderScope(
      overrides: [
        // Main onboarding state
        onboardingProvider.overrideWith(
          (ref) => OnboardingNotifier(
            initialIsCompleted: onboardingCompleted == 'true',
          ),
        ),
        // AI onboarding state
        aiOnboardingProvider.overrideWith(
          (ref) => AiOnboardingNotifier(
            initialCompleted: aiOnboardingCompleted == 'true',
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
