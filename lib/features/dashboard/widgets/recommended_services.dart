import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../providers/service_bookmark_provider.dart';
import 'service_request_sheet.dart';

/// Data model for a recommended service card.
class _ServiceData {
  final String id;
  final String title;
  final String subtitle;
  final String lottie;
  final IconData icon;
  final List<String> placeholders;

  const _ServiceData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.lottie,
    required this.icon,
    required this.placeholders,
  });
}

const _services = <_ServiceData>[
  _ServiceData(
    id: 'academic_guidance',
    title: 'Academic\nGuidance',
    subtitle: 'Expert academic advice',
    lottie: 'assets/lottie/dashboard/guidiance.json',
    icon: Icons.school_rounded,
    placeholders: [
      'I need advice on selecting courses for next semester...',
      'How do I balance my study time?',
      'I need help preparing a study plan for midterms...',
    ],
  ),
  _ServiceData(
    id: 'custom_software',
    title: 'Custom\nSoftware',
    subtitle: 'Tailored software solutions',
    lottie: 'assets/lottie/dashboard/software.json',
    icon: Icons.code_rounded,
    placeholders: [
      'I need a software for my final year project...',
      'Can you build a website for my business?',
      'I need a mobile app built to track my inventory...',
    ],
  ),
  _ServiceData(
    id: 'final_year_project',
    title: 'Final Year Project\nAssistance',
    subtitle: 'End-to-end project support',
    lottie: 'assets/lottie/dashboard/project.json',
    icon: Icons.engineering_rounded,
    placeholders: [
      'How do I choose a topic for my project?',
      'I want you to handle my full project work.',
      'I need guidance on corrections from my supervisor...',
    ],
  ),
  _ServiceData(
    id: 'assignment_assistance',
    title: 'Assignment\nAssistance',
    subtitle: 'Ace every assignment',
    lottie: 'assets/lottie/dashboard/assignment.json',
    icon: Icons.edit_document,
    placeholders: [
      'I need assistance with a calculus assignment...',
      'Can you review my essay before I submit?',
      'I need help debugging a programming lab...',
    ],
  ),
  _ServiceData(
    id: 'past_questions',
    title: 'Request Past\nQuestion',
    subtitle: 'Specific past question access',
    lottie: 'assets/lottie/documents.json',
    icon: Icons.quiz_rounded,
    placeholders: [
      'Requesting MTH101 past questions for 2021/2022...',
      'Do you have PHY102 past questions?',
      'I need the last 5 years of ACC201 exams...',
    ],
  ),
  _ServiceData(
    id: 'tutoring_mentorship',
    title: 'Tutoring &\nMentorship',
    subtitle: 'One-on-one guidance',
    lottie: 'assets/lottie/dashboard/guidiance_two.json',
    icon: Icons.people_alt_rounded,
    placeholders: [
      'I need a tutor for introductory Python...',
      'Can I get a mentor for my career path?',
      'I need weekly tutoring for genetics...',
    ],
  ),
];

class RecommendedServices extends ConsumerWidget {
  const RecommendedServices({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Recommended services for you',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Based on your activity',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal Scrollable Cards
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _ServiceCard(
                data: _services[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual service card with visibility-aware Lottie animation.
class _ServiceCard extends ConsumerStatefulWidget {
  final _ServiceData data;

  const _ServiceCard({required this.data});

  @override
  ConsumerState<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends ConsumerState<_ServiceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  bool _isVisible = false;
  bool _isCompositionLoaded = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    final visible = info.visibleFraction > 0.5;
    if (visible != _isVisible) {
      _isVisible = visible;
      if (_isCompositionLoaded) {
        if (_isVisible) {
          _lottieController.repeat();
        } else {
          _lottieController.stop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = ref.watch(serviceBookmarkProvider);
    final isBookmarked = bookmarks[widget.data.id] ?? false;

    return VisibilityDetector(
      key: Key('service_${widget.data.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: () {
          ServiceRequestSheet.show(
            context,
            serviceId: widget.data.id,
            serviceTitle: widget.data.title,
            placeholders: widget.data.placeholders,
            icon: widget.data.icon,
          );
        },
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.surfaceHighlight.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // ── Lottie Animation (top section) ──
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 150,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight.withOpacity(0.3),
                    ),
                    child: Lottie.asset(
                      widget.data.lottie,
                      controller: _lottieController,
                      onLoaded: (composition) {
                        _lottieController.duration = composition.duration;
                        _isCompositionLoaded = true;
                        if (_isVisible) {
                          _lottieController.repeat();
                        }
                      },
                      fit: BoxFit.contain,
                      frameRate: FrameRate.max,
                      addRepaintBoundary: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            widget.data.icon,
                            color: AppColors.primary.withOpacity(0.5),
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── Subtle green overlay blend ──
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 150,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.06),
                          AppColors.primary.withOpacity(0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Gradient fade between Lottie and info section ──
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.surface,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Info section (bottom) ──
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 12, 14),
                    color: AppColors.surface,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Title + subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.data.title,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.montserrat,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.data.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.urbanist,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bookmark button
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(serviceBookmarkProvider.notifier)
                                .toggle(widget.data.id);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isBookmarked
                                  ? AppColors.primary
                                  : AppColors.surfaceHighlight.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: isBookmarked
                                  ? Colors.black
                                  : AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Subtle green accent line at top ──
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.0),
                          AppColors.primary.withOpacity(0.6),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
