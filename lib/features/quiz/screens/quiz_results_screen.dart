import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../providers/quiz_provider.dart';
import '../../main_shell/providers/shell_provider.dart';

class QuizResultsScreen extends ConsumerStatefulWidget {
  const QuizResultsScreen({super.key});

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen>
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
          _lottieController.forward(from: 0);
        } else {
          _lottieController.stop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final session = ref.read(activeQuizProvider);

    if (session == null) {
      return Scaffold(
        backgroundColor: c.background,
        body: Center(
          child: Text(
            'No quiz results',
            style: TextStyle(color: c.textPrimary),
          ),
        ),
      );
    }

    final total = session.totalQuestions;
    final correct = session.score;
    final percentage = ((correct / total) * 100).round();
    final isPassing = percentage >= 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitResults(context, ref);
      },
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Lottie Celebration ──
                VisibilityDetector(
                  key: const Key('quiz_results_lottie'),
                  onVisibilityChanged: _onVisibilityChanged,
                  child: Lottie.asset(
                    isPassing
                        ? 'assets/lottie/complete.json'
                        : 'assets/lottie/books.json',
                    controller: _lottieController,
                    onLoaded: (composition) {
                      _lottieController.duration = composition.duration;
                      if (!isPassing) {
                        _lottieController.repeat();
                      } else if (_isVisible) {
                        _lottieController.forward();
                      }
                    },
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title ──
                Text(
                  isPassing ? 'Great Job! 🎉' : 'Keep Practicing! 💪',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 26,
                    color: c.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                    ),

                const SizedBox(height: 8),
                Text(
                  isPassing
                      ? 'You\'re on your way to mastering this!'
                      : 'Review the explanations and try again',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // ── Score Circle ──
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isPassing ? c.primary : AppColors.error)
                            .withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: (isPassing ? c.primary : AppColors.error)
                          .withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontFamily: AppTextStyles.hostGrotesk,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color:
                              isPassing ? c.primary : AppColors.error,
                        ),
                      ),
                      Text(
                        '$correct/$total correct',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      delay: 200.ms,
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 36),

                // ── Stats breakdown ──
                Row(
                  children: [
                    _ResultStat(
                      icon: Icons.check_circle_rounded,
                      label: 'Correct',
                      value: '$correct',
                      color: c.primary,
                      delay: 300,
                    ),
                    const SizedBox(width: 12),
                    _ResultStat(
                      icon: Icons.cancel_rounded,
                      label: 'Wrong',
                      value: '${total - correct}',
                      color: AppColors.error,
                      delay: 380,
                    ),
                    const SizedBox(width: 12),
                    _ResultStat(
                      icon: Icons.emoji_events_rounded,
                      label: 'Score',
                      value: '$percentage%',
                      color: const Color(0xFFFFB74D),
                      delay: 460,
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // ── Question Breakdown ──
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: c.surfaceHighlight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question Breakdown',
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 15,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...List.generate(total, (i) {
                        final q = session.questions[i];
                        final userAnswer = session.answers[i];
                        final isCorrectAnswer = userAnswer == q.correctIndex;
                        final isTimeout = userAnswer == -1;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isTimeout
                                      ? c.textHint.withValues(alpha: 0.15)
                                      : isCorrectAnswer
                                          ? c.primary
                                              .withValues(alpha: 0.12)
                                          : AppColors.error
                                              .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    isTimeout
                                        ? Icons.schedule_rounded
                                        : isCorrectAnswer
                                            ? Icons.check_rounded
                                            : Icons.close_rounded,
                                    size: 14,
                                    color: isTimeout
                                        ? c.textHint
                                        : isCorrectAnswer
                                            ? c.primary
                                            : AppColors.error,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  q.question,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 12,
                                    height: 1.3,
                                    color: c.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                q.courseCode,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: c.textHint,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Action Buttons ──
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(activeQuizProvider.notifier).endQuiz();
                      Navigator.of(context).pop();
                      ref.read(shellProvider.notifier).state = 1;
                    },
                    icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                    label: Text('Study with AI', style: AppTextStyles.button),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () => _exitResults(context, ref),
                    icon: Icon(Icons.arrow_back_rounded,
                        size: 20, color: c.textPrimary),
                    label: Text(
                      'Back to Quiz Arena',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: c.surfaceHighlight.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _exitResults(BuildContext context, WidgetRef ref) {
    ref.read(activeQuizProvider.notifier).endQuiz();
    Navigator.of(context).pop();
  }
}

// ── Stat Card ──

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int delay;

  const _ResultStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTextStyles.hostGrotesk,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: c.textHint,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: delay), duration: 350.ms)
          .slideY(
            begin: 0.15,
            end: 0,
            delay: Duration(milliseconds: delay),
            duration: 350.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
