class Exam {
  final int id;
  final String title;
  final String description;
  final String examType;
  final int totalDuration;
  final String price;
  final String difficulty;
  final double start;
  final String userCount;

  const Exam({
    required this.id,
    required this.title,
    required this.description,
    required this.examType,
    required this.totalDuration,
    required this.price,
    required this.difficulty,
    required this.start,
    required this.userCount,
  });

  bool get isFree {
    final lowerPrice = price.toLowerCase().trim();
    return lowerPrice == '0' || lowerPrice == '0.0' || lowerPrice == 'miễn phí' || lowerPrice.isEmpty;
  }

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      examType: json['examType']?.toString() ?? '',
      totalDuration: json['totalDuration'] is num ? (json['totalDuration'] as num).toInt() : 0,
      price: json['price']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '',
      start: json['start'] is num ? (json['start'] as num).toDouble() : 0.0,
      userCount: json['userCount']?.toString() ?? '0',
    );
  }
}
