class Exam {
  final String id;
  final String title;
  final String description;
  final String type; // "JLPT", "Kanji", "Ngữ pháp", "Từ vựng"
  final String jlptLevel; // "N5", "N4", "N3", "N2", "N1"
  final String difficulty; // "Dễ", "Trung bình", "Khó"
  final double price; // 0.0 means Free
  final int durationMinutes;
  final int questionsCount;
  final int enrolledCount;
  final double rating;

  const Exam({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.jlptLevel,
    required this.difficulty,
    required this.price,
    required this.durationMinutes,
    required this.questionsCount,
    required this.enrolledCount,
    required this.rating,
  });

  bool get isFree => price == 0.0;

  factory Exam.fromJson(Map<String, dynamic> json) {
    // Backend price is formatted string like "99,000" or "0"
    final String rawPrice = json['price']?.toString() ?? '0';
    final double parsedPrice =
        double.tryParse(rawPrice.replaceAll(RegExp(r'[^\d]'), '')) ?? 0.0;

    final String rawTitle = json['title']?.toString() ?? '';
    String detectedLevel = json['level']?.toString() ?? '';
    if (detectedLevel.isEmpty || detectedLevel == 'null') {
      detectedLevel = 'N3';
      for (final level in ['N5', 'N4', 'N3', 'N2', 'N1']) {
        if (rawTitle.toUpperCase().contains(level)) {
          detectedLevel = level;
          break;
        }
      }
    }

    return Exam(
      id: json['id']?.toString() ?? '',
      title: rawTitle,
      description:
          json['description']?.toString() ?? 'Đề thi trắc nghiệm tiếng Nhật tổng hợp.',
      type: json['examType']?.toString() ?? 'JLPT',
      jlptLevel: detectedLevel,
      difficulty: json['difficulty']?.toString() ?? 'Trung bình',
      price: parsedPrice,
      durationMinutes:
          json['totalDuration'] is num ? (json['totalDuration'] as num).toInt() : 60,
      questionsCount:
          json['questionsCount'] is num ? (json['questionsCount'] as num).toInt() : 50,
      enrolledCount:
          json['enrolledCount'] is num ? (json['enrolledCount'] as num).toInt() : 120,
      rating: json['rating'] is num ? (json['rating'] as num).toDouble() : 4.8,
    );
  }
}
