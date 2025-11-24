import 'package:flutter_app/models/order/order_item.dart';

class OrderHistory {
  final int id;
  final int customerId;
  final DateTime orderDate;
  final String status;
  final double totalAmount;
  final List<OrderItem> items;
  final String shippingAddressSummary;

  OrderHistory({
    required this.id,
    required this.customerId,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.items,
    required this.shippingAddressSummary,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] ?? [];
    return OrderHistory(
      id: json['id'] as int,
      customerId: json['customerId'] as int,
      orderDate: DateTime.parse(json['orderDate'] as String),
      status: json['status'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      items: itemsJson.map((i) => OrderItem.fromJson(i)).toList(),
      shippingAddressSummary: json['shippingAddressSummary'] as String,
    );
  }
}
