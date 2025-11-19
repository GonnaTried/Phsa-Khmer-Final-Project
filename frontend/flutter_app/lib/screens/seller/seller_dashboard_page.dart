import 'package:flutter/material.dart';
import 'package:flutter_app/screens/seller/manage_listings_page.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/table/custom_table.dart';
import 'package:flutter_app/widgets/table/table_item_data.dart';

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});
  bool _isWebLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.kTabletBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = _isWebLayout(context);

    // menuItems
    final List<TableItemData> menuItems = [
      TableItemData(
        leadingWidget: const Icon(
          Icons.shopping_bag_outlined,
          color: AppColors.primaryColor,
        ),
        primaryText: 'Pending Orders',
        secondaryText: 'New Order: 13/Oct/2025',
        badgeCount: 10,
        onTap: null,
      ),
      TableItemData(
        leadingWidget: const Icon(
          Icons.delivery_dining,
          color: AppColors.primaryColor,
        ),
        primaryText: 'Processing Orders',
        secondaryText: 'Expect to Delevered: 25/Oct/2025',
        badgeCount: 20,
        onTap: null,
      ),
      TableItemData(
        leadingWidget: const Icon(
          Icons.pending_actions,
          color: AppColors.primaryColor,
        ),
        primaryText: 'Pending Confirm On Delivery',
        secondaryText: 'Auto Confirm on: 25/Oct/2025',
        badgeCount: 20,
        onTap: null,
      ),
      TableItemData(
        leadingWidget: const Icon(Icons.check_circle, color: AppColors.success),
        primaryText: 'Confirmed Delivery',
        secondaryText: 'Last Delivery: 25/Oct/2025',
        rightText: "View Details",
        onTap: null,
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
        leadingWidget: const Icon(
          Icons.drafts,
          color: AppColors.secondaryColor,
        ),
        primaryText: 'Draft Listing',
        secondaryText: 'Ready to publish',
        badgeCount: 15,
        onTap: null,
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
      appBar: CustomAppBar(
        titleText: "Seller Dashboard",
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(AppConstants.kDefaultPadding),
            constraints: BoxConstraints(
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
