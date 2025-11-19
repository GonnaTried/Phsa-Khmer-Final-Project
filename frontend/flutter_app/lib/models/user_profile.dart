class UserProfile {
  final int userId;
  final String? telegramUsername;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;

  UserProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.telegramUsername,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final int? rawUserId = json['user_id'] as int? ?? json['id'] as int?;

    if (rawUserId == null) {
      print("Warning: 'user_id' was null or missing in the profile response.");
    }

    return UserProfile(
      userId: rawUserId ?? 0,

      telegramUsername: json['telegram_username'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }
}
