import 'package:flutter/material.dart';

/// Base color interface for theme-aware access.
abstract class AppColorScheme {
  Color get primary;
  Color get primaryDark;
  Color get primaryLight;
  Color get background;
  Color get surface;
  Color get surfaceHighlight;
  Color get textPrimary;
  Color get textSecondary;
  Color get textHint;
  Color get error;
  Color get success;
  Color get warning;
  Color get info;
}

/// Dark mode colors.
class _DarkColors implements AppColorScheme {
  const _DarkColors();

  @override
  Color get primary => const Color(0xFF00D26A);
  @override
  Color get primaryDark => const Color(0xFF00A852);
  @override
  Color get primaryLight => const Color(0xFF33FF8C);
  @override
  Color get background => const Color(0xFF0A0A0A);
  @override
  Color get surface => const Color(0xFF1E1E1E);
  @override
  Color get surfaceHighlight => const Color(0xFF2C2C2C);
  @override
  Color get textPrimary => const Color(0xFFFFFFFF);
  @override
  Color get textSecondary => const Color(0xFFB0B0B0);
  @override
  Color get textHint => const Color(0xFF757575);
  @override
  Color get error => const Color(0xFFFF4C4C);
  @override
  Color get success => const Color(0xFF00D26A);
  @override
  Color get warning => const Color(0xFFFFB74D);
  @override
  Color get info => const Color(0xFF4FC3F7);
}

/// Light mode colors.
class _LightColors implements AppColorScheme {
  const _LightColors();

  @override
  Color get primary => const Color(0xFF00D26A);
  @override
  Color get primaryDark => const Color(0xFF00A852);
  @override
  Color get primaryLight => const Color(0xFF33FF8C);
  @override
  Color get background => const Color(0xFFEEEFF3);
  @override
  Color get surface => const Color(0xFFFFFFFF);
  @override
  Color get surfaceHighlight => const Color(0xFFE8E8E8);
  @override
  Color get textPrimary => const Color(0xFF1A1A2E);
  @override
  Color get textSecondary => const Color(0xFF6B7280);
  @override
  Color get textHint => const Color(0xFF9CA3AF);
  @override
  Color get error => const Color(0xFFFF4C4C);
  @override
  Color get success => const Color(0xFF00D26A);
  @override
  Color get warning => const Color(0xFFFFB74D);
  @override
  Color get info => const Color(0xFF4FC3F7);
}

/// Static color constants for backward compatibility.
/// These always return the DARK mode values.
/// For theme-aware colors, use `context.colors.xxx` instead.
class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(0xFF00D26A);
  static const Color primaryDark = Color(0xFF00A852);
  static const Color primaryLight = Color(0xFF33FF8C);

  // Background Colors (Dark Theme defaults)
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceHighlight = Color(0xFF2C2C2C);

  // Text Colors (Dark Theme defaults)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF757575);

  // Status Colors
  static const Color error = Color(0xFFFF4C4C);
  static const Color success = Color(0xFF00D26A);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF4FC3F7);
}

/// Extension for easy, theme-aware color access from any widget.
/// Usage: `context.colors.background`, `context.colors.textPrimary`, etc.
extension AppColorsExtension on BuildContext {
  AppColorScheme get colors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark
        ? const _DarkColors()
        : const _LightColors();
  }

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
