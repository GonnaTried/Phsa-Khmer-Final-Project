// class SellerOrders {
//   final int id;
//   final String status;
//   final double totalAmount;
//   final String customerName;
//   final String orderDate;
//   final List<SellerOrderItem> items;

//   SellerOrders({
//     required this.id,
//     required this.status,
//     required this.totalAmount,
//     required this.customerName,
//     required this.orderDate,
//     required this.items,
//   });

//   factory SellerOrders.fromJson(Map<String, dynamic> json) {
//     var itemsList = json['items'] as List;
//     List<SellerOrderItem> orderItems =
//         itemsList.map((i) => SellerOrderItem.fromJson(i)).toList();

//     return SellerOrders(
//       id: json['id'],
//       status: json['status'],
//       totalAmount: json['totalAmount'].toDouble(),
//       customerName: json['customerName'],
//       orderDate: json['orderDate'],
//       items: orderItems,
//     );
//   }

// }