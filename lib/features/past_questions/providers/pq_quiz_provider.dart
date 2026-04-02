import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/quiz_question.dart';
import '../data/pq_repository.dart';

/// Fetches quiz questions for a given past question ID.
/// Uses `.family` so each PQ gets its own isolated cache.
final pqQuizProvider =
    FutureProvider.autoDispose.family<List<QuizQuestion>, String>(
  (ref, pastQuestionId) async {
    final repo = ref.watch(pqRepositoryProvider);
    return repo.fetchQuiz(pastQuestionId);
  },
);
