/// Model representing a single past examination question paper.
class PastQuestion {
  final String id;
  final String courseCode;
  final String courseTitle;
  final String year;
  final String semester;
  final String department;
  final int level;

  const PastQuestion({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.year,
    required this.semester,
    required this.department,
    required this.level,
  });
}
