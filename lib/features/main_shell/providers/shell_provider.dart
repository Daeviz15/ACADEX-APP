import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the current active index of the MainShellScreen.
/// This allows other features (like the Dashboard) to trigger tab switches globally.
final shellProvider = StateProvider<int>((ref) => 0);
