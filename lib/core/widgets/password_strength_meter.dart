import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

enum PasswordStrength { weak, medium, good, strong }

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  PasswordStrength get strength {
    if (password.isEmpty) return PasswordStrength.weak;
    if (password.length < 6) return PasswordStrength.weak;

    int points = 0;
    if (password.length >= 8) points++;
    if (RegExp(r'[A-Z]').hasMatch(password)) points++;
    if (RegExp(r'[0-9]').hasMatch(password)) points++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) points++;

    if (points <= 1) return PasswordStrength.weak;
    if (points == 2) return PasswordStrength.medium;
    if (points == 3) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  Color get _strengthColor {
    switch (strength) {
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.yellow;
      case PasswordStrength.strong:
        return AppColors.primary;
    }
  }

  double get _strengthProgress {
    switch (strength) {
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.good:
        return 0.75;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  String get _strengthText {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStrong = strength == PasswordStrength.strong;
    final isWeak = strength == PasswordStrength.weak && password.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password Strength',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              _strengthText,
              style: AppTextStyles.bodySmall.copyWith(
                color: _strengthColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceHighlight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: MediaQuery.of(context).size.width * _strengthProgress,
                decoration: BoxDecoration(
                  color: _strengthColor,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: isStrong
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
              ).animate(target: isWeak ? 1 : 0).shakeX(hz: 4, amount: 2),
            ],
          ),
        ),
        if (isStrong)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Sleek & Secure',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                ),
              ],
            ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
          ),
      ],
    );
  }
}
