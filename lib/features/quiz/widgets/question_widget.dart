import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final List<String> options;
  final int? selectedOption;
  final int correctIndex;
  final bool hasAnswered;
  final ValueChanged<int> onSelectOption;

  const QuestionCard({
    super.key,
    required this.question,
    required this.options,
    required this.selectedOption,
    required this.correctIndex,
    required this.hasAnswered,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: c.surfaceHighlight.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            question,
            style: AppTextStyles.h3.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: c.textPrimary,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: -0.05, end: 0, duration: 300.ms, curve: Curves.easeOut),

        const SizedBox(height: 20),

        // Options
        ...List.generate(options.length, (index) {
          final isSelected = selectedOption == index;
          final isCorrect = index == correctIndex;
          final showCorrect = hasAnswered && isCorrect;
          final showWrong = hasAnswered && isSelected && !isCorrect;

          Color borderColor = c.surfaceHighlight.withValues(alpha: 0.3);
          Color bgColor = c.surface;
          Color textColor = c.textPrimary;
          IconData? trailingIcon;

          if (showCorrect) {
            borderColor = c.primary;
            bgColor = c.primary.withValues(alpha: 0.1);
            textColor = c.primary;
            trailingIcon = Icons.check_circle_rounded;
          } else if (showWrong) {
            borderColor = AppColors.error;
            bgColor = AppColors.error.withValues(alpha: 0.1);
            textColor = AppColors.error;
            trailingIcon = Icons.cancel_rounded;
          } else if (isSelected && !hasAnswered) {
            borderColor = c.primary;
            bgColor = c.primary.withValues(alpha: 0.08);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasAnswered ? null : () => onSelectOption(index),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                      width: (isSelected || showCorrect || showWrong) ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Option letter
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: (isSelected || showCorrect)
                              ? (showWrong
                                  ? AppColors.error.withValues(alpha: 0.15)
                                  : c.primary.withValues(alpha: 0.15))
                              : c.surfaceHighlight.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              fontFamily: AppTextStyles.hostGrotesk,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: showWrong
                                  ? AppColors.error
                                  : (isSelected || showCorrect)
                                      ? c.primary
                                      : c.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          options[index],
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (trailingIcon != null)
                        Icon(
                          trailingIcon,
                          color: showWrong ? AppColors.error : c.primary,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 60 * index),
                  duration: 300.ms,
                )
                .slideX(
                  begin: 0.08,
                  end: 0,
                  delay: Duration(milliseconds: 60 * index),
                  duration: 300.ms,
                  curve: Curves.easeOutCubic,
                ),
          );
        }),
      ],
    );
  }
}
