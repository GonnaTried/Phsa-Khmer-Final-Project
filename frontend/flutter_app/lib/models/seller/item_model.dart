import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ItemModel {
  final int id;
  final String name;
  final double price;

  final String? imageUrl;

  final XFile? imageXFile;

  final String? localId;

  ItemModel({
    this.id = 1,
    required this.name,
    required this.price,
    this.imageUrl,
    this.imageXFile,
    this.localId,
  });

  // --- Factory for API Retrieval (Server Data) ---
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      imageXFile: null,
      localId: null,
    );
  }

  // --- CopyWith (Essential for state updates) ---
  ItemModel copyWith({
    String? name,
    double? price,
    String? imageUrl,
    File? imageFile,
    String? localId,
  }) {
    return ItemModel(
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      imageXFile: imageXFile ?? this.imageXFile,
      localId: localId ?? this.localId,
    );
  }

  File? get imageFile => imageXFile != null ? File(imageXFile!.path) : null;
}
