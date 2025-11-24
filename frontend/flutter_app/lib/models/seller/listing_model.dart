import 'package:flutter_app/models/seller/listing_item_model.dart';

class ListingModel {
  final int id;
  final String title;
  final String image;
  final List<ListingItemModel> items;
  final ListingStatusModel status;

  ListingModel({
    required this.id,
    required this.title,
    required this.image,
    required this.items,
    required this.status,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'],
      title: json['title'] ?? 'Untitled Listing',
      image: json['image'] ?? '',
      status: ListingStatusModel.fromJson(json['status']),
      items:
          (json['items'] as List?)
              ?.map((i) => ListingItemModel.fromJson(i))
              .toList() ??
          [],
    );
  }
}
