class FlashcardQuizResult {
  final int quizId;

  final int totalQuestion;

  final int correctAnswer;

  final int score;

  const FlashcardQuizResult({
    required this.quizId,
    required this.totalQuestion,
    required this.correctAnswer,
    required this.score,
  });

  factory FlashcardQuizResult.fromJson(
      Map<String, dynamic> json) {
    return FlashcardQuizResult(
      quizId: json["quizId"] ?? 0,
      totalQuestion: json["totalQuestion"] ?? 0,
      correctAnswer: json["correctAnswer"] ?? 0,
      score: json["score"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "quizId": quizId,
      "totalQuestion": totalQuestion,
      "correctAnswer": correctAnswer,
      "score": score,
    };
  }
}