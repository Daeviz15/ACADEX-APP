import 'dart:math';
import 'package:flutter/material.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class QuizTimer extends StatelessWidget {
  final int timeRemaining;
  final int totalTime;

  const QuizTimer({
    super.key,
    required this.timeRemaining,
    this.totalTime = 15,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final progress = timeRemaining / totalTime;
    final isUrgent = timeRemaining <= 5;

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(56, 56),
            painter: _TimerPainter(
              progress: progress,
              color: isUrgent ? AppColors.error : c.primary,
              backgroundColor: c.surfaceHighlight.withValues(alpha: 0.3),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: AppTextStyles.hostGrotesk,
              fontSize: isUrgent ? 20 : 18,
              fontWeight: FontWeight.w800,
              color: isUrgent ? AppColors.error : c.textPrimary,
            ),
            child: Text('$timeRemaining'),
          ),
        ],
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _TimerPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
