class FlashcardSet {
  final int id;
  final String name;
  final String description;
  final bool isPublic;
  final DateTime? createdAt;
  final int totalCards;

  const FlashcardSet({
    required this.id,
    required this.name,
    required this.description,
    required this.isPublic,
    required this.createdAt,
    required this.totalCards,
  });

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    return FlashcardSet(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      description: json["description"] ?? "",
      isPublic: json["isPublic"] ?? false,
      createdAt: json["createdAt"] == null
          ? null
          : DateTime.parse(json["createdAt"]),
      totalCards: json["totalCards"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "isPublic": isPublic,
      "createdAt": createdAt?.toIso8601String(),
      "totalCards": totalCards,
    };
  }

  FlashcardSet copyWith({
    int? id,
    String? name,
    String? description,
    bool? isPublic,
    DateTime? createdAt,
    int? totalCards,
  }) {
    return FlashcardSet(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      totalCards: totalCards ?? this.totalCards,
    );
  }
}