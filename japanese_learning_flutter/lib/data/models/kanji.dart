import 'dart:convert';

class KanjiRadical {
  final String character;
  final String name;
  final String meaning;
  final String story;

  KanjiRadical({
    required this.character,
    required this.name,
    required this.meaning,
    required this.story,
  });

  factory KanjiRadical.fromJson(Map<String, dynamic> json) {
    return KanjiRadical(
      character: json['character'] ?? '',
      name: json['name'] ?? '',
      meaning: json['meaning'] ?? '',
      story: json['story'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'name': name,
      'meaning': meaning,
      'story': story,
    };
  }
}

class KanjiStrokeBadge {
  final double x; // Relative x coordinate (0.0 to 1.0)
  final double y; // Relative y coordinate (0.0 to 1.0)
  final int number;

  KanjiStrokeBadge({
    required this.x,
    required this.y,
    required this.number,
  });

  factory KanjiStrokeBadge.fromJson(Map<String, dynamic> json) {
    return KanjiStrokeBadge(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      number: json['number'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'number': number,
    };
  }
}

class KanjiModel {
  final String kanji;
  final String meaning;
  final String hanViet;
  final String jlptLevel; // 'N5', 'N4', 'N3', 'N2', 'N1'
  final List<KanjiRadical> radicals;
  final String onyomi;
  final List<String> onyomiCompounds;
  final String kunyomi;
  final List<String> kunyomiCompounds;
  final List<KanjiStrokeBadge> strokeBadges;
  final bool isMastered;

  KanjiModel({
    required this.kanji,
    required this.meaning,
    required this.hanViet,
    required this.jlptLevel,
    required this.radicals,
    required this.onyomi,
    required this.onyomiCompounds,
    required this.kunyomi,
    required this.kunyomiCompounds,
    required this.strokeBadges,
    this.isMastered = false,
  });

  factory KanjiModel.fromJson(Map<String, dynamic> json) {
    final onyomiRaw = json['onyomiCompounds'] as String? ?? '';
    final onyomiList = onyomiRaw.isNotEmpty 
        ? onyomiRaw.split(';').map((s) => s.trim()).toList() 
        : <String>[];
        
    final kunyomiRaw = json['kunyomiCompounds'] as String? ?? '';
    final kunyomiList = kunyomiRaw.isNotEmpty 
        ? kunyomiRaw.split(';').map((s) => s.trim()).toList() 
        : <String>[];

    List<KanjiRadical> radList = [];
    final radJsonStr = json['radicalsJson'] as String? ?? '';
    if (radJsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(radJsonStr);
        if (decoded is List) {
          radList = decoded.map((item) => KanjiRadical.fromJson(item)).toList();
        }
      } catch (_) {}
    }

    List<KanjiStrokeBadge> badges = [];
    final badgesJsonStr = json['strokeBadgesJson'] as String? ?? '';
    if (badgesJsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(badgesJsonStr);
        if (decoded is List) {
          badges = decoded.map((item) => KanjiStrokeBadge.fromJson(item)).toList();
        }
      } catch (_) {}
    }

    return KanjiModel(
      kanji: json['kanjiChar'] ?? '',
      meaning: json['meaning'] ?? '',
      hanViet: json['hanViet'] ?? '',
      jlptLevel: json['jlptLevel'] ?? 'N5',
      radicals: radList,
      onyomi: json['onyomi'] ?? '',
      onyomiCompounds: onyomiList,
      kunyomi: json['kunyomi'] ?? '',
      kunyomiCompounds: kunyomiList,
      strokeBadges: badges,
      isMastered: false,
    );
  }

  KanjiModel copyWith({
    String? kanji,
    String? meaning,
    String? hanViet,
    String? jlptLevel,
    List<KanjiRadical>? radicals,
    String? onyomi,
    List<String>? onyomiCompounds,
    String? kunyomi,
    List<String>? kunyomiCompounds,
    List<KanjiStrokeBadge>? strokeBadges,
    bool? isMastered,
  }) {
    return KanjiModel(
      kanji: kanji ?? this.kanji,
      meaning: meaning ?? this.meaning,
      hanViet: hanViet ?? this.hanViet,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      radicals: radicals ?? this.radicals,
      onyomi: onyomi ?? this.onyomi,
      onyomiCompounds: onyomiCompounds ?? this.onyomiCompounds,
      kunyomi: kunyomi ?? this.kunyomi,
      kunyomiCompounds: kunyomiCompounds ?? this.kunyomiCompounds,
      strokeBadges: strokeBadges ?? this.strokeBadges,
      isMastered: isMastered ?? this.isMastered,
    );
  }
}
