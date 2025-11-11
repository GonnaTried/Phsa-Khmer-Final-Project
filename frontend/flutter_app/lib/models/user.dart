class UserProfile {
  final int userId;
  final String username;
  final String phoneNumber;
  final String telegramUsername;
  final bool telegramLinked;

  UserProfile({
    required this.userId,
    required this.username,
    required this.phoneNumber,
    required this.telegramUsername,
    required this.telegramLinked,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as int,
      username: json['username'] ?? 'N/A',
      phoneNumber: json['phone_number'] ?? 'N/A',
      telegramUsername: json['telegram_username'] ?? 'N/A',
      telegramLinked: json['telegram_linked'] ?? false,
    );
  }
}
