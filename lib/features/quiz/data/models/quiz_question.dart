/// Model representing a single quiz question.
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String courseCode;
  final String topic;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.courseCode,
    required this.topic,
  });
}

/// Enum representing the three quiz modes.
enum QuizMode { examPrep, cashChallenge, study }
