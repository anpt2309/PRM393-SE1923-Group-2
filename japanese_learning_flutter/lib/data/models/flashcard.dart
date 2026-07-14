class Flashcard {
  final int id;
  final String front;
  final String back;
  final String note;

  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.note,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json["id"] ?? 0,
      front: json["front"] ?? "",
      back: json["back"] ?? "",
      note: json["note"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "front": front,
      "back": back,
      "note": note,
    };
  }

  Flashcard copyWith({
    int? id,
    String? front,
    String? back,
    String? note,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      note: note ?? this.note,
    );
  }
}