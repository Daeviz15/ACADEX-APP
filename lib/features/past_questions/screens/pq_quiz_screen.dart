import 'package:acadex/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:acadex/config/theme/app_colors.dart';
import 'package:acadex/config/theme/app_text_styles.dart';
import '../data/models/past_question.dart';
import '../data/models/quiz_question.dart';
import '../data/pq_repository.dart';
import '../providers/pq_quiz_provider.dart';
import '../../../core/utils/text_similarity.dart';
import '../../../core/utils/quiz_feedback_generator.dart';
import '../services/quiz_progress_service.dart';
import 'package:lottie/lottie.dart';

class PqQuizScreen extends ConsumerStatefulWidget {
  final PastQuestion question;
  const PqQuizScreen({super.key, required this.question});

  @override
  ConsumerState<PqQuizScreen> createState() => _PqQuizScreenState();
}

class _PqQuizScreenState extends ConsumerState<PqQuizScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  String? _selectedMode;
  bool _modeSelected = false;

  /// Tracks the user's selected option index per question (Objective).
  final Map<int, int> _selectedAnswers = {};

  /// Tracks text answers (Theory).
  final Map<int, String> _theoryAnswers = {};
  
  /// Stores locally evaluated theory scores (now given by AI).
  final Map<int, double> _theoryScores = {};

  /// Stores the personalized AI feedback for theory questions.
  final Map<int, String> _theoryAIFeedbacks = {};

  /// Tracks if a theory question is currently being graded by the AI.
  final Map<int, bool> _isGradingTheory = {};

  /// Tracks whether the user has "confirmed" their answer for a question.
  final Map<int, bool> _answeredQuestions = {};

  int _correctCount = 0;
  bool _quizFinished = false;

  int _currentWinStreak = 0;
  int _currentFailStreak = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSavedProgress();
    });
  }

  Future<void> _checkSavedProgress() async {
    final service = ref.read(quizProgressServiceProvider);
    final savedState = await service.queryProgress(widget.question.id);
    if (savedState != null && mounted) {
      _showResumeDialog(savedState);
    }
  }

  void _showResumeDialog(QuizProgressState state) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restore_rounded, size: 56, color: context.colors.primary),
              const SizedBox(height: 16),
              Text("Resume Quiz?", style: AppTextStyles.h2.copyWith(color: context.colors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                "You have an unfinished session for this paper. Would you like to resume where you left off?",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentPage = state.currentPage;
                      _selectedAnswers.addAll(state.selectedAnswers);
                      _theoryAnswers.addAll(state.theoryAnswers);
                      _theoryScores.addAll(state.theoryScores);
                      _theoryAIFeedbacks.addAll(state.theoryAIFeedbacks);
                      _answeredQuestions.addAll(state.answeredQuestions);
                      _correctCount = state.correctCount;
                      _currentWinStreak = state.currentWinStreak;
                      _currentFailStreak = state.currentFailStreak;
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(_currentPage);
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text("Yes, Resume", style: AppTextStyles.button.copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    ref.read(quizProgressServiceProvider).clearProgress(widget.question.id);
                    Navigator.pop(ctx);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text("No, Start Fresh", style: AppTextStyles.button.copyWith(color: context.colors.error)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_quizFinished || _answeredQuestions.isEmpty) {
      ref.read(quizProgressServiceProvider).clearProgress(widget.question.id);
      return true;
    }

    bool shouldPop = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pause_circle_filled_rounded, size: 56, color: context.colors.primary),
              const SizedBox(height: 16),
              Text("Hold on, Scholar!", style: AppTextStyles.h2.copyWith(color: context.colors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                "You are mid-way through this quiz. Do you want to save your progress and return later, or quit entirely?",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: context.colors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final state = QuizProgressState(
                      currentPage: _currentPage,
                      selectedAnswers: _selectedAnswers,
                      theoryAnswers: _theoryAnswers,
                      theoryScores: _theoryScores,
                      theoryAIFeedbacks: _theoryAIFeedbacks,
                      answeredQuestions: _answeredQuestions,
                      correctCount: _correctCount,
                      currentWinStreak: _currentWinStreak,
                      currentFailStreak: _currentFailStreak,
                    );
                    await ref.read(quizProgressServiceProvider).saveProgress(widget.question.id, state);
                    if (mounted) {
                      Navigator.pop(ctx);
                      shouldPop = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Saved! Come back later to complete.", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          backgroundColor: const Color(0xFF00AA55),
                          behavior: SnackBarBehavior.floating,
                        )
                      );
                    }
                  },
                  icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                  label: Text("Save & Continue Later", style: AppTextStyles.button.copyWith(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await ref.read(quizProgressServiceProvider).clearProgress(widget.question.id);
                    if (mounted) {
                      Navigator.pop(ctx);
                      shouldPop = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Progress discarded. See you next time!", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          backgroundColor: context.colors.error,
                          behavior: SnackBarBehavior.floating,
                        )
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.colors.error, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Quit Entirely", style: AppTextStyles.button.copyWith(color: context.colors.error)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text("Keep Grinding", style: AppTextStyles.button.copyWith(color: context.colors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return shouldPop;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectOption(int questionIndex, int optionIndex) {
    if (_answeredQuestions[questionIndex] == true) return;
    setState(() {
      _selectedAnswers[questionIndex] = optionIndex;
    });
  }

  Future<void> _confirmAnswer(int questionIndex, List<QuizQuestion> questions, String userName) async {
    if (_answeredQuestions[questionIndex] == true) return;
    if (_isGradingTheory[questionIndex] == true) return;
    
    final question = questions[questionIndex];
    bool isCorrect = false;

    if (question.questionType == 'objective') {
      if (_selectedAnswers[questionIndex] == null) return;
      final selectedOptionIndex = _selectedAnswers[questionIndex]!;
      final selectedOptionText = question.options[selectedOptionIndex];
      
      if (question.correctAnswer.length == 1) {
          final mappedLetter = String.fromCharCode(65 + selectedOptionIndex);
          isCorrect = (mappedLetter == question.correctAnswer.toUpperCase());
      } else {
          isCorrect = (selectedOptionText.trim() == question.correctAnswer.trim());
      }
    } else {
      if (_theoryAnswers[questionIndex] == null || _theoryAnswers[questionIndex]!.trim().isEmpty) return;
      
      // Set Loading State
      setState(() {
        _isGradingTheory[questionIndex] = true;
      });

      try {
        final repo = ref.read(pqRepositoryProvider);
        final result = await repo.gradeTheoryAnswer(
          questionText: question.questionText,
          idealAnswer: question.correctAnswer,
          userAnswer: _theoryAnswers[questionIndex]!,
          userName: userName,
        );

        final score = (result['score'] as num?)?.toDouble() ?? 0.0;
        _theoryScores[questionIndex] = score;
        _theoryAIFeedbacks[questionIndex] = result['feedback']?.toString() ?? "Good attempt!";
        isCorrect = (score >= 50.0);
      } catch (e) {
        // Fallback or handle error
        _theoryScores[questionIndex] = 0.0;
        _theoryAIFeedbacks[questionIndex] = "Network issue: Unable to grade your answer. Check connection.";
        isCorrect = false;
      }

      // Finish Loading State
      setState(() {
        _isGradingTheory[questionIndex] = false;
      });
    }

    setState(() {
      _answeredQuestions[questionIndex] = true;
      if (isCorrect) {
        _correctCount++;
        _currentWinStreak++;
        _currentFailStreak = 0;
      } else {
        _currentFailStreak++;
        _currentWinStreak = 0;
      }
    });

    // Only show the pop-up overlay for objective questions. 
    // Theory questions have their own detailed inline UI feedback.
    if (question.questionType == 'objective') {
      _showFeedbackOverlay(isCorrect, userName);
    }
  }

  void _showFeedbackOverlay(bool isCorrect, String name) {
    if (!mounted) return;
    final feedback = QuizFeedbackGenerator.getFeedback(
      name: name,
      isCorrect: isCorrect,
      failStreak: _currentFailStreak,
      winStreak: _currentWinStreak,
    );

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50 + MediaQuery.of(context).padding.top,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isCorrect ? const Color(0xFF00AA55) : const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        isCorrect ? "🔥" : "💀",
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          feedback,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.outfit,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentPage < totalQuestions - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      setState(() => _quizFinished = true);
      // Clear persistence since user naturally completed the quiz
      ref.read(quizProgressServiceProvider).clearProgress(widget.question.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDarkMode;
    final quizAsync = ref.watch(pqQuizProvider(widget.question.id));
    final authState = ref.watch(authNotifierProvider);
    final userName = authState.value?.name ?? 'Scholar';
    
    final accent = isDark ? c.primary : const Color(0xFF00664F);

    return Scaffold(
      backgroundColor: c.background,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.of(context).pop();
          }
        },
        child: quizAsync.when(
        loading: () => _buildLoadingState(c, accent),
        error: (err, _) => _buildErrorState(c, err),
        data: (rawQuestions) {
          if (rawQuestions.isEmpty) return _buildEmptyState(c, accent);

          final hasObjective = rawQuestions.any((q) => q.questionType == 'objective');
          final hasTheory = rawQuestions.any((q) => q.questionType == 'theory');

          if (!_modeSelected) {
            if (hasObjective && hasTheory) {
              return _buildModeSelector(c, accent, isDark);
            } else {
              Future.microtask(() {
                if (mounted) {
                  setState(() {
                    _selectedMode = hasObjective ? 'objective' : 'theory';
                    _modeSelected = true;
                  });
                }
              });
              return _buildLoadingState(c, accent);
            }
          }

          final questions = rawQuestions.where((q) => q.questionType == _selectedMode).toList();
          if (questions.isEmpty) return _buildEmptyState(c, accent);

          if (_quizFinished) {
            return _buildResultsScreen(c, accent, isDark, questions);
          }
          return _buildQuizBody(c, accent, isDark, questions, userName);
        },
      ),
    ));
  }

  // ── Loading State ──
  Widget _buildLoadingState(AppColorScheme c, Color accent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading quiz...',
            style: AppTextStyles.bodyLarge.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Mode Selector ──
  Widget _buildModeSelector(AppColorScheme c, Color accent, bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(c, accent, null),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.hub_rounded, size: 56, color: accent),
                    ).animate().scale(delay: 100.ms, begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                    const SizedBox(height: 32),
                    Text(
                      "Select Quiz Mode",
                      style: AppTextStyles.h3.copyWith(color: c.textPrimary),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 12),
                    Text(
                      "This exam paper contains both objective and theory questions. How would you like to practice?",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary, height: 1.5),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.radio_button_checked_rounded, size: 20),
                        label: const Text("Practice Objective (MCQ)"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () => setState(() { _selectedMode = 'objective'; _modeSelected = true; }),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                    const SizedBox(height: 16),
                     SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_document, size: 20),
                        label: const Text("Practice Theory (AI Validated)"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: accent,
                          side: BorderSide(color: accent.withValues(alpha: 0.5), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => setState(() { _selectedMode = 'theory'; _modeSelected = true; }),
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error State ──
  Widget _buildErrorState(AppColorScheme c, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: c.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load quiz',
              style: AppTextStyles.h3.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              err.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.invalidate(pqQuizProvider(widget.question.id)),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState(AppColorScheme c, Color accent) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(c, accent, null),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_rounded, color: accent.withValues(alpha: 0.4), size: 64),
                    const SizedBox(height: 20),
                    Text(
                      'No Quiz Available Yet',
                      style: AppTextStyles.h3.copyWith(color: c.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The AI is still processing this past question.\nPlease check back shortly.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──
  Widget _buildAppBar(AppColorScheme c, Color accent, List<QuizQuestion>? questions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.surface,
                shape: BoxShape.circle,
                border: Border.all(color: c.surfaceHighlight.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.arrow_back_rounded, color: c.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.question.courseCode,
                  style: TextStyle(
                    fontFamily: AppTextStyles.hostGrotesk,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                Text(
                  'Quiz • ${widget.question.displayYear}',
                  style: AppTextStyles.bodySmall.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          if (questions != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentPage + 1}/${questions.length}',
                style: TextStyle(
                  fontFamily: AppTextStyles.hostGrotesk,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Main Quiz Body ──
  Widget _buildQuizBody(
    AppColorScheme c,
    Color accent,
    bool isDark,
    List<QuizQuestion> questions,
    String userName,
  ) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(c, accent, questions),
          const SizedBox(height: 4),

          // ── AI Disclaimer Banner ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: c.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: c.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These questions are dynamically extracted from the actual exam paper.',
                      style: AppTextStyles.bodySmall.copyWith(color: c.info),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Progress Bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / questions.length,
                backgroundColor: c.surfaceHighlight,
                valueColor: AlwaysStoppedAnimation(accent),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Question Pages ──
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return _QuestionCard(
                  questionIndex: index,
                  question: questions[index],
                  selectedOption: _selectedAnswers[index],
                  theoryAnswer: _theoryAnswers[index],
                  theoryScore: _theoryScores[index],
                  theoryAIFeedback: _theoryAIFeedbacks[index],
                  isAnswered: _answeredQuestions[index] == true,
                  onSelectOption: (optionIdx) => _selectOption(index, optionIdx),
                  onTheoryChanged: (val) {
                    setState(() {
                      _theoryAnswers[index] = val;
                    });
                  },
                  onConfirm: () => _confirmAnswer(index, questions, userName),
                  onNext: () => _nextQuestion(questions.length),
                  accent: accent,
                  isDark: isDark,
                  isGrading: _isGradingTheory[index] == true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Results Screen ──
  Widget _buildResultsScreen(
    AppColorScheme c,
    Color accent,
    bool isDark,
    List<QuizQuestion> questions,
  ) {
    final total = questions.length;
    final percentage = ((_correctCount / total) * 100).round();
    final grade = percentage >= 70
        ? 'Excellent!'
        : percentage >= 50
            ? 'Good Job!'
            : 'Keep Studying!';
    final gradeIcon = percentage >= 70
        ? Icons.emoji_events_rounded
        : percentage >= 50
            ? Icons.thumb_up_alt_rounded
            : Icons.menu_book_rounded;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(gradeIcon, color: accent, size: 56),
              )
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 28),
              Text(
                grade,
                style: TextStyle(
                  fontFamily: AppTextStyles.hostGrotesk,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: c.textPrimary,
                ),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 12),
              Text(
                'You scored',
                style: AppTextStyles.bodyLarge.copyWith(color: c.textSecondary),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$_correctCount',
                      style: TextStyle(
                        fontFamily: AppTextStyles.hostGrotesk,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                    TextSpan(
                      text: ' / $total',
                      style: TextStyle(
                        fontFamily: AppTextStyles.hostGrotesk,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontFamily: AppTextStyles.hostGrotesk,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textHint,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.textSecondary,
                        side: BorderSide(color: c.surfaceHighlight),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentPage = 0;
                          _selectedAnswers.clear();
                          _theoryAnswers.clear();
                          _theoryScores.clear();
                          _answeredQuestions.clear();
                          _correctCount = 0;
                          _currentWinStreak = 0;
                          _currentFailStreak = 0;
                          _quizFinished = false;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_pageController.hasClients) {
                             _pageController.jumpToPage(0);
                          }
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ── Question Card (Stateless, receives callbacks) ──
// ══════════════════════════════════════════════════════════════════════════════

class _QuestionCard extends StatelessWidget {
  final int questionIndex;
  final QuizQuestion question;
  final int? selectedOption;
  final String? theoryAnswer;
  final double? theoryScore;
  final String? theoryAIFeedback;
  final bool isAnswered;
  final ValueChanged<int> onSelectOption;
  final ValueChanged<String> onTheoryChanged;
  final VoidCallback onConfirm;
  final VoidCallback onNext;
  final Color accent;
  final bool isDark;
  final bool isGrading;

  const _QuestionCard({
    required this.questionIndex,
    required this.question,
    required this.selectedOption,
    this.theoryAnswer,
    this.theoryScore,
    this.theoryAIFeedback,
    required this.isAnswered,
    required this.onSelectOption,
    required this.onTheoryChanged,
    required this.onConfirm,
    required this.onNext,
    required this.accent,
    required this.isDark,
    this.isGrading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final optionLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Difficulty Badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _difficultyColor(question.difficulty).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              question.difficulty.toUpperCase(),
              style: TextStyle(
                fontFamily: AppTextStyles.urbanist,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _difficultyColor(question.difficulty),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Question Text ──
          Text(
            question.questionText,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: c.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // ── Options or Theory Field ──
          if (question.questionType == 'theory') ...[
            if (isAnswered) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (theoryScore ?? 0) >= 50 ? c.success.withValues(alpha: 0.1) : c.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (theoryScore ?? 0) >= 50 ? c.success.withValues(alpha: 0.5) : c.error.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon((theoryScore ?? 0) >= 50 ? Icons.check_circle_outline_rounded : Icons.cancel_outlined, color: (theoryScore ?? 0) >= 50 ? c.success : c.error),
                        const SizedBox(width: 8),
                        Text("${(theoryScore ?? 0).toStringAsFixed(0)}% AI Score", style: AppTextStyles.h3.copyWith(color: (theoryScore ?? 0) >= 50 ? c.success : c.error)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(theoryAnswer ?? "", style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary, height: 1.5)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Divider(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.workspace_premium_rounded, size: 16, color: accent),
                        const SizedBox(width: 6),
                        Text("Lecturer's Feedback", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800, color: accent, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(theoryAIFeedback ?? question.correctAnswer, style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary, height: 1.6)),
                    const SizedBox(height: 16),
                    // Expandable ideal answer
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        collapsedIconColor: c.textSecondary,
                        iconColor: accent,
                        title: Text(
                          "View Recommended Ideal Format", 
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: c.textSecondary, 
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "For maximum marks in exams, structure your answer similar to this ideal format approach.", 
                            style: AppTextStyles.bodySmall.copyWith(
                              color: c.textHint,
                              height: 1.3,
                            )
                          ),
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: c.surfaceHighlight),
                            ),
                            child: Text(question.correctAnswer, style: AppTextStyles.bodySmall.copyWith(color: c.textSecondary, height: 1.5)),
                          )
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              )
            ] else ...[
              TextField(
                onChanged: onTheoryChanged,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: "Type your exhaustive answer here...",
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: c.textHint),
                  filled: true,
                  fillColor: c.surface,
                  contentPadding: const EdgeInsets.all(20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.surfaceHighlight)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.surfaceHighlight)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accent, width: 2)),
                ),
                style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary, height: 1.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: c.textSecondary, size: 14),
                  const SizedBox(width: 6),
                  Text("Your answer will be securely graded in real-time by Acadex AI.", style: AppTextStyles.bodySmall.copyWith(color: c.textSecondary))
                ]
              )
            ]
          ] else ...[
          // ── Options ──
          ...List.generate(question.options.length, (index) {
            final isSelected = selectedOption == index;
            final optionText = question.options[index];
            
            bool isCorrect = false;
            if (question.correctAnswer.length == 1) {
              isCorrect = (String.fromCharCode(65 + index) == question.correctAnswer.toUpperCase());
            } else {
              isCorrect = (optionText.trim() == question.correctAnswer.trim());
            }

            Color bgColor;
            Color borderColor;
            Color textColor;

            if (isAnswered) {
              if (isCorrect) {
                bgColor = c.success.withValues(alpha: 0.12);
                borderColor = c.success;
                textColor = c.success;
              } else if (isSelected && !isCorrect) {
                bgColor = c.error.withValues(alpha: 0.12);
                borderColor = c.error;
                textColor = c.error;
              } else {
                bgColor = c.surface;
                borderColor = c.surfaceHighlight.withValues(alpha: 0.3);
                textColor = c.textSecondary;
              }
            } else {
              if (isSelected) {
                bgColor = accent.withValues(alpha: 0.1);
                borderColor = accent;
                textColor = accent;
              } else {
                bgColor = c.surface;
                borderColor = c.surfaceHighlight.withValues(alpha: 0.3);
                textColor = c.textPrimary;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onSelectOption(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      // Label circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected || (isAnswered && isCorrect)
                              ? (isAnswered
                                  ? (isCorrect ? c.success : c.error)
                                  : accent)
                              : c.surfaceHighlight.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isAnswered && isSelected
                              ? Icon(
                                  isCorrect
                                      ? Icons.check_rounded
                                      : Icons.close_rounded,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : Text(
                                  index < optionLabels.length
                                      ? optionLabels[index]
                                      : '${index + 1}',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.hostGrotesk,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: isSelected && !isAnswered
                                        ? Colors.white
                                        : c.textSecondary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          optionText,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: textColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          ],

          // ── Explanation (shown after answering) ──
          if (isAnswered && question.explanation != null && question.explanation!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.info.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded,
                          color: c.info, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Explanation',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.explanation!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          // ── Confirm / Next Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isGrading
                  ? null
                  : (isAnswered
                      ? onNext
                      : ((question.questionType == 'objective' ? selectedOption != null : (theoryAnswer != null && theoryAnswer!.trim().isNotEmpty)) ? onConfirm : null)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: isDark ? Colors.black : Colors.white,
                disabledBackgroundColor: accent.withValues(alpha: 0.3),
                disabledForegroundColor: (isDark ? Colors.black : Colors.white)
                    .withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: isGrading
                  ? SizedBox(
                      height: 30, // Keeps the button height consistent without layout shift
                      child: Lottie.asset(
                        'assets/lottie/allLoad.json',
                        fit: BoxFit.contain,
                      ),
                    )
                  : Text(
                      isAnswered ? 'Next Question' : 'Submit Answer',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF00D26A);
      case 'hard':
        return const Color(0xFFFF4C4C);
      default:
        return const Color(0xFFFFB74D);
    }
  }
}
