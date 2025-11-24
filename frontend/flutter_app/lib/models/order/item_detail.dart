class ItemDetail {
  final int id;
  final String name;
  final String imageUrl;
  final double price;

  ItemDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  factory ItemDetail.fromJson(Map<String, dynamic> json) {
    return ItemDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }
}