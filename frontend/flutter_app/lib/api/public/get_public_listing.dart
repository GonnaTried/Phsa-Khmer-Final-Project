// api/public/get_public_listing.dart

import 'dart:convert';
import 'package:flutter_app/models/product/item_model.dart';
import 'package:flutter_app/models/product/product.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/models/paginated_listing_response.dart';

class GetPublicListing {
  /// Helper to construct the full image URL.
  String _getProductImageUrl(String filename) {
    if (filename.isEmpty) {
      return 'https://via.placeholder.com/300x400';
    }
    return '${AppConstants.kApiHostSpring}/api/public/files/$filename';
  }

  /// Helper to parse a single JSON object into a Product.
  Product _parseProductFromJson(Map<String, dynamic> json) {
    List<ItemModel> parsedItems = [];
    if (json['items'] != null && json['items'] is List) {
      // <-- FIX: Use List.from() here for robustness
      parsedItems = List<ItemModel>.from(
        (json['items'] as List).map((itemJson) {
          return ItemModel(
            id: itemJson['id'] ?? 0,
            name: itemJson['name'] ?? 'No Name',
            price: (itemJson['price'] as num?)?.toDouble() ?? 0.0,
            imageUrl: _getProductImageUrl(itemJson['imageUrl'] ?? ''),
          );
        }),
      );
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['title'] ?? 'Untitled Listing',
      price: (parsedItems.isNotEmpty) ? parsedItems[0].price : 0.0,
      imageUrl: _getProductImageUrl(json['image'] ?? ''),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      items: parsedItems,
    );
  }

  Future<PaginatedListingResponse> fetchPaginatedListings({
    required int page,
    required int size,
  }) async {
    final url = Uri.parse(
      '${AppConstants.kApiHostSpring}/api/public/listings?page=$page&size=$size',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> jsonList = jsonResponse['content'] as List<dynamic>;

      // <-- FIX: Explicitly create a Dart List to avoid JSArray issues
      final List<Product> newProducts = List<Product>.from(
        jsonList.map((json) => _parseProductFromJson(json)),
      );

      return PaginatedListingResponse(
        listings: newProducts,
        isLastPage: jsonResponse['last'] as bool? ?? true,
      );
    } else {
      throw Exception(
        'Failed to load listings. Status Code: ${response.statusCode}',
      );
    }
  }

  Future<Product> fetchListingById(String id) async {
    final url = Uri.parse(
      '${AppConstants.kApiHostSpring}/api/public/listings/$id',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return _parseProductFromJson(json);
    } else if (response.statusCode == 404) {
      throw Exception('Listing not found');
    } else {
      throw Exception(
        'Failed to load listing. Status Code: ${response.statusCode}',
      );
    }
  }

  Future<PaginatedListingResponse> fetchListingsByUserId(
    String userId, {
    required int page,
    required int size,
  }) async {
    final url = Uri.parse(
      '${AppConstants.kApiHostSpring}/api/public/listings/user/$userId?page=$page&size=$size',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final List<dynamic> jsonList = jsonResponse['content'] as List<dynamic>;

      final List<Product> newProducts = jsonList
          .map((json) => _parseProductFromJson(json))
          .toList();

      return PaginatedListingResponse(
        listings: newProducts,
        isLastPage: jsonResponse['last'] as bool? ?? true,
      );
    } else {
      throw Exception(
        'Failed to load user listings. Status Code: ${response.statusCode}',
      );
    }
  }
}
