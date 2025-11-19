import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/token_service.dart'; // Ensure this path is correct

class StripePaymentService {
  static const String _baseUrl =
      'https://lauderdale-surround-lender-forwarding.trycloudflare.com';

  final TokenService _tokenService; // Dependency injection

  // Constructor now requires TokenService
  StripePaymentService(this._tokenService); 

  // --- Helper function to build headers with Authorization ---
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _tokenService.getAccessToken();
    
    if (token == null) {
      throw Exception("Authentication token missing. User must log in.");
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // JWT is included here
    };
  }


  Future<Map<String, String>> initiateCheckout(int customerId) async {
    final url = Uri.parse('$_baseUrl/api/checkout/$customerId');

    try {
      final headers = await _getAuthHeaders(); // Use the authorized headers
      
      final response = await http.post(
        url,
        headers: headers, // Pass the headers with the JWT
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'sessionUrl': data['sessionUrl'] as String,
          'sessionId': data['sessionId'] as String,
        };
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized (401). Token might be invalid or expired.");
      } 
      else {
        final errorBody = json.decode(response.body);
        throw Exception(
            'Failed to initiate checkout. Status code: ${response.statusCode}. Error: ${errorBody['error'] ?? 'Unknown'}');
      }
    } catch (e) {
      // Re-throw the exception wrapped for better context
      throw Exception('Network or Authentication error during checkout initiation: $e');
    }
  }

  // checkPaymentStatus does not require authentication
  Future<String> checkPaymentStatus(String sessionId) async {
    final url = Uri.parse('$_baseUrl/api/payment/status?session_id=$sessionId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] as String;
      } 
      // Handle the case where the server is up but returns an unexpected status
      return 'CONNECTION_ERROR'; 
      
    } catch (e) {
      // Handle network failure entirely (e.g., DNS lookup failure)
      return 'CONNECTION_ERROR'; 
    }
  }
}