import 'package:flutter/material.dart';
import 'package:flutter_app/models/seller/product.dart';
import 'package:flutter_app/screens/view_listing/view_listing_detail.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/product/custom_product_card.dart';
import '../../utils/app_constants.dart';

class CustomProductGrid extends StatelessWidget {
  final List<Product> products;
  final double minItemWidth;

  const CustomProductGrid({
    Key? key,
    required this.products,
    this.minItemWidth = 180.0,
  }) : super(key: key);

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth < AppConstants.kTabletBreakpoint) {
      return (screenWidth / minItemWidth).floor();
    } else if (screenWidth < AppConstants.kMaxContentWidth) {
      return (screenWidth / (minItemWidth + 50)).floor();
    } else {
      return (AppConstants.kMaxContentWidth / (minItemWidth + 70)).floor();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final crossAxisCount = _calculateCrossAxisCount(screenWidth);

    if (products.isEmpty) {
      return const Center(child: Text('No products available.'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      itemCount: products.length,
      padding: const EdgeInsets.all(AppConstants.kDefaultPadding),

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: AppConstants.kSpacingMedium,
        mainAxisSpacing: AppConstants.kSpacingMedium,
      ),

      itemBuilder: (context, index) {
        final product = products[index];
        return CustomProductCard(
          product: product,
          onTap: () {
            NavigationUtils.push(
              context,
              ViewListingDetail(listingId: product.id),
            );
          },
        );
      },
    );
  }
}
