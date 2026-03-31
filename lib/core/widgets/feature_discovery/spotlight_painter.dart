import 'package:flutter/material.dart';

class SpotlightPainter extends CustomPainter {
  final Rect targetRect;
  final double padding;
  final double borderRadius;
  final Animation<double> progress;

  SpotlightPainter({
    required this.targetRect,
    required this.progress,
    this.padding = 8.0,
    this.borderRadius = 16.0,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Determine the full screen rect
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Expand target rect by padding and animate it via the progress value
    final paddedRect = targetRect.inflate(padding * progress.value);
    final rRect = RRect.fromRectAndRadius(
      paddedRect,
      Radius.circular(borderRadius * progress.value),
    );

    // The dark overlay color
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7 * progress.value)
      ..style = PaintingStyle.fill;

    // We use path operations to "punch a hole" in the background
    final backgroundPath = Path()..addRect(bgRect);
    
    // Only punch the hole if progress is somewhat visible, to avoid jarring start
    final holePath = Path()..addRRect(rRect);
    
    // Combine paths using Path.combine(PathOperation.difference)
    final resultantPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      holePath,
    );

    canvas.drawPath(resultantPath, paint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.progress != progress ||
        oldDelegate.padding != padding ||
        oldDelegate.borderRadius != borderRadius;
  }
}
