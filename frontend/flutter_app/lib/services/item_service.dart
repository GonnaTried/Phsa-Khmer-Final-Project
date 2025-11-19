import 'dart:io';
import 'package:flutter_app/models/product/item_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _baseUrl =
    'https://lauderdale-surround-lender-forwarding.trycloudflare.com/api/items';

class ItemService {
  final String? accessToken;

  ItemService(this.accessToken);

  Future<bool> createItem({
    required ItemModel itemData,
    required String imageFilePath,
  }) async {
    final uri = Uri.parse(_baseUrl);

    // 1. Create the Multipart Request
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..headers['Content-Type'] = 'multipart/form-data';

    // 2. Add text fields (Name and Price)

    request.fields['name'] = itemData.name;
    request.fields['price'] = itemData.price.toString();

    /*
    // OPTION B: Send model data as a JSON part (If Spring Boot uses @RequestPart ItemModel)
    request.fields['item_json'] = jsonEncode({
      'name': itemData.name,
      'price': itemData.price,
    });
    */

    // 3. Add the file part
    final file = await http.MultipartFile.fromPath('image', imageFilePath);
    request.files.add(file);

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Item created successfully: $responseBody');
        return true;
      } else {
        print(
          'Failed to create item (Status: ${response.statusCode}): $responseBody',
        );
        return false;
      }
    } catch (e) {
      print('Error during item creation: $e');
      return false;
    }
  }
}
