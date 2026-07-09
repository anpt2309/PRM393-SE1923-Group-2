class SentenceItem {
  final String id;
  final String partId;
  final String kanji;
  final String hira;
  final String viet;
  final List<String> words;

  final String? explanation; // Giải thích về trợ từ hoặc cấu trúc

  SentenceItem({
    required this.id,
    required this.partId,
    required this.kanji,
    required this.hira,
    required this.viet,
    required this.words,
    this.explanation,
  });

  factory SentenceItem.fromFirestore(Map<String, dynamic> data, String id) {
    return SentenceItem(
      id: id,
      partId: data['partId'] ?? '',
      kanji: data['kanji'] ?? '',
      hira: data['hira'] ?? '',
      viet: data['viet'] ?? '',
      words: List<String>.from(data['words'] ?? []),
      explanation: data['explanation'],
    );
  }
}
