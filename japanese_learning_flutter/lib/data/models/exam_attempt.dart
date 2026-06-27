class ExamQuestion {
  final int number;
  final int questionId;
  final String title;
  final String questionText;
  final List<String> options;
  final List<int> optionIds;
  final String? formulaText;
  final bool isListening;
  final String? audioDuration;

  const ExamQuestion({
    required this.number,
    required this.questionId,
    required this.title,
    required this.questionText,
    required this.options,
    required this.optionIds,
    this.formulaText,
    this.isListening = false,
    this.audioDuration,
  });
}

class ExamPartInfo {
  final String name;
  final int startIndex;
  final int endIndex;

  const ExamPartInfo({
    required this.name,
    required this.startIndex,
    required this.endIndex,
  });
}
