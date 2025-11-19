import 'package:flutter_app/models/cart/item_detail_model.dart';

class CartItemModel {
  final int id;
  final int quantity;
  final ItemDetailModel item;

  CartItemModel({required this.id, required this.quantity, required this.item});

  factory CartItemModel.fromJson(
    Map<String, dynamic> json,
    String Function(String) getImageUrl,
  ) {
    return CartItemModel(
      id: json['id'],
      quantity: json['quantity'] ?? 0,
      item: ItemDetailModel.fromJson(json['item'], getImageUrl),
    );
  }
}
