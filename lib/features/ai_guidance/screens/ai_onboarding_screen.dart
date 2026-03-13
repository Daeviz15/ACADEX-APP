import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:acadex/config/theme/app_colors.dart';

import 'package:acadex/config/theme/app_text_styles.dart';
import '../providers/ai_onboarding_provider.dart';

class AiOnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const AiOnboardingScreen({super.key, required this.onComplete});

  @override
  ConsumerState<AiOnboardingScreen> createState() => _AiOnboardingScreenState();
}

class _AiOnboardingScreenState extends ConsumerState<AiOnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await ref.read(aiOnboardingProvider.notifier).completeOnboarding();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient background glow — subtle green orb at top center
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 800),
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      AppColors.primary.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _completeOnboarding,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighlight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.surfaceHighlight.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Skip',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                // PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _AiOnboardingPage1(isActive: _currentPage == 0),
                      _AiOnboardingPage2(isActive: _currentPage == 1),
                      _AiOnboardingPage3(isActive: _currentPage == 2),
                    ],
                  ),
                ),

                // Bottom: dot indicators + call to action
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
                  child: Column(
                    children: [
                      // Dot row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.surfaceHighlight,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.4),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),

                      // Continue / Get Started button with glow
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == 2 ? 'Get Started' : 'Continue',
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.montserrat,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentPage == 2
                                      ? Icons.rocket_launch_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 1: Meet Your AI Study Companion
// ─────────────────────────────────────────────────────────────────────────────
class _AiOnboardingPage1 extends StatelessWidget {
  final bool isActive;
  const _AiOnboardingPage1({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Bot + floating chat bubbles — no glass background
          SizedBox(
            height: screenHeight * 0.42,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Subtle circular glow behind the bot
                Positioned(
                  bottom: 20,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Bot Lottie — shifted down
                Positioned(
                  top: 30,
                  left: 40,
                  right: 40,
                  bottom: 0,
                  child: Lottie.asset(
                    'assets/lottie/ai/bot.json',
                    animate: isActive,
                    fit: BoxFit.contain,
                    frameRate: FrameRate.max,
                    addRepaintBoundary: true,
                  ),
                ),

                // "Hello! 👋" bubble — top right
                Positioned(
                  top: 20,
                  right: 16,
                  child: _chatBubble(
                    text: 'Hello! 👋',
                    color: Colors.white,
                    textColor: Colors.black87,
                    delay: 400,
                  ),
                ),

                // "How Can I Help?" bubble — mid left
                Positioned(
                  top: screenHeight * 0.16,
                  left: 0,
                  child: _chatBubble(
                    text: 'How Can I Help?',
                    color: AppColors.primary,
                    textColor: Colors.black,
                    delay: 600,
                  ),
                ),

                // "Let's Chat" bubble — bottom right
                Positioned(
                  bottom: 10,
                  right: 8,
                  child: _chatBubble(
                    text: "Let's Chat",
                    color: AppColors.surfaceHighlight,
                    textColor: AppColors.textPrimary,
                    delay: 800,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms),

          const Spacer(),

          // Title
          Text(
            'Meet Your AI',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTextStyles.montserrat,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.15),

          // Highlighted word
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ).createShader(bounds),
            child: Text(
              'Study Companion',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.montserrat,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.15),

          const SizedBox(height: 14),

          // Description
          Text(
            'Get instant, expert answers to ace your\nassignments, projects, and exams.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _chatBubble({
    required String text,
    required Color color,
    required Color textColor,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style:  TextStyle(
          fontFamily: AppTextStyles.montserrat,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(begin: 0.3, curve: Curves.easeOutBack);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 2: Chat Smarter, Study Better
// ─────────────────────────────────────────────────────────────────────────────
class _AiOnboardingPage2 extends StatelessWidget {
  final bool isActive;
  const _AiOnboardingPage2({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Chat-style showcase
          SizedBox(
            height: screenHeight * 0.38,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.08),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    // Brain animation as a subtle backdrop
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.12,
                        child: Lottie.asset(
                          'assets/lottie/ai/brain.json',
                          animate: isActive,
                          fit: BoxFit.cover,
                          frameRate: FrameRate.max,
                          addRepaintBoundary: true,
                        ),
                      ),
                    ),
                    // Use-case chat bubbles
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _useCaseBubble(
                            icon: Icons.school_rounded,
                            label: 'Assignments',
                            text: 'Help me structure my thesis on renewable energy.',
                            alignment: Alignment.centerLeft,
                            delay: 100,
                          ),
                          _useCaseBubble(
                            icon: Icons.psychology_rounded,
                            label: 'Learning',
                            text: 'Explain photosynthesis like I\'m 10 years old.',
                            alignment: Alignment.centerRight,
                            delay: 250,
                          ),
                          _useCaseBubble(
                            icon: Icons.code_rounded,
                            label: 'Projects',
                            text: 'Debug my Python function for sorting algorithms.',
                            alignment: Alignment.centerLeft,
                            delay: 400,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).scale(
                begin: const Offset(0.95, 0.95),
                curve: Curves.easeOutBack,
              ),

          const Spacer(),

          // Title
          Text(
            'Chat Smarter,',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTextStyles.montserrat,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.15),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ).createShader(bounds),
            child: Text(
              'Study Better',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.montserrat,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.15),

          const SizedBox(height: 14),

          Text(
            'Ask anything about your coursework and get\nstep-by-step guidance from your AI tutor.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _useCaseBubble({
    required IconData icon,
    required String label,
    required String text,
    required Alignment alignment,
    required int delay,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        child: Column(
          crossAxisAlignment: alignment == Alignment.centerLeft
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            // Green tag pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 12, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.montserrat,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            // Chat message bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.surfaceHighlight.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Text(
                text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.85),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms).slideX(
          begin: alignment == Alignment.centerLeft ? -0.1 : 0.1,
          curve: Curves.easeOut,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE 3: Your Academic Superpowers (Feature Grid — all Lottie animated)
// ─────────────────────────────────────────────────────────────────────────────
class _AiOnboardingPage3 extends StatelessWidget {
  final bool isActive;
  const _AiOnboardingPage3({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // 2x2 Feature Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top row
                  Row(
                    children: [
                      Expanded(
                        child: _featureTile(
                          title: 'Assignment\nHelp',
                          lottie: 'assets/lottie/ai/light.json',
                          isActive: isActive,
                          delay: 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _featureTile(
                          title: 'Code\nAssistance',
                          lottie: 'assets/lottie/ai/code.json',
                          isActive: isActive,
                          delay: 100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bottom row
                  Row(
                    children: [
                      Expanded(
                        child: _featureTile(
                          title: 'Exam\nPreparation',
                          lottie: 'assets/lottie/ai/exam.json',
                          isActive: isActive,
                          delay: 200,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _featureTile(
                          title: 'Explain\nConcepts',
                          lottie: 'assets/lottie/ai/explain.json',
                          isActive: isActive,
                          delay: 300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Title
          Text(
            'Your Academic',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTextStyles.montserrat,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.15),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ).createShader(bounds),
            child: Text(
              'Superpowers',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.montserrat,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.15),

          const SizedBox(height: 14),

          Text(
            'Unlock smart AI tools built specifically\nfor students like you.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _featureTile({
    required String title,
    required String lottie,
    required bool isActive,
    required int delay,
  }) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 56,
              width: 56,
              child: Lottie.asset(
                lottie,
                animate: isActive,
                fit: BoxFit.contain,
                frameRate: FrameRate.max,
                addRepaintBoundary: true,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.montserrat,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 500.ms,
        ).scale(
          begin: const Offset(0.9, 0.9),
          delay: Duration(milliseconds: delay),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        );
  }
}
