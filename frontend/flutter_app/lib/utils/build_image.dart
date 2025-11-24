import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';

String _getImageUrl(String filename) {
  if (filename.isEmpty) return 'https://via.placeholder.com/60';
  return '${AppConstants.kApiHostSpring}/api/public/files/$filename';
}

Widget buildImage(String filename) {
  final imageUrl = _getImageUrl(filename);

  const double imageSize = 50.0;

  if (filename.isEmpty) {
    return const SizedBox(
      width: imageSize,
      height: imageSize,
      child: Icon(Icons.broken_image, color: AppColors.danger),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(5.0),
    child: Image.network(
      imageUrl,
      width: imageSize,
      height: imageSize,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: imageSize,
          height: imageSize,
          color: AppColors.dividerColor,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox(
          width: imageSize,
          height: imageSize,
          child: Icon(
            Icons.image_not_supported,
            color: AppColors.textSecondary,
          ),
        );
      },
    ),
  );
}
