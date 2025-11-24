class ListingStatusModel {
  final int id;
  final String name;

  ListingStatusModel({required this.id, required this.name});

  factory ListingStatusModel.fromJson(Map<String, dynamic> json) {
    return ListingStatusModel(id: json['id'], name: json['name'] ?? 'unknown');
  }
}
