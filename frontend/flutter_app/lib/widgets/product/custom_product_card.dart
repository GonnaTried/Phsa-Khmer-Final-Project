import 'package:flutter/material.dart';
import 'package:flutter_app/models/product/product.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';

class CustomProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const CustomProductCard({Key? key, required this.product, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
      child: Card(
        color: AppColors.surfaceColor,
        elevation: AppConstants.kDefaultElevation / 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.kBorderRadius),
                ),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      color: AppColors.textSecondary,
                      size: 40,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.kSpacingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppConstants.kSmallTextSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpaces.smallVertical,
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: AppConstants.kTextSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  // AppSpaces.smallVertical,
                  // Row(
                  //   children: [
                  //     const Icon(
                  //       Icons.star,
                  //       color: AppColors.starColor,
                  //       size: AppConstants.kIconSizeSmall * 0.8,
                  //     ),
                  //     AppSpaces.smallHorizontal,
                  //     Text(
                  //       product.rating.toStringAsFixed(1),
                  //       style: const TextStyle(
                  //         fontSize: AppConstants.kSmallTextSize,
                  //         color: AppColors.textSecondary,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
