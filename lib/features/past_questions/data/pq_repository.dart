import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:acadex/core/network/api_client.dart';
import 'package:acadex/core/network/api_endpoints.dart';
import 'models/past_question.dart';
import 'models/quiz_question.dart';

/// Holds the distinct filter options returned by the /filters endpoint.
class PqFilterOptions {
  final List<String> departments;
  final List<String> years;
  final List<String> semesters;
  final List<int> levels;

  const PqFilterOptions({
    this.departments = const [],
    this.years = const [],
    this.semesters = const [],
    this.levels = const [],
  });

  factory PqFilterOptions.fromJson(Map<String, dynamic> json) {
    return PqFilterOptions(
      departments: (json['departments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      years: (json['years'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      semesters: (json['semesters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      levels: (json['levels'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );
  }
}

/// Repository handling all Past Questions API communication.
class PqRepository {
  final Dio _dio;
  PqRepository(this._dio);

  /// Fetch past questions with optional server-side filters.
  Future<List<PastQuestion>> fetchPastQuestions({
    String? department,
    String? semester,
    String? year,
    int? level,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (department != null) queryParams['department'] = department;
    if (semester != null) queryParams['semester'] = semester;
    if (year != null) queryParams['year'] = year;
    if (level != null) queryParams['level'] = level;
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await _dio.get(
      ApiEndpoints.pastQuestions,
      queryParameters: queryParams,
    );

    return (response.data as List<dynamic>)
        .map((json) => PastQuestion.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch distinct filter options from the database.
  Future<PqFilterOptions> fetchFilters() async {
    final response = await _dio.get(ApiEndpoints.pastQuestionFilters);
    return PqFilterOptions.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetch quiz questions for a specific past question.
  Future<List<QuizQuestion>> fetchQuiz(String pastQuestionId) async {
    final response = await _dio.get(
      ApiEndpoints.pastQuestionQuiz(pastQuestionId),
    );
    return (response.data as List<dynamic>)
        .map((json) => QuizQuestion.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Trigger AI quiz generation for a past question (admin use).
  Future<void> triggerQuizGeneration(String pastQuestionId) async {
    await _dio.post(ApiEndpoints.generateQuiz(pastQuestionId));
  }

  /// Grade a theory answer securely using the AI backend
  Future<Map<String, dynamic>> gradeTheoryAnswer({
    required String questionText,
    required String idealAnswer,
    required String userAnswer,
    required String userName,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.gradeTheory,
      data: {
        'question_text': questionText,
        'ideal_answer': idealAnswer,
        'user_answer': userAnswer,
        'user_name': userName,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}

/// Riverpod provider for the repository.
final pqRepositoryProvider = Provider<PqRepository>((ref) {
  return PqRepository(ref.read(dioProvider));
});
