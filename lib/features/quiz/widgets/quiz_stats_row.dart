import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class QuizStatsRow extends StatelessWidget {
  final int totalQuizzes;
  final int winRate;
  final int bestStreak;

  const QuizStatsRow({
    super.key,
    required this.totalQuizzes,
    required this.winRate,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        _StatCard(icon: Icons.quiz_rounded, value: '$totalQuizzes', label: 'Quizzes', color: c.primary, delay: 200),
        const SizedBox(width: 12),
        _StatCard(icon: Icons.trending_up_rounded, value: '$winRate%', label: 'Win Rate', color: const Color(0xFF4FC3F7), delay: 280),
        const SizedBox(width: 12),
        _StatCard(icon: Icons.local_fire_department_rounded, value: '$bestStreak', label: 'Best Streak', color: const Color(0xFFFFB74D), delay: 360),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final int delay;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? c.surface : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(
            color: color.withValues(alpha: 0.2),
          ) : Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
          child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTextStyles.hostGrotesk,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? c.textPrimary : Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? c.textHint : Colors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: delay), duration: 350.ms)
          .slideY(
            begin: 0.15,
            end: 0,
            delay: Duration(milliseconds: delay),
            duration: 350.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
