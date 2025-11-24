import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/order/order_histroy.dart';
import 'package:flutter_app/screens/home/home_page.dart';
import 'package:flutter_app/screens/seller/confirm_delivery_page.dart';
import 'package:flutter_app/screens/seller/manage_listings_page.dart';
import 'package:flutter_app/screens/seller/pending_order.dart';
import 'package:flutter_app/screens/seller/processing_order_page.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/table/custom_table.dart';
import 'package:flutter_app/widgets/table/table_item_data.dart';
import 'package:http/http.dart' as http;

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  final TokenService _tokenService = TokenService();
  List<OrderHistory> _allPendingOrders = [];
  List<OrderHistory> _allProcessingOrders = [];
  List<OrderHistory> _allConfirmedOrders = [];
  bool _isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _fetchProcessingOrders();
    _fetchConfirmedOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken == null) {
        // Use `if (mounted)` to check if the widget is still in the tree before navigating
        if (mounted) {
          NavigationUtils.pushAndRemoveUntil(context, const HomePage());
          NavigationUtils.showAppSnackbar(
            context,
            "Authentication failed. Login again.",
          );
        }
        throw Exception("Authentication failed. Access token not found.");
      }
      final response = await http.get(
        Uri.parse('${AppConstants.kApiHostSpring}/api/seller/orders/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        setState(() {
          _allPendingOrders = jsonList
              .map((json) => OrderHistory.fromJson(json))
              .toList();
        });
      } else {
        // Handle non-200 status codes gracefully
        if (mounted) {}
      }
    } catch (e) {
      if (mounted) {}
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchProcessingOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken == null) {
        // Use `if (mounted)` to check if the widget is still in the tree before navigating
        if (mounted) {
          NavigationUtils.pushAndRemoveUntil(context, const HomePage());
          NavigationUtils.showAppSnackbar(
            context,
            "Authentication failed. Login again.",
          );
        }
        throw Exception("Authentication failed. Access token not found.");
      }
      final response = await http.get(
        Uri.parse(
          '${AppConstants.kApiHostSpring}/api/seller/orders/processing',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        setState(() {
          _allProcessingOrders = jsonList
              .map((json) => OrderHistory.fromJson(json))
              .toList();
        });
      } else {
        // Handle non-200 status codes gracefully
        if (mounted) {}
      }
    } catch (e) {
      if (mounted) {}
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchConfirmedOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken == null) {
        // Use `if (mounted)` to check if the widget is still in the tree before navigating
        if (mounted) {
          NavigationUtils.pushAndRemoveUntil(context, const HomePage());
          NavigationUtils.showAppSnackbar(
            context,
            "Authentication failed. Login again.",
          );
        }
        throw Exception("Authentication failed. Access token not found.");
      }
      final response = await http.get(
        Uri.parse('${AppConstants.kApiHostSpring}/api/seller/orders/confirmed'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        setState(() {
          _allConfirmedOrders = jsonList
              .map((json) => OrderHistory.fromJson(json))
              .toList();
        });
      } else {
        // Handle non-200 status codes gracefully
        if (mounted) {}
      }
    } catch (e) {
      if (mounted) {}
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isWebLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.kTabletBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = _isWebLayout(context);
    // These variables are not currently used in the final UI but kept for reference
    // int pendingOrders = 10;
    // int processingOrders = 20;
    // int confirmedDelivery = 20;

    // menuItems are now defined using the potentially updated _allOrders.length
    final List<TableItemData> menuItems = [
      TableItemData(
        leadingWidget: const Icon(
          Icons.shopping_bag_outlined,
          color: AppColors.primaryColor,
        ),
        primaryText: 'Pending Orders',
        // Use the length of _allOrders fetched in initState/fetchOrders
        badgeCount: _allPendingOrders.length,
        onTap: (context) {
          NavigationUtils.push(context, const PendingOrder());
        },
      ),
      TableItemData(
        leadingWidget: const Icon(
          Icons.delivery_dining,
          color: AppColors.primaryColor,
        ),
        primaryText: 'Processing Orders',
        // secondaryText: 'Expect to Delevered: 25/Oct/2025',
        badgeCount: _allProcessingOrders.length,
        badgeColorOverride: AppColors.primaryColor,

        onTap: (context) {
          NavigationUtils.push(context, const ProcessingOrderPage());
        },
      ),
      TableItemData(
        leadingWidget: const Icon(Icons.check_circle, color: AppColors.success),
        primaryText: 'Confirmed Delivery',
        // secondaryText: _allConfirmedOrders[0].orderDate.toString(),
        badgeCount: _allConfirmedOrders.length,
        badgeColorOverride: AppColors.success,
        // rightText: "View Details",
        onTap: (context) {
          NavigationUtils.push(context, const ConfirmDeliveryPage());
        },
      ),
      TableItemData(
        leadingWidget: const Icon(Icons.manage_search, color: AppColors.info),
        primaryText: 'Manage Listing',
        rightText: "View Details",

        onTap: (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const ManageListingsPage()),
          );
        },
      ),
      TableItemData(
        leadingWidget: const Icon(Icons.money, color: AppColors.secondaryLight),
        primaryText: 'Payout Settings',
        secondaryText: 'Lifetime Earnings: 1000\$',
        rightText: '200\$',
        onTap: null,
      ),
      TableItemData(
        leadingWidget: const Icon(
          Icons.phone_in_talk,
          color: AppColors.textSecondary,
        ),
        primaryText: 'Contact Support',
        secondaryText: '24/7 Chat Available',
        rightText: 'Help',
        onTap: null,
      ),
    ];

    return Scaffold(
      appBar: const CustomAppBar(
        titleText: "Seller Dashboard",
        automaticallyImplyLeading: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Show loading indicator
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.kMaxContentWidth,
                  ),
                  child: Column(
                    children: [
                      CustomTable(
                        title: "Menu",
                        items: menuItems,
                        titleTextColor: AppColors.primaryColor,
                        titleBackgroundColor: AppColors.dividerColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
