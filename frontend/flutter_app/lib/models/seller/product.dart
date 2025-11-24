import 'package:flutter_app/models/seller/item_model.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final double rating;
  final List<ItemModel> items;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.rating = 0.0,
    this.items = const [],
  });
}
