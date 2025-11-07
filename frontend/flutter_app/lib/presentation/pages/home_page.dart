// lib/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/components/product_grid.dart';
import 'package:flutter_app/presentation/components/search_bar_widget.dart'; // Will create this component next

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check screen size to decide if the search bar should appear in the body (mobile)
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ONLY SHOW THE MOBILE SEARCH BAR HERE IF IT'S A SMALL SCREEN
          if (isSmallScreen)
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              // We can reuse the visual appearance from the component if needed,
              // or simplify and place the TextField directly here for mobile:
              child: SearchBar(hintText: 'Search products'),
            ),

          const Text(
            'Featured Products',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          const ProductGrid(),

          Text(
            'Trending Categories',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
