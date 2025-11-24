import 'package:flutter_app/models/order/item_detail.dart';

class OrderItem {
  final int itemId;
  final ItemDetail item;
  final int quantity;
  final double unitPrice;
  final String? itemImageUrl;

  OrderItem({
    required this.itemId,
    required this.item,
    required this.quantity,
    required this.unitPrice,
    this.itemImageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['itemId'] as int,
      item: ItemDetail.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      itemImageUrl: json['itemImageUrl'] as String?,
    );
  }
}
