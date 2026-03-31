import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';

class QuizModeCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String lottiePath;
  final Color accentColor;
  final List<Color> gradientColors;
  final Widget? badge;
  final Widget? metadata;
  final VoidCallback onTap;
  final int animationDelay;

  const QuizModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lottiePath,
    required this.accentColor,
    required this.gradientColors,
    this.badge,
    this.metadata,
    required this.onTap,
    this.animationDelay = 0,
  });

  @override
  State<QuizModeCard> createState() => _QuizModeCardState();
}

class _QuizModeCardState extends State<QuizModeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  bool _isVisible = false;

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
    final isVisible = info.visibleFraction > 0.2;
    if (isVisible != _isVisible) {
      setState(() {
        _isVisible = isVisible;
        if (_isVisible) {
          _lottieController.repeat();
        } else {
          _lottieController.stop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;

    return VisibilityDetector(
      key: Key('quiz_mode_card_${widget.title}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(22),
          splashColor: widget.accentColor.withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? c.surface : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
              border: isDark ? Border.all(
                color: widget.accentColor.withValues(alpha: 0.25),
                width: 1.5,
              ) : Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
                boxShadow: isDark ? [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                // Left accent gradient bar
                Container(
                  width: 4,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.gradientColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: AppTextStyles.h3.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: isDark ? c.textPrimary : Colors.white,
                              ),
                            ),
                          ),
                          if (widget.badge != null) widget.badge!,
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? c.textSecondary : Colors.white.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                      if (widget.metadata != null) ...[
                        const SizedBox(height: 12),
                        widget.metadata!,
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Lottie icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Lottie.asset(
                    widget.lottiePath,
                    controller: _lottieController,
                    onLoaded: (composition) {
                      _lottieController.duration = composition.duration;
                      if (_isVisible) {
                        _lottieController.repeat();
                      }
                    },
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: widget.animationDelay),
            duration: 400.ms,
          )
          .slideX(
            begin: 0.06,
            end: 0,
            delay: Duration(milliseconds: widget.animationDelay),
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
