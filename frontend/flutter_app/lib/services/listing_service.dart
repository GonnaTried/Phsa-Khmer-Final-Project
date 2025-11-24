import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/models/seller/item_model.dart';
// Assuming TokenService is now updated
import 'package:flutter_app/services/token_service.dart';
import 'package:image_picker/image_picker.dart';

const String _baseUrl = AppConstants.kApiHostSpring + '/api/seller/listings';

class ListingService {
  final TokenService _tokenService;
  ListingService(this._tokenService);

  // Helper function to build and execute the MultipartRequest
  Future<http.StreamedResponse?> _executePostListingRequest({
    required List<ItemModel> items,
    required String listingTitle,
    required XFile? listingThumbnailFile,
    required int statusId,
    required String accessToken,
    String? category,
    String? tags,
  }) async {
    final uri = Uri.parse('$_baseUrl');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken';
    // ..headers['Content-Type'] = 'multipart/form-data'; // Set by the request handler

    if (listingThumbnailFile == null) {
      print('Error: Missing required listing thumbnail file.');
      return null;
    }

    // --- 1. Add Listing Text Fields ---
    request.fields['title'] = listingTitle;
    request.fields['item_count'] = items.length.toString();
    request.fields['statusId'] = statusId.toString();
    if (category?.isNotEmpty == true) {
      request.fields['category'] = category!;
    }
    if (tags?.isNotEmpty == true) {
      request.fields['tags'] = tags!;
    }

    // --- 2. Add the Listing Thumbnail File ---
    const String thumbnailFieldName = 'listing_thumbnail';

    if (kIsWeb) {
      Uint8List fileBytes = await listingThumbnailFile.readAsBytes();
      if (fileBytes.isEmpty) return null; // Validation

      request.files.add(
        http.MultipartFile.fromBytes(
          thumbnailFieldName,
          fileBytes,
          filename: listingThumbnailFile.name,
        ),
      );
    } else {
      final thumbnailFileCheck = File(listingThumbnailFile.path);
      if (!await thumbnailFileCheck.exists() ||
          await thumbnailFileCheck.length() == 0)
        return null;

      request.files.add(
        await http.MultipartFile.fromPath(
          thumbnailFieldName,
          listingThumbnailFile.path,
          filename: listingThumbnailFile.name,
        ),
      );
    }

    // --- 3. Process Item Images and Metadata ---
    final List<Map<String, dynamic>> itemDetails = [];
    const String itemFieldName = 'item_images';

    for (var item in items) {
      final itemImageXFile = item.imageXFile;

      if (itemImageXFile == null) continue;

      String filename = itemImageXFile.name;

      if (kIsWeb) {
        Uint8List fileBytes = await itemImageXFile.readAsBytes();
        if (fileBytes.isNotEmpty) {
          request.files.add(
            http.MultipartFile.fromBytes(
              itemFieldName,
              fileBytes,
              filename: filename,
            ),
          );
          itemDetails.add({'name': item.name, 'price': item.price});
        }
      } else {
        final itemFileCheck = File(itemImageXFile.path);
        if (await itemFileCheck.exists() && await itemFileCheck.length() > 0) {
          request.files.add(
            await http.MultipartFile.fromPath(
              itemFieldName,
              itemImageXFile.path,
              filename: filename,
            ),
          );
          itemDetails.add({'name': item.name, 'price': item.price});
        }
      }
    }

    if (itemDetails.isEmpty && items.isNotEmpty) {
      print('Error: All item images were skipped.');
      return null;
    }

    // --- 4. Add JSON Metadata Field ---
    request.fields['item_details'] = jsonEncode(itemDetails);

    try {
      return await request.send();
    } catch (e) {
      print('Error sending multipart request: $e');
      return null;
    }
  }

  Future<bool> postFullListing({
    required List<ItemModel> items,
    required String listingTitle,
    required XFile? listingThumbnailFile,
    required int statusId,
    String? category,
    String? tags,
  }) async {
    String? accessToken = await _tokenService.getAccessToken();
    if (accessToken == null) {
      print('Authentication token missing.');
      return false;
    }

    http.StreamedResponse? response = await _executePostListingRequest(
      items: items,
      listingTitle: listingTitle,
      listingThumbnailFile: listingThumbnailFile,
      statusId: statusId,
      accessToken: accessToken,
      category: category,
      tags: tags,
    );

    if (response != null && response.statusCode == 401) {
      print('Request failed with 401. Attempting token refresh...');

      final refreshSuccess = await _tokenService.refreshAccessToken();

      if (refreshSuccess) {
        String? newAccessToken = await _tokenService.getAccessToken();

        if (newAccessToken != null) {
          print('Token refreshed. Retrying request...');

          response = await _executePostListingRequest(
            items: items,
            listingTitle: listingTitle,
            listingThumbnailFile: listingThumbnailFile,
            statusId: statusId,
            accessToken: newAccessToken,
            category: category,
            tags: tags,
          );
        } else {
          return false;
        }
      } else {
        print('Token refresh failed. Cannot retry request.');
        return false;
      }
    }

    if (response == null) return false;

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Full Listing created successfully.');
      return true;
    } else {
      print('Failed to create listing (Status: ${response.statusCode})');
      print('Server Response Body: $responseBody');
      return false;
    }
  }
}
