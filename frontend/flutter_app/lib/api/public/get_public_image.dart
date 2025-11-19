import 'package:flutter_app/utils/app_constants.dart';

String getProductImageUrl(String filename) {
  if (filename.isEmpty) {
    return 'https://via.placeholder.com/150';
  }
  return '${AppConstants.kApiHostSpring}/api/public/files/$filename';
}
