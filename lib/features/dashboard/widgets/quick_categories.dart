import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class QuickCategories extends StatelessWidget {
  const QuickCategories({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'icon': Icons.edit_document, 'label': 'Assignments', 'color': Color(0xFFE2F6E9)}, // Light green tint
    {'icon': Icons.psychology_rounded, 'label': 'AI Tutors', 'color': Color(0xFFF3E5F5)}, // Light purple tint
    {'icon': Icons.library_books_rounded, 'label': 'Past Qsts', 'color': Color(0xFFE3F2FD)}, // Light blue tint
    {'icon': Icons.emoji_events_rounded, 'label': 'Quizzes', 'color': Color(0xFFFFF3E0)}, // Light orange tint
    {'icon': Icons.laptop_mac_rounded, 'label': 'Software', 'color': Color(0xFFFFEBEE)}, // Light red tint
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          // Determine icon color based on its background tint for high contrast
          final Color bgColor = cat['color'];
          // Convert light background color into a vibrant dark color for the icon string
          // We can just use primary for everything or custom colors. Let's use primary for sleekness.
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.surfaceHighlight.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cat['icon'],
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  cat['label'],
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
