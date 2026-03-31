import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

/// Model for a single study goal.
class StudyGoal {
  final String subject;
  final double progress; // 0.0 – 1.0
  final Color ringColor;

  const StudyGoal({
    required this.subject,
    required this.progress,
    required this.ringColor,
  });
}

/// Mock data — will be replaced by Riverpod provider later.
final List<StudyGoal> mockStudyGoals = [
  const StudyGoal(
    subject: 'Mathematics',
    progress: 0.75,
    ringColor: AppColors.primary,
  ),
  const StudyGoal(
    subject: 'Physics',
    progress: 0.56,
    ringColor: Color(0xFF7C4DFF),
  ),
  const StudyGoal(
    subject: 'Chemistry',
    progress: 0.37,
    ringColor: Color(0xFF00BCD4),
  ),
];

class StudyProgressRow extends StatelessWidget {
  const StudyProgressRow({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Progress',
                style: AppTextStyles.h3.copyWith(fontSize: 18, color: c.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: c.surfaceHighlight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'This week',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: c.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: c.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress Rings Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? c.surface : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: mockStudyGoals.asMap().entries.map((entry) {
                final index = entry.key;
                final goal = entry.value;
                return _ProgressRing(goal: goal)
                    .animate()
                    .fadeIn(
                      duration: 500.ms,
                      delay: Duration(milliseconds: 150 * index),
                    )
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      delay: Duration(milliseconds: 150 * index),
                      curve: Curves.easeOutBack,
                    );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatefulWidget {
  final StudyGoal goal;

  const _ProgressRing({required this.goal});

  @override
  State<_ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<_ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = Tween<double>(
      begin: 0.0,
      end: widget.goal.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start the animation after frame paints
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Column(
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: AnimatedBuilder(
            animation: _progressAnim,
            builder: (context, child) {
              return CustomPaint(
                painter: _RingPainter(
                  progress: _progressAnim.value,
                  ringColor: widget.goal.ringColor,
                  trackColor: widget.goal.ringColor.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    '${(_progressAnim.value * 100).toInt()}%',
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: widget.goal.ringColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.goal.subject,
          style: AppTextStyles.bodySmall.copyWith(
            color: widget.goal.ringColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 8.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
