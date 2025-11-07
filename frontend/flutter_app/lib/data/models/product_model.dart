// lib/data/models/product_model.dart

class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  // Factory constructor to create a ProductModel from a JSON map
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Note: We need to safely handle potential nulls and type conversions
    // price and rating come as num (int/double) from JSON, so we convert them to double

    // Safely extract rating
    double rate = 0.0;
    if (json['rating'] != null && json['rating']['rate'] != null) {
      rate = (json['rating']['rate'] as num).toDouble();
    }

    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      rating: rate,
    );
  }
}
