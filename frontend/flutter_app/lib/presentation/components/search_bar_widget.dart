// lib/presentation/components/search_bar_widget.dart

import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the screen is small (where the search bar is needed in the body)
    bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    // Only show the search bar in the body on small screens,
    // otherwise the icon in the AppBar is sufficient.
    if (!isSmallScreen) {
      return const SizedBox.shrink(); // Hide the widget
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search products',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
