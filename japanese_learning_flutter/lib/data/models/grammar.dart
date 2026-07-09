import 'dart:convert';

class GrammarFormulaBlock {
  final String text;
  final bool isTarget; // If true, highlight it with Cobalt Blue border

  GrammarFormulaBlock({
    required this.text,
    this.isTarget = false,
  });

  factory GrammarFormulaBlock.fromJson(Map<String, dynamic> json) {
    return GrammarFormulaBlock(
      text: json['text'] as String? ?? '',
      isTarget: json['isTarget'] as bool? ?? false,
    );
  }
}

class SentenceToken {
  final String text;
  final String grammaticalRole;
  final bool isTargetPattern; // Highlight in Accent Orange

  SentenceToken({
    required this.text,
    required this.grammaticalRole,
    this.isTargetPattern = false,
  });

  factory SentenceToken.fromJson(Map<String, dynamic> json) {
    return SentenceToken(
      text: json['text'] as String? ?? '',
      grammaticalRole: json['grammaticalRole'] as String? ?? '',
      isTargetPattern: json['isTargetPattern'] as bool? ?? false,
    );
  }
}

class GrammarModel {
  final String id;
  final String pattern; // e.g. "〜てみる"
  final String level; // N5, N4, N3, N2, N1
  final String meaning; // e.g. "Thử làm một việc gì đó"
  final List<GrammarFormulaBlock> formula; // blocks of equation
  final List<SentenceToken> exampleAnatomy; // word tokens and their roles
  final String exampleSentence; // full text for TTS
  final String translation; // Vietnamese translation
  final double formalityNuance; // 0.0 (Casual) to 1.0 (Formal)
  final bool isMastered;

  GrammarModel({
    required this.id,
    required this.pattern,
    required this.level,
    required this.meaning,
    required this.formula,
    required this.exampleAnatomy,
    required this.exampleSentence,
    required this.translation,
    required this.formalityNuance,
    this.isMastered = false,
  });

  GrammarModel copyWith({
    bool? isMastered,
  }) {
    return GrammarModel(
      id: id,
      pattern: pattern,
      level: level,
      meaning: meaning,
      formula: formula,
      exampleAnatomy: exampleAnatomy,
      exampleSentence: exampleSentence,
      translation: translation,
      formalityNuance: formalityNuance,
      isMastered: isMastered ?? this.isMastered,
    );
  }

  factory GrammarModel.fromJson(Map<String, dynamic> json) {
    // Parse formulaJson if it is a JSON string or already parsed List
    List<GrammarFormulaBlock> parsedFormula = [];
    final formulaData = json['formulaJson'];
    if (formulaData != null) {
      try {
        final decoded = formulaData is String ? jsonDecode(formulaData) : formulaData;
        if (decoded is List) {
          parsedFormula = decoded
              .map((item) => GrammarFormulaBlock.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        // Fallback
      }
    }

    // Parse exampleAnatomyJson
    List<SentenceToken> parsedAnatomy = [];
    final anatomyData = json['exampleAnatomyJson'];
    if (anatomyData != null) {
      try {
        final decoded = anatomyData is String ? jsonDecode(anatomyData) : anatomyData;
        if (decoded is List) {
          parsedAnatomy = decoded
              .map((item) => SentenceToken.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        // Fallback
      }
    }

    return GrammarModel(
      id: (json['id'] ?? '').toString(),
      pattern: json['structure'] as String? ?? '',
      level: (json['jlptLevel'] ?? '').toString(),
      meaning: json['meaning'] as String? ?? '',
      formula: parsedFormula,
      exampleAnatomy: parsedAnatomy,
      exampleSentence: json['example'] as String? ?? '',
      translation: json['explanation'] as String? ?? '',
      formalityNuance: (json['formalityNuance'] as num?)?.toDouble() ?? 0.5,
      isMastered: false, // Local state
    );
  }
}
