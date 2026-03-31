import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/quiz_question.dart';
import '../data/mock_quizzes.dart';
import '../../dashboard/repositories/dashboard_repository.dart';
import '../../dashboard/providers/dashboard_provider.dart';

// ── Mode & Filter Providers ──

/// Currently selected quiz mode.
final quizModeProvider = StateProvider<QuizMode?>((ref) => null);

/// Topic filter for Study Mode.
final quizTopicFilterProvider = StateProvider<String?>((ref) => null);

/// Mock streak counter (persisted later).
final quizStreakProvider = StateProvider<int>((ref) => 5);

// ── Stats Provider ──

/// Mock stats for the lobby display.
final quizStatsProvider = Provider<QuizStats>((ref) {
  return const QuizStats(
    totalQuizzes: 24,
    winRate: 78,
    bestStreak: 12,
  );
});

@immutable
class QuizStats {
  final int totalQuizzes;
  final int winRate;
  final int bestStreak;

  const QuizStats({
    required this.totalQuizzes,
    required this.winRate,
    required this.bestStreak,
  });
}

// ── Active Quiz Session ──

/// State for an ongoing quiz session.
@immutable
class QuizSessionState {
  final QuizMode mode;
  final List<QuizQuestion> questions;
  final int currentIndex;
  final int? selectedOption;
  final bool hasAnswered;
  final int score;
  final List<int?> answers; // user's answers per question (null = unanswered)
  final int timeRemaining; // seconds, only used in Cash mode

  const QuizSessionState({
    required this.mode,
    required this.questions,
    this.currentIndex = 0,
    this.selectedOption,
    this.hasAnswered = false,
    this.score = 0,
    this.answers = const [],
    this.timeRemaining = 15,
  });

  QuizQuestion get currentQuestion => questions[currentIndex];
  bool get isLastQuestion => currentIndex >= questions.length - 1;
  int get totalQuestions => questions.length;
  double get progress => (currentIndex + 1) / totalQuestions;
  bool get isComplete => currentIndex >= totalQuestions;
  int get correctAnswers => answers.asMap().entries.where((e) {
        return e.value == questions[e.key].correctIndex;
      }).length;

  QuizSessionState copyWith({
    QuizMode? mode,
    List<QuizQuestion>? questions,
    int? currentIndex,
    int? selectedOption,
    bool? hasAnswered,
    int? score,
    List<int?>? answers,
    int? timeRemaining,
    bool clearSelection = false,
  }) {
    return QuizSessionState(
      mode: mode ?? this.mode,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOption:
          clearSelection ? null : (selectedOption ?? this.selectedOption),
      hasAnswered: hasAnswered ?? this.hasAnswered,
      score: score ?? this.score,
      answers: answers ?? this.answers,
      timeRemaining: timeRemaining ?? this.timeRemaining,
    );
  }
}

/// Manages the active quiz session state.
class ActiveQuizNotifier extends StateNotifier<QuizSessionState?> {
  final Ref ref;
  ActiveQuizNotifier(this.ref) : super(null);

  /// Start a new quiz session with the given mode and questions.
  void startQuiz(QuizMode mode, List<QuizQuestion> questions) {
    final shuffled = List<QuizQuestion>.from(questions)..shuffle();
    final selected = shuffled.take(mode == QuizMode.cashChallenge ? 10 : 10).toList();

    state = QuizSessionState(
      mode: mode,
      questions: selected,
      answers: List.filled(selected.length, null),
      timeRemaining: mode == QuizMode.cashChallenge ? 15 : 0,
    );
  }

  /// Select an answer option.
  void selectOption(int optionIndex) {
    if (state == null || state!.hasAnswered) return;

    final isCorrect = optionIndex == state!.currentQuestion.correctIndex;
    final updatedAnswers = List<int?>.from(state!.answers);
    updatedAnswers[state!.currentIndex] = optionIndex;

    state = state!.copyWith(
      selectedOption: optionIndex,
      hasAnswered: true,
      score: isCorrect ? state!.score + 1 : state!.score,
      answers: updatedAnswers,
    );
  }

  /// Move to the next question.
  void nextQuestion() {
    if (state == null) return;
    if (state!.isLastQuestion) return;

    state = state!.copyWith(
      currentIndex: state!.currentIndex + 1,
      hasAnswered: false,
      clearSelection: true,
      timeRemaining: state!.mode == QuizMode.cashChallenge ? 15 : 0,
    );
  }

  /// Update countdown timer (Cash mode).
  void tickTimer() {
    if (state == null || state!.timeRemaining <= 0) return;
    state = state!.copyWith(timeRemaining: state!.timeRemaining - 1);

    // Auto-submit when time runs out
    if (state!.timeRemaining <= 0 && !state!.hasAnswered) {
      final updatedAnswers = List<int?>.from(state!.answers);
      updatedAnswers[state!.currentIndex] = -1; // mark as timed-out
      state = state!.copyWith(
        hasAnswered: true,
        answers: updatedAnswers,
      );
    }
  }

  /// End the quiz session.
  void endQuiz() {
    if (state != null) {
      final title = state!.mode == QuizMode.cashChallenge ? 'Cash Challenge Quiz: ${state!.currentQuestion.topic}' : 'Study Quiz: ${state!.currentQuestion.topic}';
      
      // Calculate true progress
      // If they finished the quiz entirely, we can show their score.
      // If they left early, we show "In Progress".
      final isFinished = state!.currentIndex == state!.totalQuestions - 1 && state!.hasAnswered;
      final status = isFinished ? 'Score: ${state!.score}/${state!.totalQuestions}' : 'Left Early';
      double progressVal = (state!.currentIndex + (state!.hasAnswered ? 1 : 0)) / state!.totalQuestions;
      
      // Ensure we don't go over 1.0
      progressVal = progressVal.clamp(0.0, 1.0);

      // Fire and forget logging
      ref.read(dashboardRepositoryProvider).logActivity(
        type: 'quiz',
        title: title,
        statusText: status,
        progress: progressVal,
      ).then((_) {
        // Refresh the Dashboard so the new activity appears immediately!
        ref.read(dashboardSummaryProvider.notifier).refresh();
      });
    }
    state = null;
  }
}

final activeQuizProvider =
    StateNotifierProvider<ActiveQuizNotifier, QuizSessionState?>((ref) {
  return ActiveQuizNotifier(ref);
});

/// Get questions filtered by topic.
final quizQuestionsForTopicProvider = Provider.family<List<QuizQuestion>, String?>((ref, topic) {
  if (topic == null) return mockQuizQuestions;
  return mockQuizQuestions.where((q) => q.topic == topic).toList();
});
