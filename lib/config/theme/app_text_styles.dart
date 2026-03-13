import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Font Family Names
  static const String outfit = 'Outfit';
  static const String urbanist = 'Urbanist';
  static const String montserrat = 'Montserrat';
  static const String plusJakarta = 'PlusJakartaSans';
  static const String hostGrotesk = 'HostGrotesk';

  // Headings (Outfit)
  static TextStyle get h1 => const TextStyle(
    fontFamily: outfit,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get h2 => const TextStyle(
    fontFamily: outfit,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle get h3 => const TextStyle(
    fontFamily: outfit,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body Text (Urbanist/PlusJakartaSans)
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: urbanist,
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: urbanist,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: urbanist,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Buttons & Labels (Urbanist)
  static TextStyle get button => const TextStyle(
    fontFamily: urbanist,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.background,
  );
  
  static TextStyle get label => const TextStyle(
    fontFamily: urbanist,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textHint,
  );

  // Special Variants
  static TextStyle get h1Host => h1.copyWith(fontFamily: hostGrotesk);
  static TextStyle get bodyPlusJakarta => bodyMedium.copyWith(fontFamily: plusJakarta);
}
