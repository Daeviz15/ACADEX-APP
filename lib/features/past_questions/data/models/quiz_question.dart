/// Model representing a single quiz question extracted by AI.
///
/// Mirrors the backend `QuizQuestionOut` Pydantic schema.
class QuizQuestion {
  final String id;
  final String? pastQuestionId;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final String difficulty;
  final String questionType;

  const QuizQuestion({
    required this.id,
    this.pastQuestionId,
    required this.questionText,
    this.options = const [],
    required this.correctAnswer,
    this.explanation,
    this.difficulty = 'medium',
    this.questionType = 'objective',
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      pastQuestionId: json['past_question_id'] as String?,
      questionText: json['question_text'] as String,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      correctAnswer: json['correct_answer'] as String,
      explanation: json['explanation'] as String?,
      difficulty: json['difficulty'] as String? ?? 'medium',
      questionType: json['question_type'] as String? ?? 'objective',
    );
  }
}
