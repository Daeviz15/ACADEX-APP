import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final String lottieAsset;
  final String titlePrefix;
  final String titleHighlight;
  final String description;
  final bool isActive;

  const OnboardingPage({
    super.key,
    required this.lottieAsset,
    required this.titlePrefix,
    required this.titleHighlight,
    required this.description,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        // Layer 1: Full-Screen Gradient
        // Starts INSIDE the animation bottom (38%), so it physically
        // overlaps the desk/legs, then dissolves into the dark background.
        // Max opacity is 1.5% — completely invisible until you look for it.
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,                   // 0%–37%: clear
                  Colors.transparent,                   // 37%: still clear
                  AppColors.primary.withOpacity(0.008), // 43%: barely visible at desk bottom
                  AppColors.primary.withOpacity(0.015), // 50%: peak — right at transition line
                  AppColors.primary.withOpacity(0.008), // 58%: fading behind title text
                  Colors.transparent,                   // 68%: gone completely
                  Colors.transparent,                   // 100%: clear to bottom
                ],
                stops: const [0.0, 0.37, 0.43, 0.50, 0.58, 0.68, 1.0],
              ),
            ),
          ),
        ),

        // Layer 2: Content (Animation + Text)
        Column(
          children: [
            // Top section — Lottie Animation
            SizedBox(
              height: screenHeight * 0.50,
              width: double.infinity,
              child: RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Lottie.asset(
                    lottieAsset,
                    fit: BoxFit.contain,
                    frameRate: FrameRate.max,
                    animate: isActive,
                    addRepaintBoundary: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.school_outlined,
                          size: 100,
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom section — Text Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Title with green highlighted word
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(text: titlePrefix),
                          TextSpan(
                            text: titleHighlight,
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.15),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
