class ListingItemModel {
  final int id;
  final String imageUrl;
  final String name;
  final double price;

  ListingItemModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  factory ListingItemModel.fromJson(Map<String, dynamic> json) {
    return ListingItemModel(
      id: json['id'],
      imageUrl: json['imageUrl'] ?? '',
      name: json['name'] ?? 'N/A',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ListingStatusModel {
  final int id;
  final String name;

  ListingStatusModel({required this.id, required this.name});

  factory ListingStatusModel.fromJson(Map<String, dynamic> json) {
    return ListingStatusModel(id: json['id'], name: json['name'] ?? 'unknown');
  }
}

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
