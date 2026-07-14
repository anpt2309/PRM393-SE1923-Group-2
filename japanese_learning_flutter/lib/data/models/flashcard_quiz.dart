import 'flashcard_quiz_question.dart';

class FlashcardQuiz {
  final int quizId;
  final int setId;
  final int totalQuestion;

  final List<FlashcardQuizQuestion> questions;

  const FlashcardQuiz({
    required this.quizId,
    required this.setId,
    required this.totalQuestion,
    required this.questions,
  });

  factory FlashcardQuiz.fromJson(
      Map<String, dynamic> json) {
    return FlashcardQuiz(
      quizId: json["quizId"] ?? 0,
      setId: json["setId"] ?? 0,
      totalQuestion: json["totalQuestion"] ?? 0,
      questions: (json["questions"] as List? ?? [])
          .map((e) => FlashcardQuizQuestion.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "quizId": quizId,
      "setId": setId,
      "totalQuestion": totalQuestion,
      "questions":
      questions.map((e) => e.toJson()).toList(),
    };
  }
}