class ReviewQuestion {
  final int number;
  final int questionId;
  final String title;
  final String questionText;
  final List<String> options;
  final int userSelectedIndex;
  final int correctIndex;
  final String explanation;
  final List<Map<String, String>> comments;

  ReviewQuestion({
    required this.number,
    required this.questionId,
    required this.title,
    required this.questionText,
    required this.options,
    required this.userSelectedIndex,
    required this.correctIndex,
    required this.explanation,
    required this.comments,
  });

  bool get isCorrect => userSelectedIndex == correctIndex;
}

class ExamHistoryDetail {
  final int idAttempt;
  final String examName;
  final String examLevel;
  final String startTime;
  final double totalScore;
  final String totalTime;
  final String totalCorrectAnswer;
  final List<ReviewQuestion> questions;

  ExamHistoryDetail({
    required this.idAttempt,
    required this.examName,
    required this.examLevel,
    required this.startTime,
    required this.totalScore,
    required this.totalTime,
    required this.totalCorrectAnswer,
    required this.questions,
  });

  factory ExamHistoryDetail.fromJson(Map<String, dynamic> json) {
    final idAttempt = json['idAttempt'] is num ? (json['idAttempt'] as num).toInt() : 0;
    final examName = json['examName']?.toString() ?? 'Bài thi';
    final examLevel = json['examLevel']?.toString() ?? '';
    final startTime = json['startTime']?.toString() ?? '';
    final totalScore = (json['totalScore'] as num?)?.toDouble() ?? 0.0;
    final totalTime = json['totalTime']?.toString() ?? '00:00';
    final totalCorrectAnswer = json['totalCorrectAnswer']?.toString() ?? '0/0';

    final questionList = json['question'] as List? ?? [];
    final List<ReviewQuestion> questions = [];
    final prefixLetters = ['A', 'B', 'C', 'D', 'E', 'F'];
    final Set<dynamic> seenQuestionIds = {};

    int displayIndex = 1;
    for (int idx = 0; idx < questionList.length; idx++) {
      final qJson = questionList[idx];
      final questionText = qJson['questionContent']?.toString() ?? '';
      
      final questionIdVal = qJson['questionId'] ?? qJson['id'] ?? questionText;
      if (seenQuestionIds.contains(questionIdVal) || questionText.isEmpty) {
        continue;
      }
      seenQuestionIds.add(questionIdVal);

      final int qId = qJson['questionId'] is num 
          ? (qJson['questionId'] as num).toInt() 
          : (qJson['id'] is num ? (qJson['id'] as num).toInt() : 0);

      final number = displayIndex++;

      String sectionTitle = 'Phần luyện tập';
      if (number <= 10) {
        sectionTitle = 'Phần 1: Từ vựng (Vocabulary)';
      } else if (number <= 20) {
        sectionTitle = 'Phần 2: Ngữ pháp & Đọc hiểu';
      } else {
        sectionTitle = 'Phần 3: Nghe hiểu (Listening)';
      }
      final explanation = qJson['explanation']?.toString() ?? '';

      final optionList = qJson['option'] as List? ?? [];
      final List<String> options = [];
      int userSelectedIndex = -1;
      int correctIndex = -1;

      for (int i = 0; i < optionList.length; i++) {
        final opt = optionList[i];
        final content = opt['content']?.toString() ?? '';
        final optionId = opt['optionId'] as int?;
        final isCorrect = opt['isCorrect'] as bool? ?? false;

        final prefix = i < prefixLetters.length ? '${prefixLetters[i]}. ' : '';
        options.add('$prefix$content');

        if (isCorrect) {
          correctIndex = i;
        }
        if (optionId != null && optionId == qJson['selectedOptionId']) {
          userSelectedIndex = i;
        }
      }

      // Default comments since comments are not in the backend response
      final comments = [
        {'user': 'Linh Trần', 'content': 'Câu này lúc thi em phân vân giữa A và B, may mà chọn đúng.'},
        {'user': 'Minh Nhật', 'content': 'Nhờ phần giải thích rõ ràng này mới vỡ lẽ ra cách dùng trợ từ.'},
      ];

      questions.add(ReviewQuestion(
        number: number,
        questionId: qId,
        title: sectionTitle,
        questionText: questionText,
        options: options,
        userSelectedIndex: userSelectedIndex,
        correctIndex: correctIndex,
        explanation: explanation,
        comments: comments,
      ));
    }

    return ExamHistoryDetail(
      idAttempt: idAttempt,
      examName: examName,
      examLevel: examLevel,
      startTime: startTime,
      totalScore: totalScore,
      totalTime: totalTime,
      totalCorrectAnswer: totalCorrectAnswer,
      questions: questions,
    );
  }
}
