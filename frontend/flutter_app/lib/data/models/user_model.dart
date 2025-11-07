// lib/data/models/user_model.dart

class UserModel {
  final int id;
  final String username;
  final String telegramId;
  final String token; // The JWT or API token

  UserModel({
    required this.id,
    required this.username,
    required this.telegramId,
    required this.token,
  });

  // Factory constructor for JSON/Map conversion (if needed)
}
