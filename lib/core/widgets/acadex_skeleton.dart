import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:acadex/config/theme/app_colors.dart';

/// A professional, theme-aware shimmer skeleton loader for Acadex.
/// Use this to replace spinners and provide a premium "loading" feel.
class AcadexSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const AcadexSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  /// Factory for circular skeletons (like profile pictures)
  factory AcadexSkeleton.circle({required double size}) {
    return AcadexSkeleton(
      width: size,
      height: size,
      shape: BoxShape.circle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    // Shimmer colors derived from the theme's surface/highlight
    final baseColor = c.surfaceHighlight;
    final highlightColor = c.surface.withValues(alpha: 0.5);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? BorderRadius.circular(8)),
          shape: shape,
        ),
      ),
    );
  }
}
