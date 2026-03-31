import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../data/models/quiz_question.dart';
import '../providers/quiz_provider.dart';
import '../widgets/question_widget.dart';
import '../widgets/quiz_timer.dart';
import 'quiz_results_screen.dart';

class QuizSessionScreen extends ConsumerStatefulWidget {
  const QuizSessionScreen({super.key});

  @override
  ConsumerState<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends ConsumerState<QuizSessionScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _maybeStartTimer();
  }

  void _maybeStartTimer() {
    final session = ref.read(activeQuizProvider);
    if (session != null && session.mode == QuizMode.cashChallenge) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        ref.read(activeQuizProvider.notifier).tickTimer();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleNext() {
    final session = ref.read(activeQuizProvider);
    if (session == null) return;

    if (session.isLastQuestion) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const QuizResultsScreen()),
      );
    } else {
      ref.read(activeQuizProvider.notifier).nextQuestion();
      _timer?.cancel();
      _maybeStartTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final session = ref.watch(activeQuizProvider);

    if (session == null) {
      return Scaffold(
        backgroundColor: c.background,
        body: Center(
          child: Text(
            'No active quiz',
            style: TextStyle(color: c.textPrimary),
          ),
        ),
      );
    }

    final q = session.currentQuestion;
    final isCashMode = session.mode == QuizMode.cashChallenge;
    final modeLabel = switch (session.mode) {
      QuizMode.examPrep => 'Exam Prep',
      QuizMode.cashChallenge => 'Cash Challenge',
      QuizMode.study => 'Study Mode',
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog();
      },
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showExitDialog,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: c.surfaceHighlight.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: c.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            modeLabel,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: c.textHint,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: session.progress,
                              minHeight: 4,
                              backgroundColor:
                                  c.surfaceHighlight.withValues(alpha: 0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  c.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    if (isCashMode)
                      QuizTimer(timeRemaining: session.timeRemaining)
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: c.surfaceHighlight.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${session.currentIndex + 1}/${session.totalQuestions}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.hostGrotesk,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Question + Options ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    children: [
                      // Course tag
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: c.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${q.courseCode} · ${q.topic}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: c.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      QuestionCard(
                        key: ValueKey(q.id),
                        question: q.question,
                        options: q.options,
                        selectedOption: session.selectedOption,
                        correctIndex: q.correctIndex,
                        hasAnswered: session.hasAnswered,
                        onSelectOption: (index) {
                          ref
                              .read(activeQuizProvider.notifier)
                              .selectOption(index);
                          _timer?.cancel();
                        },
                      ),

                      // Explanation
                      if (session.hasAnswered) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: c.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: c.primary.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_rounded,
                                    color: c.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Explanation',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: c.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                q.explanation,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: c.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Bottom Action ──
              if (session.hasAnswered)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: BoxDecoration(
                    color: c.background,
                    border: Border(
                      top: BorderSide(
                        color: c.surfaceHighlight.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        session.isLastQuestion
                            ? 'See Results'
                            : 'Next Question',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    final c = context.colors;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Leave Quiz?',
          style: AppTextStyles.h3.copyWith(color: c.textPrimary),
        ),
        content: Text(
          'Your progress will be lost. Are you sure you want to exit?',
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.5,
            color: c.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Stay',
              style: AppTextStyles.bodyLarge.copyWith(
                color: c.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(activeQuizProvider.notifier).endQuiz();
              Navigator.pop(ctx);
              Navigator.of(context).pop();
            },
            child: Text(
              'Leave',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
