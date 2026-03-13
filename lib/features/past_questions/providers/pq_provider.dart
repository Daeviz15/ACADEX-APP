import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/past_question.dart';
import '../data/mock_past_questions.dart';

// ── Individual Filter Providers ──

/// Currently selected academic year, null = "All Years".
final pqYearFilterProvider = StateProvider<String?>((ref) => null);

/// Currently selected department, null = "All Departments".
final pqDeptFilterProvider = StateProvider<String?>((ref) => null);

/// Currently selected level, null = "All Levels".
final pqLevelFilterProvider = StateProvider<int?>((ref) => null);

/// Currently selected semester, null = "All Semesters".
final pqSemesterFilterProvider = StateProvider<String?>((ref) => null);

/// Free-text search query.
final pqSearchQueryProvider = StateProvider<String>((ref) => '');

// ── Computed Filtered Results ──

/// Applies all active filters and search query to the mock data list.
final filteredPastQuestionsProvider = Provider<List<PastQuestion>>((ref) {
  final year = ref.watch(pqYearFilterProvider);
  final dept = ref.watch(pqDeptFilterProvider);
  final level = ref.watch(pqLevelFilterProvider);
  final semester = ref.watch(pqSemesterFilterProvider);
  final query = ref.watch(pqSearchQueryProvider).toLowerCase().trim();

  return mockPastQuestions.where((pq) {
    if (year != null && pq.year != year) return false;
    if (dept != null && pq.department != dept) return false;
    if (level != null && pq.level != level) return false;
    if (semester != null && pq.semester != semester) return false;
    if (query.isNotEmpty) {
      final matchesCode = pq.courseCode.toLowerCase().contains(query);
      final matchesTitle = pq.courseTitle.toLowerCase().contains(query);
      if (!matchesCode && !matchesTitle) return false;
    }
    return true;
  }).toList();
});

/// Returns true when at least one filter is active.
final pqHasActiveFiltersProvider = Provider<bool>((ref) {
  return ref.watch(pqYearFilterProvider) != null ||
      ref.watch(pqDeptFilterProvider) != null ||
      ref.watch(pqLevelFilterProvider) != null ||
      ref.watch(pqSemesterFilterProvider) != null ||
      ref.watch(pqSearchQueryProvider).isNotEmpty;
});
