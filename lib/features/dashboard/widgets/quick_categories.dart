import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../../main_shell/providers/shell_provider.dart';
import 'service_request_sheet.dart';

class QuickCategories extends ConsumerWidget {
  const QuickCategories({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'icon': Icons.edit_document, 'label': 'Assignments', 'color': Color(0xFFE2F6E9)}, // Light green tint
    {'icon': Icons.psychology_rounded, 'label': 'AI Tutors', 'color': Color(0xFFF3E5F5)}, // Light purple tint
    {'icon': Icons.library_books_rounded, 'label': 'Past Qsts', 'color': Color(0xFFE3F2FD)}, // Light blue tint
    {'icon': Icons.emoji_events_rounded, 'label': 'Quizzes', 'color': Color(0xFFFFF3E0)}, // Light orange tint
    {'icon': Icons.laptop_mac_rounded, 'label': 'Software', 'color': Color(0xFFFFEBEE)}, // Light red tint
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final label = cat['label'];
                if (label == 'AI Tutors') {
                  ref.read(shellProvider.notifier).state = 1;
                } else if (label == 'Past Qsts') {
                  ref.read(shellProvider.notifier).state = 2;
                } else if (label == 'Quizzes') {
                  ref.read(shellProvider.notifier).state = 3;
                } else if (label == 'Assignments') {
                  ServiceRequestSheet.show(
                    context,
                    serviceId: 'assignments_help',
                    serviceTitle: 'Assignments Help',
                    placeholders: [
                      'Describe your assignment topic...',
                      'When is the deadline?',
                      'Which course is this for?',
                    ],
                    icon: Icons.edit_document,
                  );
                } else if (label == 'Software') {
                  ServiceRequestSheet.show(
                    context,
                    serviceId: 'software_support',
                    serviceTitle: 'Software Support',
                    placeholders: [
                      'Which software do you need?',
                      'Is it for Windows or Mac?',
                      'What version do you require?',
                    ],
                    icon: Icons.laptop_mac_rounded,
                  );
                }
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
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
              ),
            ),
          );
        },
      ),
    );
  }
}
