import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider for securely interacting with encrypted platform storage.
/// Uses AES-backed EncryptedSharedPreferences on Android and Keychain on iOS.
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  return SecureStorageService(storage);
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // ── Key Constants ──
  static const _tokenKey = 'auth_token';
  static const _userCacheKey = 'cached_user_profile';
  static const _hasEverLoggedInKey = 'has_ever_logged_in';

  // ═══════════════════════════════════════════════════════════════
  // JWT Token Management
  // ═══════════════════════════════════════════════════════════════

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ═══════════════════════════════════════════════════════════════
  // User Profile Cache (Offline-First)
  // Stores the user's profile JSON locally so the app can boot
  // instantly without a network call to the backend.
  // ═══════════════════════════════════════════════════════════════

  /// Caches the serialized user profile into encrypted storage.
  /// Called after every successful login, OTP verification, or profile refresh.
  Future<void> saveUserCache(Map<String, dynamic> userJson) async {
    final encoded = jsonEncode(userJson);
    await _storage.write(key: _userCacheKey, value: encoded);
    // Also mark that this device has completed at least one successful login
    await _storage.write(key: _hasEverLoggedInKey, value: 'true');
  }

  /// Retrieves the locally cached user profile JSON.
  /// Returns null if no cache exists (first-time user).
  Future<Map<String, dynamic>?> getCachedUser() async {
    final raw = await _storage.read(key: _userCacheKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      // Corrupted cache — wipe it
      await _storage.delete(key: _userCacheKey);
      return null;
    }
  }

  /// Whether this device has ever completed a successful login.
  /// Used by the splash screen to decide navigation without any network call.
  Future<bool> hasEverLoggedIn() async {
    final value = await _storage.read(key: _hasEverLoggedInKey);
    return value == 'true';
  }

  // ═══════════════════════════════════════════════════════════════
  // Full Wipe (Logout)
  // ═══════════════════════════════════════════════════════════════

  /// Destroys all auth-related secrets. Called on explicit logout only.
  Future<void> clearAuthData() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userCacheKey),
      _storage.delete(key: _hasEverLoggedInKey),
    ]);
  }
}
