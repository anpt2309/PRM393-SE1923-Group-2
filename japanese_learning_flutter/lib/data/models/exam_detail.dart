class ExamDetail {
  final int examId;
  final String title;
  final String difficulty;
  final String type;
  final String level;
  final String description;
  final double start;
  final String userCount;
  final List<ExamPart> parts;

  const ExamDetail({
    required this.examId,
    required this.title,
    required this.difficulty,
    required this.type,
    required this.level,
    required this.description,
    required this.start,
    required this.userCount,
    required this.parts,
  });

  factory ExamDetail.fromJson(Map<String, dynamic> json) {
    final partsList = json['part'] as List?;
    final mappedParts = partsList != null
        ? partsList.map((item) => ExamPart.fromJson(item as Map<String, dynamic>)).toList()
        : <ExamPart>[];

    return ExamDetail(
      examId: json['examId'] is num ? (json['examId'] as num).toInt() : 0,
      title: json['title']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      start: json['start'] is num ? (json['start'] as num).toDouble() : 0.0,
      userCount: json['userCount']?.toString() ?? '0',
      parts: mappedParts,
    );
  }
}

class ExamPart {
  final String partName;
  final String partDuration;

  const ExamPart({
    required this.partName,
    required this.partDuration,
  });

  factory ExamPart.fromJson(Map<String, dynamic> json) {
    return ExamPart(
      partName: json['partName']?.toString() ?? '',
      partDuration: json['partDuration']?.toString() ?? '',
    );
  }
}
