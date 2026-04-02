import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../../main_shell/providers/shell_provider.dart';
import '../data/models/past_question.dart';
import '../screens/pq_viewer_screen.dart';
import '../screens/pq_quiz_screen.dart';

class PqActionSheet extends ConsumerWidget {
  final PastQuestion question;

  const PqActionSheet({super.key, required this.question});

  /// Helper to show this sheet.
  static void show(BuildContext context, {required PastQuestion question}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PqActionSheet(question: question),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.surfaceHighlight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header — course info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isDark ? c.primary : const Color(0xFF00664F)).withValues(alpha: 0.12),
                  (isDark ? c.primary : const Color(0xFF00664F)).withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (isDark ? c.primary : const Color(0xFF00664F)).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.courseCode,
                  style: TextStyle(
                    fontFamily: AppTextStyles.hostGrotesk,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? c.primary : const Color(0xFF00664F),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.courseTitle,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoTag(label: question.displayYear),
                    if (question.semester != null) ...[
                      const SizedBox(width: 8),
                      _InfoTag(label: '${question.semester} Semester'),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          _ActionButton(
            icon: Icons.visibility_rounded,
            label: 'View Question',
            subtitle: 'Read the exam paper',
            delay: 0,
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PqViewerScreen(question: question),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _ActionButton(
            icon: Icons.auto_awesome_rounded,
            label: 'Study with AI',
            subtitle: 'Get AI-powered explanations',
            delay: 40,
            onTap: () {
              Navigator.pop(context);
              ref.read(shellProvider.notifier).state = 1;
            },
          ),
          const SizedBox(height: 10),
          _ActionButton(
            icon: Icons.emoji_events_rounded,
            label: 'Take a Quiz',
            subtitle: 'Test your knowledge',
            delay: 80,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PqQuizScreen(question: question),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Info Tag Pill ──

class _InfoTag extends StatelessWidget {
  final String label;
  const _InfoTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.surfaceHighlight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: c.textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ── Action Button ──

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final int delay;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: c.surfaceHighlight.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isDark ? c.primary : const Color(0xFF00664F)).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isDark ? c.primary : const Color(0xFF00664F), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: (isDark ? c.primary : const Color(0xFF00664F)).withValues(alpha: 0.6),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideX(
          begin: 0.15,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(delay: Duration(milliseconds: delay), duration: 300.ms);
  }
}
