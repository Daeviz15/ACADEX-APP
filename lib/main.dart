import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:acadex/core/storage/local_storage.dart';
import 'package:acadex/config/theme/theme_provider.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/ai_guidance/providers/ai_onboarding_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables securely
  await dotenv.load(fileName: ".env");

  // Read persistent states before app launch to prevent flickering
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final onboardingCompleted = await storage.read(key: 'onboarding_completed');
  final aiOnboardingCompleted = await storage.read(key: 'ai_onboarding_completed');
  final hasEverLoggedIn = await storage.read(key: 'has_ever_logged_in');

  // If user has ever logged in, they've definitely completed all onboarding flows
  final isOnboardingDone = onboardingCompleted == 'true' || hasEverLoggedIn == 'true';
  final isAiOnboardingDone = aiOnboardingCompleted == 'true' || hasEverLoggedIn == 'true';

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // SharedPreferences
        sharedPreferencesProvider.overrideWithValue(prefs),

        // Theme mode (persisted)
        themeModeProvider.overrideWith(
          (ref) => ThemeModeNotifier(prefs),
        ),
        
        // Main onboarding state
        onboardingProvider.overrideWith(
          (ref) => OnboardingNotifier(
            initialIsCompleted: isOnboardingDone,
          ),
        ),
        // AI onboarding state
        aiOnboardingProvider.overrideWith(
          (ref) => AiOnboardingNotifier(
            initialCompleted: isAiOnboardingDone,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
