import 'package:flutter/foundation.dart';
import 'package:flutter_app/models/user_profile.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  UserProfile? _userProfile;
  int? get currentUserId => _userProfile?.userId;

  final TokenService _tokenService;
  final AuthService _authService;

  AuthProvider(this._tokenService, this._authService) {
    checkInitialLoginStatus();
  }

  bool get isLoggedIn => _isLoggedIn;
  UserProfile? get userProfile => _userProfile;

  Future<void> checkInitialLoginStatus() async {
    _isLoggedIn = await _tokenService.isUserLoggedIn();
    if (_isLoggedIn) {
      await fetchAndSetProfile();
    }
    notifyListeners();
  }

  Future<void> loginSuccess(
    String accessToken,
    String refreshToken,
    int expiresInSeconds,
  ) async {
    await _tokenService.saveTokens(accessToken, refreshToken, expiresInSeconds);

    _isLoggedIn = true;
    await fetchAndSetProfile();
    notifyListeners();
  }

  Future<void> logout() async {
    await _tokenService.deleteTokens();
    _isLoggedIn = false;
    _userProfile = null;
    notifyListeners();
  }

  Future<void> fetchAndSetProfile() async {
    if (_isLoggedIn) {
      final profile = await _authService.fetchUserProfile();

      if (profile == null) {
        if (kDebugMode) {
          print(
            "Warning: Failed to fetch user profile, possibly due to expired token/failed refresh.",
          );
        }
        await logout();
      } else {
        _userProfile = profile;
        notifyListeners();
      }
    }
  }
}
