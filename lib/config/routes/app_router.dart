import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/main_shell/screens/main_shell_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

/// This class bridges Riverpod providers to the GoRouter refreshListenable.
/// Whenever auth or onboarding state changes, it notifies the router to re-evaluate redirects.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Listen to changes in both Auth and Onboarding status
    _ref.listen(authNotifierProvider, (previous, next) => notifyListeners());
    _ref.listen(onboardingProvider, (previous, next) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainShellScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final onboardingState = ref.read(onboardingProvider);
      
      final bool isSplash = state.matchedLocation == '/';
      final bool isLoggingIn = state.matchedLocation == '/login';
      final bool isRegistering = state.matchedLocation == '/register';
      final bool isOnboarding = state.matchedLocation == '/onboarding';
      
      // 1. Splash Screen is for initialization only. 
      // If we are still initializing (loading state), don't redirect yet.
      if (authState.isLoading && isSplash) return null;

      // 2. Check Onboarding flow
      if (!onboardingState.isCompleted) {
        // If they are already on onboarding, let them stay. Otherwise, send them there.
        return isOnboarding ? null : '/onboarding';
      }

      // 3. Check Authentication flow
      final user = authState.value;
      if (user == null) {
        // Logged out -> Allow login, register, forgot-pass, or splash. 
        // Force them away from protected routes (dashboard) if they aren't there.
        if (isSplash || isLoggingIn || isRegistering || isOnboarding || state.matchedLocation == '/forgot-password') {
          return null;
        }
        return '/login';
      }

      // 4. User is Logged In
      // If they are on a "guest" page (login, register), push them to the dashboard.
      if (isSplash || isLoggingIn || isRegistering || isOnboarding) {
        return '/dashboard';
      }

      // Already on a protected page or splash, proceed
      return null;
    },
  );
});
