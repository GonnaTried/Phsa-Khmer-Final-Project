// screens/view_listing_detail.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/api/public/get_public_listing.dart';
import 'package:flutter_app/models/seller/product.dart';
import 'package:flutter_app/providers/cart_provider.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class ViewListingDetail extends StatefulWidget {
  final String listingId;

  const ViewListingDetail({super.key, required this.listingId});

  @override
  State<ViewListingDetail> createState() => _ViewListingDetailState();
}

class _ViewListingDetailState extends State<ViewListingDetail> {
  final GetPublicListing _apiService = GetPublicListing();
  Product? _listing;
  bool _isLoading = true;
  String? _errorMessage;

  // --- STATE MANAGEMENT UPDATE ---
  // We now track all properties of the selected item, not just the image.
  String? _selectedImageUrl;
  String? _selectedItemName;
  double? _selectedItemPrice;
  int? _selectedItemId;

  @override
  void initState() {
    super.initState();
    _fetchListingDetails();
  }

  Future<void> _fetchListingDetails() async {
    try {
      final listingData = await _apiService.fetchListingById(widget.listingId);
      if (mounted) {
        setState(() {
          _listing = listingData;
          // Initially, show the main listing's details
          _selectedImageUrl = listingData.imageUrl;
          _selectedItemName = listingData.name;
          _selectedItemPrice = listingData.price;
          _isLoading = false;
          _selectedItemId = listingData.items.isNotEmpty
              ? listingData.items[0].id
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Listing Detail",
        automaticallyImplyLeading: true,
        actions: [CartActionButton()],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_listing == null) {
      return const Center(child: Text("Listing not found."));
    }

    // Main content layout
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.kMaxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainImage(),
              AppSpaces.mediumVertical,
              _buildThumbnailRow(),
              const Divider(height: 32),
              _buildDetailsAndCartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainImage() {
    if (_selectedImageUrl == null) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: AppColors.dividerColor,
          child: const Icon(Icons.image),
        ),
      );
    }
    return Image.network(
      _selectedImageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const AspectRatio(
          aspectRatio: 1,
          child: Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const AspectRatio(
          aspectRatio: 1,
          child: Icon(Icons.broken_image, size: 48),
        );
      },
    );
  }

  Widget _buildThumbnailRow() {
    // If there are no items in the listing, don't show the row at all.
    if (_listing == null || _listing!.items.isEmpty) {
      return const SizedBox.shrink(); // Return an empty, zero-sized widget
    }

    // The list now only contains the items from the listing.
    final items = _listing!.items;

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.kDefaultPadding,
        ),
        itemCount: items.length, // Use the length of the items list
        itemBuilder: (context, index) {
          final item = items[index]; // Get the full ItemModel object
          final imageUrl = item.imageUrl;
          final isSelected = imageUrl == _selectedImageUrl;

          return GestureDetector(
            onTap: () {
              // The logic is now much simpler. The tapped index directly
              // corresponds to the item in the list.
              setState(() {
                _selectedImageUrl = item.imageUrl;
                _selectedItemName = item.name;
                _selectedItemPrice = item.price;
                _selectedItemId = item.id;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AppConstants.kSmallBorderRadius,
                ),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppConstants.kSmallBorderRadius / 1.5,
                ),
                child: Image.network(imageUrl!, fit: BoxFit.cover),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsAndCartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.kDefaultPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedItemName ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpaces.smallVertical,
                Text(
                  '\$${(_selectedItemPrice ?? 0.0).toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          AppSpaces.mediumHorizontal,
          CustomButton(
            text: "Add to Cart $_selectedItemPrice\$",
            onPressed: () async {
              if (_selectedItemId == null) {
                NavigationUtils.showErrorMessage(
                  context,
                  "Please select an item variation.",
                );
                return;
              }

              final cartProvider = Provider.of<CartProvider>(
                context,
                listen: false,
              );
              await cartProvider.addItem(_selectedItemId!, 1);

              if (cartProvider.errorMessage == null) {
                NavigationUtils.showSuccessMessage(
                  context,
                  "'$_selectedItemName' added to cart!",
                );
              } else {
                NavigationUtils.showErrorMessage(
                  context,
                  "Failed to add item: ${cartProvider.errorMessage}",
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
