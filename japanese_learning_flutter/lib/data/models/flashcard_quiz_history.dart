class FlashcardQuizHistory {
  final int historyId;
  final int? setId;
  final String setName;
  final int totalQuestions;
  final int correctAnswer;
  final int score;
  final DateTime? createdAt;
  final int? timeSpent;
  final List<Map<String, dynamic>>? answers;

  const FlashcardQuizHistory({
    required this.historyId,
    this.setId,
    required this.setName,
    required this.totalQuestions,
    required this.correctAnswer,
    required this.score,
    this.createdAt,
    this.timeSpent,
    this.answers,
  });

  // Hàm helper để chuyển đổi dynamic sang int an toàn
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory FlashcardQuizHistory.fromJson(Map<String, dynamic> json) {
    // Tìm setId linh hoạt và ép kiểu an toàn
    int? sId = _parseInt(json["setId"]) ?? 
               _parseInt(json["flashcardSetId"]) ?? 
               (json["flashcardSet"] != null ? _parseInt(json["flashcardSet"]["id"]) : null);

    String sName = json["setName"] ?? 
                  json["flashcardSetName"] ?? 
                  (json["flashcardSet"] != null ? json["flashcardSet"]["name"] : null) ?? 
                  "Bộ thẻ không tên";

    return FlashcardQuizHistory(
      historyId: _parseInt(json["historyId"]) ?? _parseInt(json["id"]) ?? 0,
      setId: sId,
      setName: sName,
      totalQuestions: _parseInt(json["totalQuestion"]) ?? _parseInt(json["totalQuestions"]) ?? _parseInt(json["total_question"]) ?? 0,
      correctAnswer: _parseInt(json["correctAnswer"]) ?? _parseInt(json["correct_answer"]) ?? _parseInt(json["correctCount"]) ?? 0,
      score: _parseInt(json["score"]) ?? 0,
      createdAt: json["completedAt"] != null 
          ? DateTime.parse(json["completedAt"].toString())
          : (json["createdAt"] != null 
              ? DateTime.parse(json["createdAt"].toString()) 
              : (json["timestamp"] != null ? DateTime.parse(json["timestamp"].toString()) : null)),
      timeSpent: _parseInt(json["timeSpent"]) ?? _parseInt(json["time_spent"]),
      answers: json["answers"] != null ? List<Map<String, dynamic>>.from(json["answers"]) : null,
    );
  }

  double get percentage {
    if (totalQuestions == 0) return 0;
    return (correctAnswer / totalQuestions) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      "historyId": historyId,
      "setId": setId,
      "setName": setName,
      "totalQuestion": totalQuestions,
      "correctAnswer": correctAnswer,
      "score": score,
      "completedAt": createdAt?.toIso8601String(),
      "timeSpent": timeSpent,
      "answers": answers,
    };
  }
}
