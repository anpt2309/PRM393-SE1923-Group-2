class VocabularyWord {
  final String word; // e.g. 食べる
  final String kanji; // e.g. 食 (THỰC)
  final String hiragana; // e.g. たべる
  final String romaji; // e.g. taberu
  final String englishMeaning; // e.g. To eat
  final String vietnameseMeaning; // e.g. Ăn
  final List<String> collocations; // e.g. ["朝ご飯を食べる", "早く食べる"]
  final String exampleSentenceJa; // e.g. 毎日、朝ご飯を食べる。
  final String exampleSentenceJaHira; // e.g. まいにち、あさごはん te べる。
  final String exampleSentenceVi; // e.g. Mỗi ngày tôi đều ăn sáng.
  final String exampleSentenceEn; // e.g. I eat breakfast every day.
  final bool isMastered;
  final String wordType; // e.g. Động từ nhóm 2
  final String pitchAccent; // e.g. Trọng âm: [2]

  VocabularyWord({
    required this.word,
    required this.kanji,
    required this.hiragana,
    required this.romaji,
    required this.englishMeaning,
    required this.vietnameseMeaning,
    required this.collocations,
    required this.exampleSentenceJa,
    required this.exampleSentenceJaHira,
    required this.exampleSentenceVi,
    required this.exampleSentenceEn,
    this.isMastered = false,
    required this.wordType,
    required this.pitchAccent,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    // Parse collocations string
    final colStr = json['collocations'] as String? ?? '';
    final colList = colStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return VocabularyWord(
      word: json['word'] as String? ?? '',
      kanji: json['kanji'] as String? ?? '',
      hiragana: json['reading'] as String? ?? '', // reading maps to hiragana
      romaji: json['romaji'] as String? ?? '',
      englishMeaning: json['englishMeaning'] as String? ?? '',
      vietnameseMeaning: json['vietnameseMeaning'] as String? ?? '',
      collocations: colList,
      exampleSentenceJa: json['exampleSentenceJa'] as String? ?? '',
      exampleSentenceJaHira: json['exampleSentenceJaHira'] as String? ?? '',
      exampleSentenceVi: json['exampleSentenceVi'] as String? ?? '',
      exampleSentenceEn: json['exampleSentenceEn'] as String? ?? '',
      isMastered: false, // Local state on Flutter side
      wordType: json['wordType'] as String? ?? '',
      pitchAccent: json['pitchAccent'] as String? ?? '',
    );
  }

  VocabularyWord copyWith({
    String? word,
    String? kanji,
    String? hiragana,
    String? romaji,
    String? englishMeaning,
    String? vietnameseMeaning,
    List<String>? collocations,
    String? exampleSentenceJa,
    String? exampleSentenceJaHira,
    String? exampleSentenceVi,
    String? exampleSentenceEn,
    bool? isMastered,
    String? wordType,
    String? pitchAccent,
  }) {
    return VocabularyWord(
      word: word ?? this.word,
      kanji: kanji ?? this.kanji,
      hiragana: hiragana ?? this.hiragana,
      romaji: romaji ?? this.romaji,
      englishMeaning: englishMeaning ?? this.englishMeaning,
      vietnameseMeaning: vietnameseMeaning ?? this.vietnameseMeaning,
      collocations: collocations ?? this.collocations,
      exampleSentenceJa: exampleSentenceJa ?? this.exampleSentenceJa,
      exampleSentenceJaHira: exampleSentenceJaHira ?? this.exampleSentenceJaHira,
      exampleSentenceVi: exampleSentenceVi ?? this.exampleSentenceVi,
      exampleSentenceEn: exampleSentenceEn ?? this.exampleSentenceEn,
      isMastered: isMastered ?? this.isMastered,
      wordType: wordType ?? this.wordType,
      pitchAccent: pitchAccent ?? this.pitchAccent,
    );
  }
}

class VocabularyLesson {
  final String id;
  final String title;
  final List<VocabularyWord> words;

  VocabularyLesson({
    required this.id,
    required this.title,
    required this.words,
  });

  factory VocabularyLesson.fromJson(Map<String, dynamic> json) {
    return VocabularyLesson(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      words: [],
    );
  }

  VocabularyLesson copyWith({
    String? id,
    String? title,
    List<VocabularyWord>? words,
  }) {
    return VocabularyLesson(
      id: id ?? this.id,
      title: title ?? this.title,
      words: words ?? this.words,
    );
  }
}
