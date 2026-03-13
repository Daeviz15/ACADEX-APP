import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../data/models/past_question.dart';
import 'pq_action_sheet.dart';

class PqCard extends StatelessWidget {
  final PastQuestion question;
  final int index;

  const PqCard({super.key, required this.question, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => PqActionSheet.show(context, question: question),
          borderRadius: BorderRadius.circular(18),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.surfaceHighlight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // Left accent bar
                Container(
                  width: 4,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),

                // Course info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.courseCode,
                        style: TextStyle(
                          fontFamily: AppTextStyles.hostGrotesk,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        question.courseTitle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _MiniTag(
                            label: question.year,
                            icon: Icons.calendar_today_rounded,
                          ),
                          const SizedBox(width: 8),
                          _MiniTag(
                            label: question.semester,
                            icon: Icons.view_agenda_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mini Tag ──

class _MiniTag extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MiniTag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighlight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.textHint),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
