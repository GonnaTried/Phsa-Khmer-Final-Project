// lib/services/address_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/models/address_model.dart';
import 'package:flutter_app/services/auth_service.dart'; // Import AuthService
import 'dart:io';

const String _apiBaseUrl = 'https://lauderdale-surround-lender-forwarding.trycloudflare.com/api';

class AddressService {
  final TokenService _tokenService;
  final AuthService _authService; // New dependency

  AddressService(this._tokenService, this._authService); // Updated Constructor

  // Helper to get authorized headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<int?> _getCurrentCustomerId() async {
    final profile = await _authService.fetchUserProfile();
    if (profile == null) {
      if (kDebugMode)
        print("Error: Failed to fetch User Profile to get Customer ID.");
      return null;
    }
    return profile.userId;
  }

  // GET: Fetch all addresses for the current customer
  Future<List<ShippingAddress>> fetchAddresses() async {
    final customerId = await _getCurrentCustomerId();
    if (customerId == null) return [];

    final url = Uri.parse('$_apiBaseUrl/customers/$customerId/addresses');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      // ... (rest of the logic remains the same)
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ShippingAddress.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        if (kDebugMode) print('Unauthorized to fetch addresses.');
        return [];
      } else {
        if (kDebugMode)
          print('Failed to fetch addresses: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching addresses: $e');
      return [];
    }
  }

  // POST: Create a new address
  Future<ShippingAddress?> createAddress(ShippingAddress address) async {
    final customerId = await _getCurrentCustomerId();
    if (customerId == null) return null;

    // Ensure the customer ID is set correctly before sending
    final addressWithId = address.copyWith(customerId: customerId);

    final url = Uri.parse('$_apiBaseUrl/customers/$customerId/addresses');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(addressWithId.toJson()),
      );

      if (response.statusCode == 201) {
        return ShippingAddress.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode) print('Failed to create address: ${response.body}');
        return null;
      }
    } on SocketException {
      if (kDebugMode) print('Network error creating address.');
      return null;
    } catch (e) {
      if (kDebugMode) print('Error creating address: $e');
      return null;
    }
  }

  // PUT: Update an existing address
  Future<ShippingAddress?> updateAddress(ShippingAddress address) async {
    final customerId = await _getCurrentCustomerId();
    if (customerId == null || address.id == null) return null;

    final url = Uri.parse(
      '$_apiBaseUrl/customers/$customerId/addresses/${address.id}',
    );
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(address.toJson()),
      );

      if (response.statusCode == 200) {
        return ShippingAddress.fromJson(jsonDecode(response.body));
      } else {
        if (kDebugMode) print('Failed to update address: ${response.body}');
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('Error updating address: $e');
      return null;
    }
  }

  // DELETE: Delete an address
  Future<bool> deleteAddress(int addressId) async {
    final customerId = await _getCurrentCustomerId();
    if (customerId == null) return false;

    final url = Uri.parse(
      '$_apiBaseUrl/customers/$customerId/addresses/$addressId',
    );
    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);

      return response.statusCode == 204;
    } catch (e) {
      if (kDebugMode) print('Error deleting address: $e');
      return false;
    }
  }

  // POST: Set an address as default
  Future<bool> setDefaultAddress(int addressId) async {
    final customerId = await _getCurrentCustomerId();
    if (customerId == null) return false;

    final url = Uri.parse(
      '$_apiBaseUrl/customers/$customerId/addresses/$addressId/set-default',
    );
    try {
      final headers = await _getHeaders();
      final response = await http.post(url, headers: headers);

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error setting default address: $e');
      return false;
    }
  }
}
