// lib/models/address_model.dart

class ShippingAddress {
  final int? id;
  final int customerId;
  final String recipientName;
  final String streetAddress;
  final String city;
  final String province;
  final String zipCode;
  final String country;
  final bool isDefault;
  // Removed recipientPhone

  ShippingAddress({
    this.id,
    required this.customerId,
    required this.recipientName,
    required this.streetAddress,
    required this.city,
    required this.province,
    required this.zipCode,
    required this.country,
    this.isDefault = false,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'],
      customerId: json['customerId'],

      recipientName: json['recipientName'] ?? '', // ADDED ?? ''
      streetAddress: json['streetAddress'] ?? '', // ADDED ?? ''
      city: json['city'] ?? '', // ADDED ?? ''
      province: json['province'] ?? '', // ADDED ?? ''
      zipCode: json['zipCode'] ?? '', // ADDED ?? ''
      country: json['country'] ?? '', // ADDED ?? ''

      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customerId': customerId,
      'recipientName': recipientName,
      'streetAddress': streetAddress, // Match Java field name
      'city': city,
      'province': province, // Match Java field name
      'zipCode': zipCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  static ShippingAddress empty(int customerId) => ShippingAddress(
    customerId: customerId,
    recipientName: '',
    streetAddress: '',
    city: '',
    province: '',
    zipCode: '',
    country: '',
  );

  ShippingAddress copyWith({
    int? id,
    int? customerId,
    String? recipientName,
    String? streetAddress,
    String? city,
    String? province,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      recipientName: recipientName ?? this.recipientName,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      province: province ?? this.province,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
