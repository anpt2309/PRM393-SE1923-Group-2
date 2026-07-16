class User {
  final int id;
  final String firebaseUid;
  final String email;
  final String username;
  final String avatar;
  final int coin;
  final int streakDays;

  User({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.username,
    required this.avatar,
    required this.coin,
    required this.streakDays,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firebaseUid: json['firebaseUid'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      coin: json['coin'] ?? 0, // Đọc giá trị coin từ API
      streakDays: json['streakDays'] ?? 0,
    );
  }
}