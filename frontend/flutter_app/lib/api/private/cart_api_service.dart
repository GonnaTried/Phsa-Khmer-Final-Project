// api/cart_api_service.dart
import 'dart:convert';
import 'package:flutter_app/models/payment/checkout_response.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/models/cart/cart_model.dart';

const String BASE_URL =
    "https://lauderdale-surround-lender-forwarding.trycloudflare.com";

class CheckoutStatus {
  final String sessionId;
  final String status;

  CheckoutStatus({required this.sessionId, required this.status});

  factory CheckoutStatus.fromJson(Map<String, dynamic> json) {
    return CheckoutStatus(
      sessionId: json['sessionId'] as String,
      status: json['status'] as String,
    );
  }
}

class CartApiService {
  final TokenService _tokenService;
  CartApiService(this._tokenService);

  Future<CheckoutStatus> checkPaymentStatus(String sessionId) async {
    // Note: This API endpoint is public (permitAll) so no token is needed.
    final url = Uri.parse('$BASE_URL/api/payment/status?session_id=$sessionId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return CheckoutStatus.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch payment status: ${response.statusCode}');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getAccessToken();
    if (token == null) throw Exception('Authentication token not found.');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _getProductImageUrl(String filename) {
    if (filename.isEmpty) return 'https://via.placeholder.com/150';
    return '${AppConstants.kApiHostSpring}/api/public/files/$filename';
  }

  Future<CartModel> _parseCart(http.Response response) {
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Future.value(CartModel.fromJson(json, _getProductImageUrl));
    } else {
      throw Exception('Failed cart operation: ${response.statusCode}');
    }
  }

  Future<CartModel> getMyCart() async {
    final url = Uri.parse('${AppConstants.kApiHostSpring}/api/cart');
    final response = await http.get(url, headers: await _getHeaders());
    return _parseCart(response);
  }

  Future<CartModel> addItemToCart(int itemId, int quantity) async {
    final url = Uri.parse('${AppConstants.kApiHostSpring}/api/cart/items');
    final body = jsonEncode({'itemId': itemId, 'quantity': quantity});
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: body,
    );
    return _parseCart(response);
  }

  Future<CartModel> updateItemQuantity(int itemId, int quantity) async {
    final url = Uri.parse(
      '${AppConstants.kApiHostSpring}/api/cart/items/$itemId',
    );
    final body = jsonEncode({'quantity': quantity});
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: body,
    );
    return _parseCart(response);
  }

  Future<CartModel> removeItemFromCart(int itemId) async {
    final url = Uri.parse(
      '${AppConstants.kApiHostSpring}/api/cart/items/$itemId',
    );
    final response = await http.delete(url, headers: await _getHeaders());
    return _parseCart(response);
  }

  Future<CheckoutResponse> initiateStripeCheckout(int customerId, {String clientType = 'mobile'}) async {
    final token = await _tokenService.getAccessToken();
    if (token == null) {
      throw Exception("User not logged in.");
    }

    final url = Uri.parse('$BASE_URL/api/checkout/$customerId?client=$clientType');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      return CheckoutResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to initiate checkout: ${response.body}');
    }
  }
}
