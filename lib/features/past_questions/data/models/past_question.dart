/// Model representing a single past examination question paper.
///
/// Mirrors the backend `PastQuestionOut` Pydantic schema.
/// Uses factory constructor for safe JSON deserialization.
class PastQuestion {
  final String id;
  final String? department;
  final String courseCode;
  final String courseTitle;
  final String year;        // Raw from DB: "2016_2017"
  final String? semester;   // "1st", "2nd", or null
  final int? level;         // 100, 200, 300, 400, 500
  final List<String> fileUrls;
  final int? questionCount;
  final bool hasQuiz;

  const PastQuestion({
    required this.id,
    this.department,
    required this.courseCode,
    required this.courseTitle,
    required this.year,
    this.semester,
    this.level,
    this.fileUrls = const [],
    this.questionCount,
    this.hasQuiz = false,
  });

  /// Deserialize from API JSON response.
  factory PastQuestion.fromJson(Map<String, dynamic> json) {
    return PastQuestion(
      id: json['id'] as String,
      department: json['department'] as String?,
      courseCode: json['course_code'] as String,
      courseTitle: json['course_title'] as String,
      year: json['year'] as String,
      semester: json['semester'] as String?,
      level: json['level'] as int?,
      fileUrls: (json['file_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      questionCount: json['question_count'] as int?,
      hasQuiz: json['has_quiz'] as bool? ?? false,
    );
  }

  /// Formats "2016_2017" → "2016/2017" for display.
  String get displayYear => year.replaceAll('_', '/');

  /// Formats semester for display, e.g. "1st" → "1st Semester".
  String? get displaySemester =>
      semester != null ? '$semester Semester' : null;

  /// Formats level for display, e.g. 200 → "200 Level".
  String? get displayLevel =>
      level != null ? '$level Level' : null;
}
