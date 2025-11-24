import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/utils/app_constants.dart';

const String _authBaseUrl = AppConstants.kApiHostDjango + '/api/auth';

class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  // NEW: Key to store expiry time (as milliseconds since epoch)
  static const String _accessTokenExpiryKey = 'access_token_expiry';

  // --- Utility to get expiry time from storage ---
  Future<DateTime?> _getAccessTokenExpiry() async {
    final expiryString = await _storage.read(key: _accessTokenExpiryKey);
    if (expiryString != null) {
      final expiryMillis = int.tryParse(expiryString);
      if (expiryMillis != null) {
        return DateTime.fromMillisecondsSinceEpoch(expiryMillis);
      }
    }
    return null;
  }

  // 1. Save Tokens (Requires expirySeconds parameter)
  Future<void> saveTokens(
    String accessToken,
    String refreshToken,
    int expiresInSeconds,
  ) async {
    final expiryTime = DateTime.now().add(Duration(seconds: expiresInSeconds));

    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(
      key: _accessTokenExpiryKey,
      value: expiryTime.millisecondsSinceEpoch.toString(),
    );

    if (kDebugMode) {
      print('Tokens saved securely. Expires at: $expiryTime');
    }
  }

  // 4. Delete Tokens (Logout)
  Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accessTokenExpiryKey);
    if (kDebugMode) {
      print('Tokens deleted.');
    }
  }

  // 2. Get Access Token (NOW PROACTIVE)
  Future<String?> getAccessToken() async {
    String? accessToken = await _storage.read(key: _accessTokenKey);
    DateTime? expiry = await _getAccessTokenExpiry();

    if (accessToken == null || expiry == null) {
      return null;
    }

    // Check if the token is expired (or close to expiring, e.g., within 60 seconds)
    // Using a buffer ensures the token doesn't expire while the API request is in flight.
    const Duration buffer = Duration(seconds: 60);

    if (expiry.subtract(buffer).isBefore(DateTime.now())) {
      if (kDebugMode) {
        print(
          "Access token is near expiration or expired. Attempting proactive refresh...",
        );
      }

      final refreshSuccess = await refreshAccessToken();

      if (refreshSuccess) {
        // Retrieve the newly saved token
        return await _storage.read(key: _accessTokenKey);
      } else {
        // Refresh failed, token is unusable.
        return null;
      }
    }

    return accessToken;
  }

  // 3. Get Refresh Token (remains same)
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // 5. Check if User is Logged In (remains same)
  Future<bool> isUserLoggedIn() async {
    final token = await getAccessToken(); // Now this function handles refresh
    return token != null && token.isNotEmpty;
  }

  // 6. Refresh Access Token (Updated to use new saveTokens signature)
  Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      if (kDebugMode) {
        print("Refresh failed: No refresh token available.");
      }
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_authBaseUrl/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'] ?? refreshToken;
        final expiresInSeconds = data['expires_in'] ?? 3600;

        if (newAccessToken != null) {
          // IMPORTANT: Use the new signature of saveTokens
          await saveTokens(newAccessToken, newRefreshToken, expiresInSeconds);
          if (kDebugMode) {
            print("Tokens refreshed successfully.");
          }
          return true;
        }
      } else {
        if (kDebugMode) {
          print("Token refresh failed. Status: ${response.statusCode}");
        }
        // Refresh token is likely expired/invalid, force logout
        await deleteTokens();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during token refresh API call: $e");
      }
      return false;
    }
    return false;
  }
}
