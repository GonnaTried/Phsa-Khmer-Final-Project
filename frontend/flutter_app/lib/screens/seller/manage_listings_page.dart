import 'package:flutter/material.dart';
import 'package:flutter_app/models/product/listing_item_model.dart';
import 'package:flutter_app/screens/home/home_page.dart';
import 'package:flutter_app/screens/seller/crud_listing/create_new_listing.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/table/custom_table.dart';
import 'package:flutter_app/widgets/table/table_item_data.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:http/http.dart' as http; // Required for API calls
import 'dart:convert'; // Required for JSON decoding

enum ButtonSelection { activeItems, archivedItems, banItems, reviewingItems }

class ManageListingsPage extends StatefulWidget {
  const ManageListingsPage({super.key});
  @override
  State<ManageListingsPage> createState() => _ManageListingsPageState();
}

bool _isWebLayout(BuildContext context) {
  return MediaQuery.of(context).size.width >= AppConstants.kTabletBreakpoint;
}

class _ManageListingsPageState extends State<ManageListingsPage> {
  final _tokenService = TokenService();
  // State variables for data
  List<ListingModel> _allListings = [];
  bool _isLoading = true;
  String? _errorMessage;

  String tableTitle = "Active Listing Items";
  Color titleBackgroundColor = AppColors.success;
  List<TableItemData> tableItems = [];

  // Data categorized by status
  List<TableItemData> activeItems = [];
  List<TableItemData> archivedItems = [];
  List<TableItemData> banItems = [];
  List<TableItemData> reviewingItems = [];

  ButtonSelection? _selectedButton;
  final Color _selectionHighlightColor = AppColors.surfaceColor;

  @override
  void initState() {
    super.initState();
    _fetchAndProcessListings();
    _selectedButton = ButtonSelection.activeItems;
  }

  // --- API SERVICE IMPLEMENTATION ---

  String _getImageUrl(String filename) {
    if (filename.isEmpty) return 'https://via.placeholder.com/60';
    return '${AppConstants.kApiHostSpring}/api/public/files/$filename';
  }

  Future<void> _fetchAndProcessListings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final accessToken = await _tokenService.getAccessToken();

