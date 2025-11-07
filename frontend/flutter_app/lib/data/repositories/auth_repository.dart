// lib/data/repositories/auth_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  // Use a constant for your base URL
  static const String _baseUrl =
      'https://tinderlike-bullheadedly-lillianna.ngrok-free.dev/api/auth';

  // Endpoint to start the process
  final Uri _initiateUrl = Uri.parse('$_baseUrl/initiate/');

  /// Sends a POST request to initiate the authentication process and retrieves a one-time code.
  Future<String> initiateAuth() async {
    try {
      final response = await http.post(_initiateUrl);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true &&
            jsonResponse['one_time_code'] != null) {
          return jsonResponse['one_time_code'] as String;
        } else {
          throw Exception(
            'Failed to initiate authentication: Server response body invalid.',
          );
        }
      } else {
        throw Exception(
          'Failed to initiate authentication. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Handle network errors
      throw Exception('Network error during authentication initiation: $e');
    }
  }

  // TODO: Add a method here later to poll the server to check if the user has completed the auth.
  Future<String?> checkAuthStatus(String oneTimeCode) async {
    final verifyUrl = Uri.parse('$_baseUrl/verify/$oneTimeCode');

    // NOTE: This should probably be a GET request if it's just checking status.
    // Assuming a simple GET for status check:
    final response = await http.get(verifyUrl);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // Assume the backend returns the token when successful
      if (jsonResponse['status'] == 'verified' &&
          jsonResponse['token'] != null) {
        return jsonResponse['token'] as String;
      }
    }
    // If not verified or error, return null
    return null;
  }
}
