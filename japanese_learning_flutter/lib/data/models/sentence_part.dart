class SentencePart {
  final String id;
  final String groupId;
  final String title;
  final String description; // Ví dụ: "Học cách sử dụng trợ từ は và が"
  final String icon; // Icon đại diện cho chủ đề

  SentencePart({
    required this.id, 
    required this.groupId, 
    required this.title, 
    this.description = '',
    this.icon = '📚',
  });

  factory SentencePart.fromFirestore(Map<String, dynamic> data, String id) {
    return SentencePart(
      id: id,
      groupId: data['groupId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '📚',
    );
  }
}
