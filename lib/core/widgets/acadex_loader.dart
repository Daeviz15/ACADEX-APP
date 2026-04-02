import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:acadex/config/theme/app_colors.dart';

/// A reusable Lottie-based loader widget that properly manages its animation
/// controller lifecycle. Use this everywhere instead of CircularProgressIndicator.
///
/// Usage:
/// ```dart
/// const AcadexLoader()          // Default 60x60
/// const AcadexLoader(size: 40)  // Custom size
/// const AcadexLoader(size: 24)  // Inline/button size
/// ```
class AcadexLoader extends StatefulWidget {
  final double size;

  const AcadexLoader({super.key, this.size = 60});

  @override
  State<AcadexLoader> createState() => _AcadexLoaderState();
}

class _AcadexLoaderState extends State<AcadexLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.asset(
        'assets/lottie/allLoad.json',
        controller: _controller,
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          _controller.repeat();
        },
        fit: BoxFit.contain,
      ),
    );
  }
}


/// A custom RefreshIndicator that shows the Lottie loader dragging down.
/// Wraps the child in a CustomRefreshIndicator.
///
/// Usage:
/// ```dart
/// AcadexRefreshIndicator(
///   onRefresh: () async { await fetchData(); },
///   child: ListView(...),
/// )
/// ```
class AcadexRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;

  const AcadexRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      offsetToArmed: 70,
      builder: (BuildContext context, Widget child, IndicatorController controller) {
        return Stack(
          children: [
            child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, -60.0 + (controller.value * 110.0)),
                    child: Opacity(
                      // Fade in as the user pulls down
                      opacity: controller.value.clamp(0.0, 1.0),
                      child: Center(
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: backgroundColor ?? context.colors.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          // The spinning Lottie itself
                          child: const AcadexLoader(size: 50),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

