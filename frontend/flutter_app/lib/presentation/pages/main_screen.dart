// lib/presentation/pages/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/pages/account_page.dart';
import 'package:flutter_app/presentation/pages/home_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('Category Page')),
    const Center(child: Text('Cart Page')),
    const AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define break points for responsive design
    // 600 is a common breakpoint for tablet/desktop vs mobile
    bool isLargeScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      // 1. Top Bar (AppBar) is always present for branding and Search/Cart/Account on large screens
      appBar: AppBar(
        // Use automaticallyImplyLeading: false if we want full control over the layout
        automaticallyImplyLeading: false,

        // --- Responsive Title/Search Implementation ---
        title: isLargeScreen
            ? _buildLargeScreenHeader(context) // New structure for web
            : const Text('My E-commerce Shop'), // Simple title for mobile
        // Actions list (only used for non-navigation actions on large screens, or primary actions on mobile)
        actions: isLargeScreen ? _buildTopBarActions() : null,
      ),
      // 2. The main content area
      body: Row(
        children: <Widget>[
          // 3. Side Navigation for Large Screens (e.g., Web/Desktop)
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.category),
                  label: Text('Category'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_cart),
                  label: Text('Cart'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Account'),
                ),
              ],
            ),

          // 4. The main page view takes up the remaining space
          Expanded(child: _pages.elementAt(_selectedIndex)),
        ],
      ),

      // 5. Bottom Navigation for Small Screens (e.g., Mobile)
      bottomNavigationBar: isLargeScreen
          ? null // Hide bottom bar on large screens
          : BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category),
                  label: 'Category',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Account',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
            ),
    );
  }

  List<Widget> _buildTopBarActions() {
    return const [SizedBox(width: 16)];
  }

  Widget _buildLargeScreenHeader(BuildContext context) {
    // We place the Title and Search Bar side-by-side
    return Row(
      children: [
        // 1. App Title (Branding)
        const Padding(
          padding: EdgeInsets.only(right: 30.0),
          child: Text(
            'My E-commerce Shop',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),

        // 2. Search Input Field (Takes most of the available space)
        Expanded(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ), // Optional: cap the width
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search products or categories...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white, // Contrast the dark AppBar background
              ),
            ),
          ),
        ),
      ],
    );
  }
}
