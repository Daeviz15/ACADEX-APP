import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class DashSearchBar extends StatelessWidget {
  const DashSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceHighlight.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search services...',
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary.withOpacity(0.7),
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