    if (accessToken == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Authentication failed. Access token not found.";
      });
      if (!mounted) {
        return;
      }
      NavigationUtils.showAppSnackbar(
        context,
        "Authentication failed. Login again.",
      );
      NavigationUtils.pushAndRemoveUntil(context, const HomePage());
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.kApiHostSpring}/api/seller/listings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        _allListings = jsonList
            .map((json) => ListingModel.fromJson(json))
            .toList();
        _processListingsToTableData();
      } else {
        _errorMessage =
            "Failed to load listings. Status: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    } finally {
      setState(() {
        _isLoading = false;
        // Select the default button after data is loaded
        _selectButton(ButtonSelection.activeItems);
      });
    }
  }

  String _setStatusText(String status) {
    return status.toUpperCase();
  }

  // --- DATA TRANSFORMATION ---

  void _processListingsToTableData() {
    // Clear previous lists
    activeItems.clear();
    archivedItems.clear();
    banItems.clear();
    reviewingItems.clear();

    for (var listing in _allListings) {
      final statusName = listing.status.name.toLowerCase();
      Color statusColor;

      String statusText = _setStatusText(listing.status.name);

      if (statusName == 'active') {
        statusColor = AppColors.success;
      } else if (statusName == 'archived') {
        statusColor = AppColors.primaryColor;
      } else if (statusName == 'banned') {
        statusColor = AppColors.danger;
      } else if (statusName == 'reviewing') {
        statusColor = AppColors.secondaryDark;
      } else {
        statusColor = AppColors.textPrimary;
      }

      final itemData = TableItemData(
        // Use the image widget helper for the listing's main image
        leadingWidget: _buildLeadingImage(listing.image),

        primaryText: "[ ID: ${listing.id} ] Title: ${listing.title}",

        // Example secondary text using item count
        secondaryText: "${listing.items.length} unique items included",

        rightText: statusText,

        rightTextColor: statusColor,

        onTap: (context) {},
      );

      // Categorize and add to the correct list
      if (statusName == 'active') {
        activeItems.add(itemData);
      } else if (statusName == 'archived') {
        archivedItems.add(itemData);
      } else if (statusName == 'banned') {
        banItems.add(itemData);
      } else if (statusName == 'reviewing') {
        reviewingItems.add(itemData);
      } else {
        activeItems.add(itemData);
      }
    }
  }

  // --- UI LOGIC ---

  Color _getBorderButtonColor(ButtonSelection currentButton, Color baseColor) {
    if (_selectedButton == currentButton) {
      return _selectionHighlightColor;
    }
    return baseColor;
  }

  void _selectButton(ButtonSelection button) {
    setState(() {
      _selectedButton = button; // Always select the button when tapped
    });
    switch (_selectedButton) {
      case ButtonSelection.activeItems:
        tableTitle = "Active Listing Items";
        titleBackgroundColor = AppColors.success;
        tableItems = activeItems;
        break;
      case ButtonSelection.archivedItems:
        tableTitle = "Archived List Items";
        titleBackgroundColor = AppColors.primaryColor;
        tableItems = archivedItems;
        break;
      case ButtonSelection.reviewingItems:
        tableTitle = "Reviewing Items";
        titleBackgroundColor = AppColors.secondaryDark;
        tableItems = reviewingItems;
        break;
      case ButtonSelection.banItems:
        tableTitle = "Banned List Items";
        titleBackgroundColor = AppColors.danger;
        tableItems = banItems;
        break;
      default:
        // Should not happen if initState is correct, but safe fallback:
        tableTitle = "Active Listing Items";
        titleBackgroundColor = AppColors.success;
        tableItems = activeItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    // bool isWeb = _isWebLayout(context); // Unused variable removed

    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      content = Center(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: AppConstants.kMaxContentWidth,
            ),
            padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
            child: Text(
              "There Are No Lsitings Yet",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppConstants.kTitleTextSize,
              ),
            ),
          ),
        ),
      );
    } else {
      content = Column(
        children: [
          Row(
            children: [
              _buildFilterButton(
                ButtonSelection.activeItems,
                Icons.checklist,
                AppColors.success,
              ),
              AppSpaces.smallHorizontal,
              _buildFilterButton(
                ButtonSelection.archivedItems,
                Icons.archive,
                AppColors.primaryColor,
              ),
              AppSpaces.smallHorizontal,
              _buildFilterButton(
                ButtonSelection.reviewingItems,
                Icons.reviews,
                AppColors.secondaryDark,
              ),
              AppSpaces.smallHorizontal,
              _buildFilterButton(
                ButtonSelection.banItems,
                Icons.dangerous,
                AppColors.danger,
              ),
            ],
          ),
          AppSpaces.smallVertical,
          CustomTable(
            title: tableTitle,
            items: tableItems,
            titleBackgroundColor: titleBackgroundColor,
            titleTextColor: AppColors.surfaceColor,
            fixedRows: 10,
          ),
        ],
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Manage Listings",
        automaticallyImplyLeading: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.kMaxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: CustomButton(
                    text: "Create New Listing",
                    icon1: const Icon(Icons.add),
                    onPressed: () async {
                      final result = await NavigationUtils.push(
                        context,
                        const CreateNewListing(),
                      );
                      if (mounted) {
                        _fetchAndProcessListings();
                      }
                    },
                  ),
                ),
                AppSpaces.largeDivider,
                // Display the dynamic content (Loading/Error/Data)
                content,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    ButtonSelection button,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            width: 2.0,
            color: _getBorderButtonColor(button, AppColors.transparent),
          ),
        ),
        child: IconButton(
          icon: Icon(icon, size: 35),
          color: AppColors.surfaceColor,
          onPressed: () {
            _selectButton(button);
          },
        ),
      ),
    );
  }

  Widget _buildLeadingImage(String filename) {
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
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
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
}
