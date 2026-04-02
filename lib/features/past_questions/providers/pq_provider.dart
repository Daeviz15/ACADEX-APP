import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/past_question.dart';
import '../data/pq_repository.dart';

// ── Individual Filter Providers ──

/// Currently selected academic year, null = "All Years".
final pqYearFilterProvider = StateProvider<String?>((ref) => null);

/// Currently selected department, null = "All Departments".
final pqDeptFilterProvider = StateProvider<String?>((ref) => null);

/// Currently selected level, null = "All Levels".
final pqLevelFilterProvider = StateProvider<int?>((ref) => null);

/// Currently selected semester, null = "All Semesters".
final pqSemesterFilterProvider = StateProvider<String?>((ref) => null);

/// Free-text search query (updates immediately as user types).
final pqSearchQueryProvider = StateProvider<String>((ref) => '');

/// Debounced search query (updates after a delay to prevent API spam).
final debouncedPqSearchQueryProvider = StateProvider<String>((ref) => '');

// ── API Data Providers ──

/// Fetches dynamic filter options (distinct departments, years, etc.) from the DB.
final pqFilterOptionsProvider = FutureProvider.autoDispose<PqFilterOptions>((ref) async {
  final repo = ref.watch(pqRepositoryProvider);
  return repo.fetchFilters();
});

/// Applies all active filters and search query to fetch data from the server.
final pastQuestionsProvider = FutureProvider.autoDispose<List<PastQuestion>>((ref) async {
  final year = ref.watch(pqYearFilterProvider);
  final dept = ref.watch(pqDeptFilterProvider);
  final level = ref.watch(pqLevelFilterProvider);
  final semester = ref.watch(pqSemesterFilterProvider);
  final query = ref.watch(debouncedPqSearchQueryProvider);

  // Brief latency allowance: if multiple filters change at exactly the same time 
  // (e.g., clicking "Clear Filters"), this prevents firing multiple disjointed API calls.
  var isCancelled = false;
  ref.onDispose(() => isCancelled = true);
  await Future.delayed(const Duration(milliseconds: 50));
  if (isCancelled) throw Exception('Cancelled');

  final repo = ref.watch(pqRepositoryProvider);
  return repo.fetchPastQuestions(
    department: dept,
    year: year,
    semester: semester,
    level: level,
    search: query,
  );
});

/// Returns true when at least one filter is active.
final pqHasActiveFiltersProvider = Provider<bool>((ref) {
  return ref.watch(pqYearFilterProvider) != null ||
      ref.watch(pqDeptFilterProvider) != null ||
      ref.watch(pqLevelFilterProvider) != null ||
      ref.watch(pqSemesterFilterProvider) != null ||
      ref.watch(pqSearchQueryProvider).isNotEmpty;
});
