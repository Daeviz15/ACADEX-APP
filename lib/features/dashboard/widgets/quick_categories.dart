import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../../main_shell/providers/shell_provider.dart';
import 'service_request_sheet.dart';

class QuickCategories extends ConsumerWidget {
  const QuickCategories({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'icon': Icons.edit_document, 'label': 'Assignments', 'color': Color(0xFFE2F6E9)},
    {'icon': Icons.psychology_rounded, 'label': 'AI Tutors', 'color': Color(0xFFF3E5F5)},
    {'icon': Icons.library_books_rounded, 'label': 'Past Qsts', 'color': Color(0xFFE3F2FD)},
    {'icon': Icons.emoji_events_rounded, 'label': 'Quizzes', 'color': Color(0xFFFFF3E0)},
    {'icon': Icons.laptop_mac_rounded, 'label': 'Software', 'color': Color(0xFFFFEBEE)},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final Color bgColor = cat['color'];
          
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? c.surfaceHighlight.withValues(alpha: 0.3)
                      : bgColor.withValues(alpha: 0.3), // Soft pill background based on theme
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: c.surface, // Inner circle is solid surface color
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        cat['icon'],
                        size: 16,
                        color: c.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat['label'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
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
