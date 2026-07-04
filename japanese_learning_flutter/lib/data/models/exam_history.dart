class ExamAttemptHistoryItem {
  final int? idAttempt;
  final String title;
  final String level; // N1, N2, N3, N4, N5
  final double score; // out of 180
  final int correctCount;
  final int totalQuestions;
  final String duration;
  final String date;

  ExamAttemptHistoryItem({
    this.idAttempt,
    required this.title,
    required this.level,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.duration,
    required this.date,
  });

  factory ExamAttemptHistoryItem.fromJson(Map<String, dynamic> json) {
    final title = json['examName']?.toString() ?? 'Đề thi';
    final level = json['examLevel']?.toString() ?? 'N3';
    final score = (json['totalScore'] as num?)?.toDouble() ?? 0.0;
    final duration = json['totalTime']?.toString() ?? '00:00';
    
    // Parse correctCount and totalQuestions from totalCorrectAnswer (e.g., "20/30" or just "20")
    final totalCorrect = json['totalCorrectAnswer']?.toString() ?? '0';
    int correctCount = 0;
    int totalQuestions = 30; // Default total questions if not provided or parsing fails
    if (totalCorrect.contains('/')) {
      final parts = totalCorrect.split('/');
      if (parts.length >= 2) {
        correctCount = int.tryParse(parts[0].trim()) ?? 0;
        totalQuestions = int.tryParse(parts[1].trim()) ?? 30;
      }
    } else {
      correctCount = int.tryParse(totalCorrect) ?? 0;
    }

    // Format LocalDateTime date (e.g. "2026-06-27T01:45:05") to "27/06/2026"
    final startTimeStr = json['startTime']?.toString() ?? '';
    String dateStr = '';
    if (startTimeStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(startTimeStr);
        final day = dt.day.toString().padLeft(2, '0');
        final month = dt.month.toString().padLeft(2, '0');
        final year = dt.year.toString();
        dateStr = '$day/$month/$year';
      } catch (_) {
        if (startTimeStr.length >= 10 && startTimeStr.contains('-')) {
          final parts = startTimeStr.substring(0, 10).split('-');
          if (parts.length == 3) {
            dateStr = '${parts[2]}/${parts[1]}/${parts[0]}';
          }
        } else {
          dateStr = startTimeStr;
        }
      }
    }

    return ExamAttemptHistoryItem(
      idAttempt: json['idAttempt'] is num ? (json['idAttempt'] as num).toInt() : null,
      title: title,
      level: level,
      score: score,
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      duration: duration,
      date: dateStr,
    );
  }
}
