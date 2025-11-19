class CheckoutResponse {
  final String sessionId;
  final String checkoutUrl;

  CheckoutResponse({required this.sessionId, required this.checkoutUrl});

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      sessionId: json['sessionId'] as String,
      checkoutUrl: json['checkoutUrl'] as String,
    );
  }
}
