import 'dart:convert';
import 'dart:io';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:http/http.dart' as http;

// const String _baseUrl = 'http://127.0.0.1:8000/api/auth';
// const String _baseUrl = 'http://10.0.2.2:8000/api/auth'; // Android Emulator
const String _baseUrl = 'https://your-doamain-here/api/auth';

// --- Auth Result Model ---

class AuthResult {
  final String status;
  final String message;
  final bool? registered;
  final String? accessToken;
  final String? refreshToken;

  AuthResult({
    required this.status,
    required this.message,
    this.registered,
    this.accessToken,
    this.refreshToken,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      status: json['status'] ?? 'error',
      message: json['message'] ?? 'Unknown error',
      registered: json['registered'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}

class AuthService {
  final TokenService _tokenService;
  AuthService(this._tokenService);
  Future<String?> initiateAuth() async {
    final url = Uri.parse('$_baseUrl/initiate/');
    try {
      final response = await http.post(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['one_time_code'];
        }
      }
      print('Failed to initiate auth: ${response.body}');
      return null;
    } catch (e) {
      print('Error initiating auth: $e');
      return null;
    }
  }

  Future<AuthResult> checkAuthStatus(String code) async {
    final url = Uri.parse('$_baseUrl/check/?code=$code');
    try {
      final response = await http.get(url);

      print('--- Polling Check Status ---');
      print('HTTP Status Code: ${response.statusCode}');
      print('Raw Response Body: ${response.body}');
      print('--------------------------');

      if (response.body.isEmpty) {
        return AuthResult(
          status: 'error',
          message: 'Server returned empty response.',
        );
      }

      if (response.statusCode == 404) {
        return AuthResult(
          status: 'invalid_code',
          message: 'Verification endpoint not found (404).',
        );
      }

      final data = jsonDecode(response.body);

      return AuthResult.fromJson(data);
    } on FormatException {
      return AuthResult(
        status: 'error',
        message: 'Server response malformed (JSON parse error).',
      );
    } on SocketException {
      return AuthResult(
        status: 'network_error',
        message: 'Connection Refused/Host Unreachable.',
      );
    } catch (e) {
      print('General Error during checkAuthStatus: $e');
      return AuthResult(status: 'error', message: 'Unknown network error.');
    }
  }

  Future<AuthResult> finalAuth({
    required String code,
    required String phoneNumber,
    String? firstName,
    String? lastName,
  }) async {
    final url = Uri.parse('$_baseUrl/final/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "code": code,
          "phone_number": phoneNumber,
          "first_name": firstName,
          "last_name": lastName,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['access_token'] != null) {
        return AuthResult(
          status: 'success',
          message: data['message'] ?? 'Login successful.',
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          registered: true,
        );
      }

      return AuthResult(
        status: 'error',
        message: data['message'] ?? 'Registration failed.',
      );
    } catch (e) {
      print('Error finalizing auth: $e');
      return AuthResult(status: 'error', message: 'Network Error');
    }
  }

  Future<Map<String, String>> _getHeaders({bool authorized = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    if (authorized) {
      final token = await _tokenService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<UserProfile?> fetchUserProfile() async {
    final url = Uri.parse('$_baseUrl/profile/');
    try {
      final headers = await _getHeaders(authorized: true);

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 401) {
        // Token expired or invalid. Need re-login or token refresh later.
        print('Profile fetch failed: Unauthorized (401)');
        return null;
      } else {
        print('Profile fetch failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}
