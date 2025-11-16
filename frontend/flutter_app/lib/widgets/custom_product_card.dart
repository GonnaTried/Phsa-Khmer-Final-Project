import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_styles.dart';

class CustomProductCard extends StatelessWidget {
  // --- Required Product Data ---
  final String imageUrl;
  final String title;
  final double price;
  final double? originalPrice;
  final double rating;

  // --- Actions ---
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const CustomProductCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    this.originalPrice,
    this.rating = 0.0,
    required this.onTap,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if the product is on sale
    final bool isOnSale = originalPrice != null && originalPrice! > price;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Product Image
            _buildImage(context),

            // 2. Product Details
            Padding(
              padding: const EdgeInsets.all(AppConstants.kSpacingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: AppStyles.productTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpaces.smallVertical,

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: isOnSale
                            ? AppStyles.priceSale
                            : AppStyles.priceRegular,
                      ),
                      AppSpaces.smallHorizontal,

                      if (isOnSale)
                        Text(
                          '\$${originalPrice!.toStringAsFixed(2)}',
                          style: AppStyles.priceOriginal,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Add to Cart Button (Bottom of the card)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.kSpacingSmall,
                0,
                AppConstants.kSpacingSmall,
                AppConstants.kSpacingSmall,
              ),
              child: CustomButton(
                text: "Add",
                icon1: Icon(Icons.add_shopping_cart_sharp),
                height: 35,
                onPressed: onAddToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.kBorderRadius),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryLight,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.dividerColor,
              child: const Center(
                child: Icon(Icons.broken_image, color: AppColors.textSecondary),
              ),
            );
          },
        ),
      ),
    );
  }
}
