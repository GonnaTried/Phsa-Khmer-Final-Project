// lib/data/repositories/product_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/data/models/product_model.dart';

class ProductRepository {
  static const String _baseUrl = 'https://fakestoreapi.com';

  /// Fetches all products from the Fake Store API
  Future<List<ProductModel>> getProducts() async {
    final url = Uri.parse('$_baseUrl/products');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode the JSON array
        final List<dynamic> jsonList = json.decode(response.body);

        // Convert the list of JSON maps into a list of ProductModel objects
        return jsonList
            .map((jsonItem) => ProductModel.fromJson(jsonItem))
            .toList();
      } else {
        // Handle server errors
        throw Exception(
          'Failed to load products. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Handle network errors (e.g., no internet)
      throw Exception('Network error or failed to parse data: $e');
    }
  }
}
