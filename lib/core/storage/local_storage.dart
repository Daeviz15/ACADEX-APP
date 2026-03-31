import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main.dart before runApp');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // -- Keys --
  static const String _kHasSeenPqDiscovery = 'has_seen_pq_discovery';
  static const String _kHasSeenQuizDiscovery = 'has_seen_quiz_discovery';
  static const String _kHasSeenAiChatDiscovery = 'has_seen_ai_chat_discovery';

  // -- Past Questions --
  bool get hasSeenPqDiscovery => _prefs.getBool(_kHasSeenPqDiscovery) ?? false;
  Future<void> setHasSeenPqDiscovery() async {
    await _prefs.setBool(_kHasSeenPqDiscovery, true);
  }

  // -- Quiz Arena --
  bool get hasSeenQuizDiscovery => _prefs.getBool(_kHasSeenQuizDiscovery) ?? false;
  Future<void> setHasSeenQuizDiscovery() async {
    await _prefs.setBool(_kHasSeenQuizDiscovery, true);
  }

  // -- AI Chat (Future proofing) --
  bool get hasSeenAiChatDiscovery => _prefs.getBool(_kHasSeenAiChatDiscovery) ?? false;
  Future<void> setHasSeenAiChatDiscovery() async {
    await _prefs.setBool(_kHasSeenAiChatDiscovery, true);
  }

  // -- Reset for debugging --
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
