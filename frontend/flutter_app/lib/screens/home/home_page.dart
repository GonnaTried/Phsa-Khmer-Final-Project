import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/public/get_public_listing.dart';
import 'package:flutter_app/models/paginated_listing_response.dart';
import 'package:flutter_app/models/seller/product.dart';
import 'package:flutter_app/providers/cart_provider.dart';
import 'package:flutter_app/screens/view_listing/view_listing_detail.dart';
import 'package:http/http.dart' as http;

// Your own imports
import 'package:flutter_app/api/public/get_public_image.dart';
import 'package:flutter_app/screens/profile/profile_page.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_bottom_nav.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/custom_input_box.dart';
import 'package:flutter_app/widgets/product/custom_product_card.dart';
import 'package:flutter_app/widgets/product/custom_product_grid.dart';
import 'package:provider/provider.dart';

// Mock data for categories (can be replaced with an API call later)
final List<CategoryModel> _categories = [
  CategoryModel("Women's Cloth", 200),
  CategoryModel("Men's Cloth", 150),
  CategoryModel("Shoes", 100),
  CategoryModel("Accessories", 50),
  CategoryModel("Electronics", 80),
  CategoryModel("Books", 120),
  CategoryModel("Home Decor", 70),
];

class CategoryModel {
  String name;
  int count;
  CategoryModel(this.name, this.count);
}

// HomePage Widget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

bool _isWebLayout(BuildContext context) {
  return MediaQuery.of(context).size.width >= AppConstants.kTabletBreakpoint;
}

class _HomePageState extends State<HomePage> {
  // This Future will hold the state of our API call
  late final List<Widget> _screens;
  int _currentIndex = 0;
  final List<Product> _products = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isLoadMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  String? _errorMessage;

