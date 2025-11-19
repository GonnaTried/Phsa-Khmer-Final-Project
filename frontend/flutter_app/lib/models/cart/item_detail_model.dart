class ItemDetailModel {
  final int id;
  final String name;
  final double price;
  final String imageUrl;

  ItemDetailModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory ItemDetailModel.fromJson(
    Map<String, dynamic> json,
    String Function(String) getImageUrl,
  ) {
    return ItemDetailModel(
      id: json['id'],
      name: json['name'] ?? 'No Name',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: getImageUrl(json['imageUrl'] ?? ''),
    );
  }
}
