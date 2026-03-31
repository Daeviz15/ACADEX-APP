import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import 'package:acadex/core/storage/local_storage.dart';
import 'package:acadex/core/widgets/feature_discovery/feature_discovery.dart';
import '../data/models/quiz_question.dart';
import '../data/mock_quizzes.dart';
import '../providers/quiz_provider.dart';
import '../widgets/quiz_mode_card.dart';
import '../widgets/quiz_stats_row.dart';
import 'quiz_session_screen.dart';

class QuizLobbyScreen extends ConsumerStatefulWidget {
  const QuizLobbyScreen({super.key});

  @override
  ConsumerState<QuizLobbyScreen> createState() => _QuizLobbyScreenState();
}

class _QuizLobbyScreenState extends ConsumerState<QuizLobbyScreen> {
  final GlobalKey _examKey = GlobalKey();
  final GlobalKey _cashKey = GlobalKey();
  final GlobalKey _statsKey = GlobalKey();

  bool _discoveryChecked = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkAndShowDiscovery() async {
    if (_discoveryChecked) return;

    final storage = ref.read(storageServiceProvider);
    if (!storage.hasSeenQuizDiscovery) {
      _discoveryChecked = true;
      FeatureDiscoveryOverlay.show(
        context,
        steps: [
          FeatureDiscoveryStep(
            targetKey: _examKey,
            title: 'Exam Prep Mode',
            description:
                'Practice with past questions and get AI explanations for every answer to ace your exams.',
            lottiePath: 'assets/lottie/books.json',
          ),
          FeatureDiscoveryStep(
            targetKey: _cashKey,
            title: 'Cash Challenge',
            description:
                'Compete in high-stakes, timed rounds for a chance to win from the live prize pool!',
            lottiePath: 'assets/lottie/ai/fire.json',
          ),
          FeatureDiscoveryStep(
            targetKey: _statsKey,
            title: 'Track Your Mastery',
            description:
                'Keep an eye on your win rate and build a daily streak to unlock special rewards.',
          ),
        ],
        onComplete: () {
          storage.setHasSeenQuizDiscovery();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;
    final stats = ref.watch(quizStatsProvider);
    final streak = ref.watch(quizStreakProvider);

    return VisibilityDetector(
      key: const Key('quiz_lobby_visibility'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndShowDiscovery();
          });
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? c.background : const Color(0xFF00664F),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // ── Ambient Professional Background Orbs ──
            if (isDark)
              Positioned.fill(
                child: Stack(
                  children: [
                    Positioned(
                      top: 100,
                      left: -100,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF9E77ED).withValues(alpha: 0.1),
                              const Color(0xFF9E77ED).withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -50,
                      right: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              c.primary.withValues(alpha: 0.12),
                              c.primary.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? c.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? c.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: isDark ? c.primary : Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quiz Arena',
                                style: AppTextStyles.h2.copyWith(
                                  color: isDark ? c.textPrimary : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Test your knowledge, win prizes',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark ? c.textSecondary : Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Streak badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFF9500)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$streak',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.hostGrotesk,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Choose a Mode',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 18,
                        color: isDark ? c.textPrimary : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Exam Prep
                    Container(
                      key: _examKey,
                      child: QuizModeCard(
                        title: 'Exam Prep',
                        subtitle: 'Practice with mock exams & past papers',
                        lottiePath: 'assets/lottie/ai/exam.json',
                        accentColor: c.primary,
                        gradientColors: [
                          c.primary,
                          c.primary.withValues(alpha: 0.3),
                        ],
                        metadata: _buildProgressBar(
                          0.72,
                          'CSC — 72% mastered',
                          c,
                          isDark,
                        ),
                        animationDelay: 0,
                        onTap: () =>
                            _startQuiz(context, ref, QuizMode.examPrep),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cash Challenge
                    Container(
                      key: _cashKey,
                      child: QuizModeCard(
                        title: '💰  Cash Challenge',
                        subtitle: 'Win real cash prizes in timed rounds!',
                        lottiePath: 'assets/lottie/ai/fire.json',
                        accentColor: const Color(0xFFFFB74D),
                        gradientColors: const [
                          Color(0xFFFFB74D),
                          Color(0xFFFF8A65),
                        ],
                        badge: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF4C4C,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(
                                0xFFFF4C4C,
                              ).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF4C4C),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFFFF4C4C),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        metadata: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(
                                      0xFFFFB74D,
                                    ).withValues(alpha: 0.2),
                                    const Color(
                                      0xFFFF8A65,
                                    ).withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: '₦',
                                      style: TextStyle(fontFamily: ''), // Fallback font
                                    ),
                                    const TextSpan(text: '50,000 Prize Pool'),
                                  ],
                                ),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFFFFB74D),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: isDark ? c.textHint : Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '2h 34m',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? c.textHint : Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        animationDelay: 100,
                        onTap: () =>
                            _startQuiz(context, ref, QuizMode.cashChallenge),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Study Mode
                    QuizModeCard(
                      title: 'Study Mode',
                      subtitle: 'Self-paced learning to build streaks',
                      lottiePath: 'assets/lottie/ai/brain.json',
                      accentColor: const Color(0xFF9E77ED),
                      gradientColors: const [
                        Color(0xFF9E77ED),
                        Color(0xFFB392F0),
                      ],
                      metadata: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTopicPill('Data Structures'),
                          _buildTopicPill('Algorithms'),
                        ],
                      ),
                      animationDelay: 200,
                      onTap: () => _startQuiz(context, ref, QuizMode.study),
                    ),

                    const SizedBox(height: 32),

                    // ── Stats ──
                    Text(
                      'Your Stats',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 18,
                        color: isDark ? c.textPrimary : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      key: _statsKey,
                      child: QuizStatsRow(
                        totalQuizzes: stats.totalQuizzes,
                        winRate: stats.winRate,
                        bestStreak: stats.bestStreak,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context, WidgetRef ref, QuizMode mode) {
    ref.read(activeQuizProvider.notifier).startQuiz(mode, mockQuizQuestions);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const QuizSessionScreen()));
  }

  Widget _buildProgressBar(double progress, String label, AppColorScheme c, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: c.surfaceHighlight.withValues(alpha: 0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                ),
              ),
            ),
            const SizedBox(width: 10),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontFamily: AppTextStyles.hostGrotesk,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? c.primary : const Color(0xFF4ADE80),
                  ),
                ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? c.textHint : Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTopicPill(String topic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF9E77ED).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        topic,
        style: AppTextStyles.bodySmall.copyWith(
          color: const Color(0xFFB392F0),
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
