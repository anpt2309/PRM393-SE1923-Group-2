enum SentenceGroupType { DISCOVERY, CHALLENGE } // Khám phá & Thử thách

class SentenceGroup {
  final String id;
  final SentenceGroupType type;
  final String name;
  final String jlptLevel; // ALL, N5, N4...

  SentenceGroup({
    required this.id,
    required this.type, 
    required this.name,
    this.jlptLevel = 'ALL',
  });

  factory SentenceGroup.fromFirestore(Map<String, dynamic> data, String id) {
    return SentenceGroup(
      id: id,
      type: data['type'] == 'CHALLENGE' ? SentenceGroupType.CHALLENGE : SentenceGroupType.DISCOVERY,
      name: data['name'] ?? '',
      jlptLevel: data['jlptLevel'] ?? 'ALL',
    );
  }
}
