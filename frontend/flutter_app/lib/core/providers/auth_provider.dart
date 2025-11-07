// lib/core/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/data/models/user_model.dart';

// The state of our authentication (nullable UserModel means logged out)
class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null); // Initial state is logged out

  // Placeholder for a real authentication function
  Future<void> signInWithToken(String token) async {
    // 1. Validate token with backend
    // 2. Fetch user details

    // Simulation:
    await Future.delayed(const Duration(seconds: 1));
    final fakeUser = UserModel(
      id: 99,
      username: 'TelegramUser',
      telegramId: 'telegram_99',
      token: token,
    );
    state = fakeUser; // Set the state to the logged-in user
  }

  void signOut() {
    // Clear token from storage (SharedPreferences/Hive/etc.)
    state = null; // Set state to logged out
  }

  bool get isLoggedIn => state != null;
}

// Global provider instance
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>(
  (ref) => AuthNotifier(),
);
