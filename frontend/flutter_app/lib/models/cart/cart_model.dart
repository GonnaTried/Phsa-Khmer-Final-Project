import 'package:flutter_app/models/cart/cart_item_model.dart';

class CartModel {
  final int id;
  final List<CartItemModel> items;
  final double totalPrice;

  CartModel({required this.id, required this.items, required this.totalPrice});

  factory CartModel.fromJson(
    Map<String, dynamic> json,
    String Function(String) getImageUrl,
  ) {
    return CartModel(
      id: json['id'],
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      items: List<CartItemModel>.from(
        (json['items'] as List).map(
          (itemJson) => CartItemModel.fromJson(itemJson, getImageUrl),
        ),
      ),
    );
  }
}
