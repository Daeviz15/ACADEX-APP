import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:acadex/core/widgets/custom_button.dart';
import 'package:acadex/features/onboarding/providers/onboarding_provider.dart';
import 'package:acadex/features/onboarding/widgets/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  // Page content data — positioned as academic ASSISTANCE/GUIDANCE
  static const List<Map<String, String>> _pages = [
    {
      'lottie': 'assets/lottie/Student.json',
      'titlePrefix': 'Your Academic\n',
      'titleHighlight': 'Assistant',
      'description':
          'Get expert guidance and learning support to ace every semester with confidence.',
    },
    {
      'lottie': 'assets/lottie/complete.json',
      'titlePrefix': 'Assignment & Project\n',
      'titleHighlight': 'Guidance',
      'description':
          'Receive step-by-step assistance and expert reviews to help you submit your best work.',
    },
    {
      'lottie': 'assets/lottie/coding.json',
      'titlePrefix': 'Custom Software,\n',
      'titleHighlight': 'Built for You',
      'description':
          'Need an app, website, or tool? Our dev team brings your ideas to life.',
    },
    {
      'lottie': 'assets/lottie/ai.json',
      'titlePrefix': 'Learn Smarter,\n',
      'titleHighlight': 'Win Cash',
      'description':
          'AI-powered study tools and quiz competitions with real cash prizes.',
    },
    {
      'lottie': 'assets/lottie/books.json',
      'titlePrefix': 'Every Past Question,\n',
      'titleHighlight': 'One App',
      'description':
          'Access thousands of past questions across universities and departments.',
    },
  ];

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
    ref.read(onboardingProvider.notifier).setPage(index);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar — Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.textSecondary,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            // PageView — All 5 onboarding pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double pageOffset = 0;
                      if (_pageController.position.haveDimensions) {
                        pageOffset = _pageController.page! - index;
                      } else {
                        pageOffset = _currentPage.toDouble() - index;
                      }

                      // Sleek scale and fade effect
                      double scale = 1 - (pageOffset.abs() * 0.15);
                      double opacity = 1 - (pageOffset.abs() * 0.8);

                      return Transform.scale(
                        scale: scale.clamp(0.85, 1.0),
                        child: Opacity(
                          opacity: opacity.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: OnboardingPage(
                      lottieAsset: page['lottie']!,
                      titlePrefix: page['titlePrefix']!,
                      titleHighlight: page['titleHighlight']!,
                      description: page['description']!,
                      isActive: index == _currentPage,
                    ),
                  );
                },
              ),
            ),

            // Bottom section — Dots + CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 32 : 8,
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
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  )
                                ]
                              : [],
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // CTA Button
                  CustomButton(
                    text: isLastPage ? 'Get Started' : 'Next',
                    onPressed: _nextPage,
                  ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
