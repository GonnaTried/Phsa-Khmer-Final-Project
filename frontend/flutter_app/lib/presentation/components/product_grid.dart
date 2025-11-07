// lib/presentation/components/product_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/product_model.dart';
import 'package:flutter_app/data/repositories/product_repository.dart';
import 'package:flutter_app/presentation/components/product_card.dart';

class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  // Use a Future to manage the asynchronous data fetching
  late Future<List<ProductModel>> _productsFuture;
  final ProductRepository _repository = ProductRepository();

  @override
  void initState() {
    super.initState();
    _productsFuture = _repository.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a spinner while loading
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show error message
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // No data found
          return const Center(child: Text('No products available.'));
        }

        // Data successfully loaded
        final products = snapshot.data!;

        // --- Responsive Grid Logic ---
        final screenWidth = MediaQuery.of(context).size.width;
        int crossAxisCount = 2; // Default for mobile
        double childAspectRatio = 0.75; // Aspect ratio for product cards

        if (screenWidth >= 1200) {
          crossAxisCount = 5; // Large desktop
          childAspectRatio = 0.8;
        } else if (screenWidth >= 800) {
          crossAxisCount = 4; // Tablet/Small desktop
          childAspectRatio = 0.8;
        } else if (screenWidth >= 600) {
          crossAxisCount = 3; // Tablet portrait
        }

        return GridView.builder(
          shrinkWrap:
              true, // Important for placing inside a SingleChildScrollView
          physics:
              const NeverScrollableScrollPhysics(), // Disable internal scrolling
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product);
          },
        );
      },
    );
  }
}
