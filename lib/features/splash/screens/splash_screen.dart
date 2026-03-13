import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../../onboarding/providers/onboarding_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _textDrawController;
  late final AnimationController _elementsFadeController;

  @override
  void initState() {
    super.initState();

    // Controller for the custom text drawing animation
    _textDrawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Controller for fading in the tagline and corner graphics
    _elementsFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // 1. Start drawing the "Acadex" text
    _textDrawController.forward();

    // 2. Wait a bit, then fade in the surrounding elements (lottie hat, corners, tagline)
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      _elementsFadeController.forward();
    }

    // 3. Wait for all animations to finish and keep splash on screen to let users appreciate it
    await Future.delayed(const Duration(milliseconds: 4200));

    // 4. Navigate out
    if (mounted) {
      // Check onboarding state to decide next route
      final isCompleted = ref.read(onboardingProvider).isCompleted;
      if (isCompleted) {
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _textDrawController.dispose();
    _elementsFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Corner Graphic - Top Right
          Positioned(
            top: -50,
            right: -50,
            child: FadeTransition(
              opacity: _elementsFadeController,
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Corner Graphic - Bottom Left
          Positioned(
            bottom: -50,
            left: -50,
            child: FadeTransition(
              opacity: _elementsFadeController,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hat Lottie (replacing beer mug)
                FadeTransition(
                  opacity: _elementsFadeController,
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Lottie.asset(
                      'assets/lottie/hat.json',
                      fit: BoxFit.contain,
                      repeat: false,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Animated "Acadex" Custom Painter
                SizedBox(
                  width: 180,
                  height: 40,
                  child: AnimatedBuilder(
                    animation: _textDrawController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: AcadexTextPainter(
                          progress: _textDrawController.value,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Tagline
                FadeTransition(
                  opacity: _elementsFadeController,
                  child: Text(
                    'YOUR ACADEMIC COMPANION',
                    style: TextStyle(
                      fontFamily: AppTextStyles.hostGrotesk,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Painter for Animating "ACADEX" ──────────────────────────────

class AcadexTextPainter extends CustomPainter {
  final double progress;
  final Color color;

  AcadexTextPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final paths = _getPaths();
    final totalWidth = 184.0;
    final totalHeight = 36.0;
    final scale = (size.width / totalWidth).clamp(0.0, size.height / totalHeight);
    final dx = (size.width - (totalWidth * scale)) / 2;
    final dy = (size.height - (totalHeight * scale)) / 2;
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);
    final letterDuration = 0.5;
    final staggerDelay = (1.0 - letterDuration) / (paths.length - 1);

    for (int i = 0; i < paths.length; i++) {
      final start = i * staggerDelay;
      final end = start + letterDuration;
      final letterProgress = ((progress - start) / letterDuration).clamp(0.0, 1.0);

      if (letterProgress > 0) {
        _drawProgressivePath(canvas, paths[i], paint, letterProgress);
      }
    }
  }

  void _drawProgressivePath(Canvas canvas, Path path, Paint paint, double pathProgress) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final extractLength = metric.length * pathProgress;
      final extracted = metric.extractPath(0, extractLength);
      canvas.drawPath(extracted, paint);
    }
  }

  List<Path> _getPaths() {
    final paths = <Path>[];
    double cursorX = 0;
    const letterWidth = 24.0;
    const spacing = 8.0;

    // A
    paths.add(Path()
      ..moveTo(cursorX, 36)
      ..lineTo(cursorX + 12, 0)
      ..lineTo(cursorX + 24, 36)
      ..moveTo(cursorX + 6, 18)
      ..lineTo(cursorX + 18, 18));
    cursorX += letterWidth + spacing;

    // C
    paths.add(Path()
      ..moveTo(cursorX + 24, 6)
      ..arcToPoint(Offset(cursorX + 24, 30),
          radius: const Radius.circular(16), clockwise: false));
    cursorX += letterWidth + spacing;

    // A
    paths.add(Path()
      ..moveTo(cursorX, 36)
      ..lineTo(cursorX + 12, 0)
      ..lineTo(cursorX + 24, 36)
      ..moveTo(cursorX + 6, 18)
      ..lineTo(cursorX + 18, 18));
    cursorX += letterWidth + spacing;

    // D
    paths.add(Path()
      ..moveTo(cursorX, 0)
      ..lineTo(cursorX, 36)
      ..moveTo(cursorX, 0)
      ..arcToPoint(Offset(cursorX, 36),
          radius: const Radius.circular(18), clockwise: true));
    cursorX += letterWidth + spacing;

    // E
    paths.add(Path()
      ..moveTo(cursorX + 24, 0)
      ..lineTo(cursorX, 0)
      ..lineTo(cursorX, 36)
      ..lineTo(cursorX + 24, 36)
      ..moveTo(cursorX, 18)
      ..lineTo(cursorX + 18, 18));
    cursorX += letterWidth + spacing;

    // X
    paths.add(Path()
      ..moveTo(cursorX, 0)
      ..lineTo(cursorX + 24, 36)
      ..moveTo(cursorX + 24, 0)
      ..lineTo(cursorX, 36));

    return paths;
  }

  @override
  bool shouldRepaint(covariant AcadexTextPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
