class FlashcardQuizQuestion {
  final int questionId;
  final String question;
  final String? correctAnswer; 

  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;

  const FlashcardQuizQuestion({
    required this.questionId,
    required this.question,
    this.correctAnswer,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
  });

  factory FlashcardQuizQuestion.fromJson(Map<String, dynamic> json) {
    String qText = json["question"] ?? json["front"] ?? "";
    
    // Nhận diện linh hoạt nhiều tên biến từ server
    String? cAns = json["correctAnswer"] ?? 
                   json["answer"] ?? 
                   json["correct_answer"] ?? 
                   json["correct_option"];

    return FlashcardQuizQuestion(
      questionId: json["questionId"] ?? json["id"] ?? 0,
      question: qText,
      correctAnswer: cAns,
      optionA: json["optionA"] ?? "",
      optionB: json["optionB"] ?? "",
      optionC: json["optionC"] ?? "",
      optionD: json["optionD"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "questionId": questionId,
      "question": question,
      "correctAnswer": correctAnswer,
      "optionA": optionA,
      "optionB": optionB,
      "optionC": optionC,
      "optionD": optionD,
    };
  }
}
