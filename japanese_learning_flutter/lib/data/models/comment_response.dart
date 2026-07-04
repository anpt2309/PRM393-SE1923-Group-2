class CommentResponse {
  final int id;
  final String content;
  final String userName;
  final int questionId;

  CommentResponse({
    required this.id,
    required this.content,
    required this.userName,
    required this.questionId,
  });

  factory CommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentResponse(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      content: json['content']?.toString() ?? '',
      userName: json['userName']?.toString() ?? 'Người dùng',
      questionId: json['questionId'] is num ? (json['questionId'] as num).toInt() : 0,
    );
  }

  Map<String, String> toMapForReview() {
    return {
      'user': userName,
      'content': content,
    };
  }
}
