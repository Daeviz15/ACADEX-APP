import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Global auth state provider using Riverpod's StateNotifier pattern.
/// The provider auto-initializes on first read via the constructor.
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final notifier = AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(secureStorageProvider),
  );
  // Fire-and-forget: begins the offline-first session restoration immediately
  notifier.init();
  return notifier;
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repository;
  final SecureStorageService _secureStorage;

  AuthNotifier(this._repository, this._secureStorage)
      : super(const AsyncValue.loading());

  // ═══════════════════════════════════════════════════════════════
  // Offline-First Session Restoration
  // ═══════════════════════════════════════════════════════════════

  /// Called once at app boot. Follows a strict offline-first pattern:
  ///
  /// 1. Read the JWT token from secure storage
  /// 2. If token exists → immediately load the cached user profile (no network)
  /// 3. Attempt a background refresh via getMe() — if it fails, we silently
  ///    keep using the cached profile; the user never sees a loading screen
  /// 4. If no token → user has never logged in → state = null → login screen
  Future<void> init() async {
    final token = await _secureStorage.getToken();

    if (token != null) {
      // ── Phase 1: Instant local restore ──
      final cachedJson = await _secureStorage.getCachedUser();
      if (cachedJson != null) {
        // Immediately emit the cached user so the router can navigate
        state = AsyncValue.data(User.fromJson(cachedJson));
      }

      // ── Phase 2: Silent background refresh ──
      // We do NOT block navigation on this. It runs after the UI is live.
      _backgroundRefresh();
    } else {
      // No token at all — first-time user or fully logged out
      state = const AsyncValue.data(null);
    }
  }

  /// Silently attempts to refresh the user profile from the backend.
  /// If the server is unreachable (LocalTunnel down, no internet, etc.),
  /// we simply keep the cached data. Zero UX disruption.
  Future<void> _backgroundRefresh() async {
    try {
      final freshUser = await _repository.getMe();
      // Update both in-memory state and persistent cache
      if (mounted) {
        state = AsyncValue.data(freshUser);
      }
      await _secureStorage.saveUserCache(freshUser.toJson());
    } catch (e) {
      // Server unreachable or token expired — keep cached user for now.
      // If the token is truly expired, server-dependent features will
      // show a graceful error when the user tries to use them.
      // We do NOT delete the token here to avoid breaking offline UX.
    }
  }

  /// Manually fetches the latest user profile and updates state.
  /// Useful for pull-to-refresh actions on the dashboard.
  Future<void> getMe() async {
    try {
      final freshUser = await _repository.getMe();
      if (mounted) {
        state = AsyncValue.data(freshUser);
      }
      await _secureStorage.saveUserCache(freshUser.toJson());
    } catch (e) {
      // Server unreachable or token expired during pull-to-refresh.
      // We swallow the error so the app doesn't crash, allowing the cached 
      // user profile to remain active. The UI refresh indicator will simply complete.
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Registration (no auto-login — user must verify OTP first)
  // ═══════════════════════════════════════════════════════════════

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _repository.register(
          name: name, email: email, password: password);
      // Don't log them in — OTP verification is required
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Login — stores JWT + caches profile locally
  // ═══════════════════════════════════════════════════════════════

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      // 1. Authenticate and receive JWT
      final token = await _repository.login(
          email: email, password: password);
      await _secureStorage.saveToken(token);

      // 2. Fetch the full user profile
      final user = await _repository.getMe();

      // 3. Cache the profile for offline-first boot
      await _secureStorage.saveUserCache(user.toJson());

      // 4. Emit authenticated state
      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }


  Future<void> googleLogin() async {
    state = const AsyncValue.loading();
    try {
      final googleSignIn = GoogleSignIn.instance;
      
      await googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );

      await googleSignIn.signOut();
      
      
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Failed to retrieve ID token from Google.');
      }

      // 1. Authenticate with Acadex backend via Google ID Token
      final token = await _repository.loginWithGoogle(idToken);
      
      // DEEP REFRESH: Wipe any leftover state from previous sessions before saving new token
      await _secureStorage.clearAuthData();
      await _secureStorage.saveToken(token);

      // 2. Fetch resulting user profile (Force fresh sync)
      final user = await _repository.getMe();
      
      // 3. Cache locally for offline-first boot
      await _secureStorage.saveUserCache(user.toJson());

      // Finally emit the fully-formed, persisted user identity
      state = AsyncValue.data(user);
    } on GoogleSignInException catch (e) {
      // Handle "Canceled" (manually closing dialog) silently
      if (e.code == GoogleSignInExceptionCode.canceled) {
        state = const AsyncValue.data(null);
        return;
      }
      
      // Other Google errors (e.g., misconfigured SHA-1, missing internet)
      state = AsyncValue.error(
        'Google Sign-In failed: ${e.code} (Code: ${e.code})', 
        StackTrace.current
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // OTP Verification — auto-login after email confirmation
  // ═══════════════════════════════════════════════════════════════

  Future<void> verifyOtp(String email, String otpCode) async {
    state = const AsyncValue.loading();
    try {
      final token = await _repository.verifyOtp(
          email: email, otpCode: otpCode);
      await _secureStorage.saveToken(token);

      final user = await _repository.getMe();
      await _secureStorage.saveUserCache(user.toJson());

      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Logout — full credential wipe
  // ═══════════════════════════════════════════════════════════════

  Future<void> logout() async {
    await _secureStorage.clearAuthData();
    state = const AsyncValue.data(null);
  }

  /// Updates the user's avatar and refreshes the local state and cache.
  Future<void> updateAvatar(String filePath) async {
    // We don't set global loading state here to allow "Optimistic UI" 
    // where the user can keep browsing while the upload completes.
    try {
      final updatedUser = await _repository.updateAvatar(filePath);
      
      // Update in-memory state
      if (mounted) {
        state = AsyncValue.data(updatedUser);
      }
      
      // Persist to local cache for offline-first restoration
      await _secureStorage.saveUserCache(updatedUser.toJson());
    } catch (e) {
      // In a real app, you might show a snackbar here.
      // For now, we'll just log it.
      print("AVATAR UPLOAD FAILED: $e");
    }
  }

  /// Updates the user's banner and refreshes the local state and cache.
  Future<void> updateBanner(String filePath) async {
    try {
      final updatedUser = await _repository.updateBanner(filePath);
      
      // Update in-memory state
      if (mounted) {
        state = AsyncValue.data(updatedUser);
      }
      
      // Persist to local cache
      await _secureStorage.saveUserCache(updatedUser.toJson());
    } catch (e) {
      print("BANNER UPLOAD FAILED: $e");
    }
  }
}
