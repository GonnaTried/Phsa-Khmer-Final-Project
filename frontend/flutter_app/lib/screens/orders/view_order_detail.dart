import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/order/order_histroy.dart';
import 'package:flutter_app/screens/home/home_page.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/build_image.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:flutter_app/widgets/table/custom_table.dart';
import 'package:flutter_app/widgets/table/table_item_data.dart';
import 'package:http/http.dart' as http;

class ViewOrderDetail extends StatelessWidget {
  final TokenService _tokenService = TokenService();
  final OrderHistory order;
  bool isSeller = true;

  ViewOrderDetail({super.key, required this.order, this.isSeller = false});

  List<TableItemData> _generateTableItems() {
    final List<TableItemData> items = [];

    for (var item in order.items) {
      final priceString = item.unitPrice.toStringAsFixed(2);
      final secondaryText = "${item.quantity} x \$$priceString";

      final itemData = TableItemData(
        leadingWidget: buildImage(item.item.imageUrl),
        primaryText: item.item.name,
        secondaryText: secondaryText,
      );

      items.add(itemData);
    }

    items.add(
      TableItemData(
        primaryText: 'Order Total',
        secondaryText: '\$${order.totalAmount.toStringAsFixed(2)}',
      ),
    );

    return items;
  }

  Future<void> _handleCancelOrder(BuildContext context) async {
    // Implement cancel order logic here
    // You might want to show a confirmation dialog first
    bool confirmCancel =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Cancellation"),
              content: const Text(
                "Are you sure you want to cancel this order?",
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes"),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmCancel) {
      try {
        final accessToken = await _tokenService.getAccessToken();
        if (accessToken == null) {
          NavigationUtils.pushAndRemoveUntil(context, HomePage());
          NavigationUtils.showAppSnackbar(
            context,
            "Authentication failed. Login again.",
          );
          throw Exception("Authentication failed. Access token not found.");
        }
        final response = await http.patch(
          Uri.parse(
            '${AppConstants.kApiHostSpring}/api/seller/orders/${order.id}/status',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({"newStatus": "CANCELLED"}),
        );
        if (response.statusCode == 200) {
          Navigator.of(context).pop(true);
          NavigationUtils.showAppSnackbar(
            context,
            "Order cancelled successfully.",
            isError: true,
          );
        }
      } catch (e) {
        NavigationUtils.showAppSnackbar(context, "An error occurred: $e");
      } finally {}
    }
  }

  Future<void> _handleConfirmOrder(BuildContext context) async {
    bool confirmCancel =
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Your Order?"),
              content: const Text(
                "Are you sure you want to Confirm this order?",
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Yes"),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmCancel) {
      try {
        final accessToken = await _tokenService.getAccessToken();
        if (accessToken == null) {
          NavigationUtils.pushAndRemoveUntil(context, HomePage());
          NavigationUtils.showAppSnackbar(
            context,
            "Authentication failed. Login again.",
          );
          throw Exception("Authentication failed. Access token not found.");
        }
        final response = await http.patch(
          Uri.parse(
            '${AppConstants.kApiHostSpring}/api/seller/orders/${order.id}/status',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({"newStatus": "PROCESSING"}),
        );
        if (response.statusCode == 200) {
          Navigator.of(context).pop(true);
          NavigationUtils.showAppSnackbar(
            context,
            "Order Confirmed successfully.",
          );
        }
      } catch (e) {
        NavigationUtils.showAppSnackbar(context, "An error occurred: $e");
      } finally {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TableItemData> tableItems = _generateTableItems();
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Order Detail",
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: AppConstants.kMaxContentWidth),
          padding: EdgeInsets.all(AppConstants.kDefaultPadding),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CustomTable(
                        title:
                            "Order Items (${order.items.length} unique items)",
                        items: tableItems,
                      ),
                      AppSpaces.largeDivider,
                    ],
                  ),
                ),
              ),
              isSeller
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                            text: "Cancel Order",
                            buttonColor: AppColors.danger,
                            textColor: AppColors.surfaceColor,
                            onPressed: () {
                              _handleCancelOrder(context);
                            },
                          ),
                          AppSpaces.mediumHorizontal,
                          CustomButton(
                            text: "Confirm Order",
                            buttonColor: AppColors.primaryColor,
                            textColor: AppColors.surfaceColor,
                            onPressed: () {
                              _handleConfirmOrder(context);
                            },
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
