import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:acadex/core/widgets/acadex_skeleton.dart';
import '../providers/service_bookmark_provider.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_models.dart';
import 'service_request_sheet.dart';

class RecommendedServices extends ConsumerWidget {
  const RecommendedServices({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final servicesAsync = ref.watch(recommendedServicesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Recommended services for you',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Based on your activity',
          style: AppTextStyles.bodyMedium.copyWith(
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        servicesAsync.when(
          data: (services) => _RecommendedCarousel(services: services),
          loading: () => const AcadexSkeleton(height: 270, width: double.infinity),
          error: (err, stack) => Center(
            child: Text(
              'Failed to load services',
              style: TextStyle(color: c.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendedCarousel extends StatefulWidget {
  final List<ServiceRecommendation> services;
  const _RecommendedCarousel({required this.services});

  @override
  State<_RecommendedCarousel> createState() => _RecommendedCarouselState();
}

class _RecommendedCarouselState extends State<_RecommendedCarousel> {
  late PageController _pageController;
  double _currentPage = 1.0;
  Timer? _autoScrollTimer;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1, viewportFraction: 0.75);
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page ?? 0.0;
        });
      }
    });

    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isUserScrolling && _pageController.hasClients) {
        int nextPage = (_pageController.page?.round() ?? 1) + 1;
        if (nextPage >= widget.services.length) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.services.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 270,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification) {
            _isUserScrolling = true;
            _stopAutoScroll();
          } else if (notification is ScrollEndNotification) {
            _isUserScrolling = false;
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (!_isUserScrolling && mounted) {
                _startAutoScroll();
              }
            });
          }
          return false;
        },
        child: PageView.builder(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.services.length,
          itemBuilder: (context, index) {
            double scale = 1.0;
            double opacity = 1.0;

            if (_pageController.hasClients && _pageController.position.haveDimensions) {
              final distanceInfo = (_currentPage - index).abs();
              scale = 1 - (distanceInfo * 0.15).clamp(0.0, 0.3);
              opacity = 1 - (distanceInfo * 0.4).clamp(0.0, 0.6);
            }

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Align(
                  alignment: Alignment.center,
                  child: _ServiceCard(
                    data: widget.services[index],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ServiceCard extends ConsumerStatefulWidget {
  final ServiceRecommendation data;

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
    final c = context.colors;
    final isDark = context.isDarkMode;
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
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: c.surfaceHighlight.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : c.primary).withValues(alpha: 0.08),
                blurRadius: 32,
                spreadRadius: -4,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 160,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? c.surfaceHighlight.withValues(alpha: 0.3)
                          : c.primary.withValues(alpha: 0.02),
                    ),
                    child: Stack(
                      children: [
                        if (!isDark) ...[
                          Positioned(
                            top: -20,
                            right: -20,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.primary.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -10,
                            left: 20,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                        ],
                        Positioned.fill(
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
                                  color: c.primary.withValues(alpha: 0.5),
                                  size: 48,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 160,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          c.primary.withValues(alpha: 0.06),
                          c.primary.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 12, 14),
                    color: c.surface,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.data.title,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.montserrat,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: c.textPrimary,
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
                                  color: c.textSecondary.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                  ? c.primary
                                  : c.surfaceHighlight.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: isBookmarked
                                  ? Colors.white
                                  : c.textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          c.primary.withValues(alpha: 0.0),
                          c.primary.withValues(alpha: 0.6),
                          c.primary.withValues(alpha: 0.0),
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
