// lib/models/checkout_request.dart

class CheckoutRequest {
  final List<CartItemRequest> items;
  final String successUrl;
  final String cancelUrl;
  final int? shippingAddressId;

  CheckoutRequest({
    required this.items,
    required this.successUrl,
    required this.cancelUrl,
    this.shippingAddressId,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'successUrl': successUrl,
      'cancelUrl': cancelUrl,
      'shippingAddressId': shippingAddressId,
    };
  }
}

class CartItemRequest {
  final int listingId;
  final int quantity;

  CartItemRequest({required this.listingId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'listingId': listingId, 'quantity': quantity};
  }
}
