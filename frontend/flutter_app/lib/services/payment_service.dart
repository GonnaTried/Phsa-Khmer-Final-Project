import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter_app/models/checkout_request.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/token_service.dart'; // Assume TokenService is available
import 'dart:io';

// IMPORTANT: Adjust this URL based on where you are running:
// - 'http://10.0.2.2:8080/api' for Android Emulator
// - 'http://localhost:8080/api' for Web/Desktop
const String _paymentBaseUrl = 'https://lauderdale-surround-lender-forwarding.trycloudflare.com/api';

class PaymentService {
  // If you need authorized requests for Payment Intent creation, inject TokenService
  // For simplicity, we assume you get the TokenService instance somehow, or make it a field
  final TokenService _tokenService = TokenService();

  // Helper to get authorized headers
  Future<Map<String, String>> _getHeaders({bool authorized = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (authorized) {
      // Assuming Payment Intent creation requires authentication
      final token = await _tokenService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // 1. Implementation for the Payment Sheet flow (Requires Payment Intent from backend)
  // This replaces the old createPaymentIntent(int amount, String currency) method.
  // URL: /api/checkout/create-payment-intent
  Future<Map<String, dynamic>?> createPaymentIntent(
    CheckoutRequest checkoutRequest,
  ) async {
    final url = Uri.parse('$_paymentBaseUrl/checkout/create-payment-intent');

    try {
      final headers = await _getHeaders(authorized: true);

      if (kDebugMode) {
        print('Requesting Payment Intent at: $url');
        print('Request Body: ${jsonEncode(checkoutRequest.toJson())}');
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(checkoutRequest.toJson()),
      );

      if (response.statusCode == 200) {
        // Backend should return {"client_secret": "..."}
        return json.decode(response.body);
      } else {
        if (kDebugMode) {
          print('Backend Error ${response.statusCode}: ${response.body}');
        }
        throw Exception(
          'Failed to create payment intent on server. Status: ${response.statusCode}',
        );
      }
    } on SocketException {
      if (kDebugMode) print('Network connection failed.');
      throw Exception(
        'Network connection failed. Check host URL/server status.',
      );
    } catch (e) {
      if (kDebugMode) print("Error creating payment intent: $e");
      throw Exception('Failed to create payment intent');
    }
  }

  // 2. Implementation for the Checkout Session flow (Redirect flow)
  // URL: /api/checkout/create-session
  Future<String?> createStripeCheckoutSession(
    CheckoutRequest requestBody,
  ) async {
    final url = Uri.parse('$_paymentBaseUrl/checkout/create-session');

    try {
      final headers = await _getHeaders(authorized: true);

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody.toJson()),
      );

      if (response.statusCode == 200) {
        // Backend returns the Session ID as a String in the body
        return response.body;
      } else {
        print('Backend failed to create session: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error creating session: $e');
      return null;
    }
  }
}