  final GetPublicListing _getPublicListing = GetPublicListing();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _scrollController.addListener(_onScroll);
    _updateCartCount();
    // _screens = [
    //   _buildProductContent(), // Home content with FutureBuilder
    //   _sidebar(), // Sidebar content
    //   const Center(child: Text('Search Screen')),
    //   const Center(child: Text('Wishlist Screen')),
    //   const ProfilePage(),
    // ];
  }

  // final List<Widget> _bodyScreens = [
  //   const HomePage(),
  //   const Center(child: Text('Category Screen')),
  //   const Center(child: Text('Search Screen')),
  //   const Center(child: Text('Wishlist Screen')),
  //   // Note: The Profile screen is handled separately for full-page navigation
  //   const ProfilePage(),
  // ];

  void _onItemTapped(int index) {
    if (index == 4) {
      // Check if the tapped index is the 'Profile' index
      // If it's the profile index, push a new route
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) =>
                  const ProfilePage(), // Navigate to the separate page
            ),
          )
          .then((_) {
            // Optional: Reset the index after returning from the ProfilePage
            // If you don't reset, the 'Profile' icon will remain highlighted
            // until another item is tapped.
            setState(() {
              _currentIndex = _currentIndex; // Keeps the current visual index
            });
          });
    } else {
      // For all other indices, just update the state to switch the body content
      setState(() {
        _currentIndex = index;
      });
    }
  }

  int _cartCount = 0;
  void _updateCartCount() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.fetchCart();
      if (mounted) {
        setState(() {
          _cartCount = _cartCount;
        });
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // If we're not at the bottom, do nothing
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200)
      return;

    // If we are at the bottom, fetch more products
    _fetchProducts();
  }

  // --- Data Fetching Logic ---
  Future<void> _fetchProducts() async {
    if (_isLoadMore || !_hasMore) return;
    setState(() {
      _isLoadMore = true;
      _errorMessage = null;
    });

    try {
      final PaginatedListingResponse response = await _getPublicListing
          .fetchPaginatedListings(page: _currentPage, size: _pageSize);

      if (mounted) {
        setState(() {
          _products.addAll(response.listings);
          _hasMore = !response.isLastPage;
          _currentPage++;
          _isLoading = false;
          _isLoadMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadMore = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // int _selectedIndex = 0;
  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    bool isWeb = _isWebLayout(context);

    if (isWeb) {
      return _buildWebLayout();
    } else {
      return _buildWebLayout();
    }
  }

  // --- Layout Builders ---
  Widget _buildWebLayout() {
    final isWeb = _isWebLayout(context);
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Phsa Khmer',
        automaticallyImplyLeading: false,
        actions: [
          // CartActionButton(itemCount: _cartCount),
          IconButton(onPressed: (){}, icon: Icon(Icons.search, color: AppColors.textPrimary,)),
          IconButton(
            onPressed: () => NavigationUtils.push(context, const ProfilePage()),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            isWeb ? _searchField() : Container(),
            AppSpaces.smallVertical,
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: isWeb ? 250 : 0, // Slightly wider for web
                    child: isWeb ? _sidebar() : null,
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    // The main content area now uses the FutureBuilder
                    child: _buildProductContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: isWeb
      //     ? null
      //     : CustomBottomNav(currentIndex: _currentIndex, onTap: _onItemTapped),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Phsa Khmer',
        automaticallyImplyLeading: false,
        actions: [CartActionButton()],
      ),
      // body: _screens[_selectedIndex],
      // bottomNavigationBar: CustomBottomNav(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }

  // --- Reusable UI Component Widgets ---

  /// This widget handles the API call state and displays the product grid.
  /// It is now the single source for displaying products on both web and mobile.
  Widget _buildProductContent() {
    if (_isLoading && _products.isEmpty) {
      // Initial load
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _products.isEmpty) {
      // ... error handling ...
    }

    if (_products.isEmpty) {
      return const Center(child: Text('No products found.'));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    // Helper function moved from CustomProductGrid to calculate cross axis count
    int _calculateCrossAxisCount(double screenWidth, double minItemWidth) {
      if (screenWidth < AppConstants.kTabletBreakpoint) {
        return (screenWidth / minItemWidth).floor();
      } else if (screenWidth < AppConstants.kMaxContentWidth) {
        return (screenWidth / (minItemWidth + 50)).floor();
      } else {
        return (AppConstants.kMaxContentWidth / (minItemWidth + 70)).floor();
      }
    }

    // Determine the cross axis count dynamically
    final crossAxisCount = _calculateCrossAxisCount(screenWidth, 180.0);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = _products[index];
              return CustomProductCard(
                product: product,
                onTap: () {
                  NavigationUtils.push(
                    context,
                    ViewListingDetail(listingId: product.id),
                  );
                },
              );
            }, childCount: _products.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.75,
              crossAxisSpacing: AppConstants.kSpacingMedium,
              mainAxisSpacing: AppConstants.kSpacingMedium,
            ),
          ),
        ),

        // 2. The pagination loading indicator (if hasMore)
        if (_hasMore)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sidebar() {
    return Container(
      color: AppColors.surfaceColor,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.kSpacingSmall),
        children: [
          const Padding(
            padding: EdgeInsets.all(AppConstants.kDefaultPadding / 2),
            child: Text(
              "Categories",
              style: TextStyle(
                fontSize: AppConstants.kTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._categories.map(
            (category) => ListTile(
              title: Text(category.name),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                print("Selected category: ${category.name}");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
  // 1. Define the path to your asset
  const String backgroundImagePath = 'assets/images/bg.jpg';

  return Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage(backgroundImagePath),
        fit: BoxFit.cover,
      ),
    ),
    
    child: Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.kMaxContentWidth,
        ),
        color: Colors.white.withOpacity(0.95), 
        padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
        child: const CustomInputBox(
          placeholder: "Search for products, brands, and more",
          suffixIcon: Icon(Icons.search),
        ),
      ),
    ),
  );
}

  /// This method is now only responsible for the UI structure, not data fetching.
  // Widget _homeContent(List<Product> products) {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
  //     child: Center(
  //       child: Container(
  //         constraints: const BoxConstraints(
  //           maxWidth: AppConstants.kMaxContentWidth,
  //         ),
  //         child: CustomProductGrid(products: products),
  //       ),
  //     ),
  //   );
  // }
}
