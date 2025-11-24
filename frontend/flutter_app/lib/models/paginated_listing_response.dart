import 'package:flutter_app/models/seller/product.dart';
import 'package:flutter_app/widgets/product/custom_product_card.dart';

class PaginatedListingResponse {
  final List<Product> listings;
  final bool isLastPage;

  PaginatedListingResponse({required this.listings, required this.isLastPage});
}
