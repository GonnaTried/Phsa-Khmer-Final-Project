import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/order/order_histroy.dart';
import 'package:flutter_app/screens/auth/login_page.dart';
import 'package:flutter_app/screens/home/home_page.dart';
import 'package:flutter_app/screens/orders/view_order_detail.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/build_image.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/table/custom_table.dart';
import 'package:flutter_app/widgets/table/table_item_data.dart';
import 'package:http/http.dart' as http;

class ConfirmDeliveryPage extends StatefulWidget {
  const ConfirmDeliveryPage({super.key});

  @override
  State<ConfirmDeliveryPage> createState() => _ConfirmDeliveryPageState();
}

class _ConfirmDeliveryPageState extends State<ConfirmDeliveryPage> {
  TokenService _tokenService = TokenService();

  List<OrderHistory> _allOrders = [];
  List<TableItemData> _orders = [];

  Future<void> _fetchOrders() async {
    try {
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken == null) {
        if (!mounted) return;
        NavigationUtils.pushAndRemoveUntil(context, HomePage());
        NavigationUtils.showAppSnackbar(
          context,
          "Authentication failed. Login again.",
        );
        throw Exception("Authentication failed. Access token not found.");
      }
      final response = await http.get(
        Uri.parse(
          '${AppConstants.kApiHostSpring}/api/seller/orders/delivered',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List jsonList = jsonDecode(response.body);
        setState(() {
          _allOrders = jsonList
              .map((json) => OrderHistory.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      if (!mounted) return;
      NavigationUtils.showAppSnackbar(context, "An error occurred: $e");
    } finally {
      if (mounted) {
        _processOrdersToTables();
      }
    }
  }

  void _processOrdersToTables() {
    _orders.clear();
    for (var order in _allOrders) {
      final orderStatus = order.status.toLowerCase();
      Icon orderIcon;
      if (orderStatus == 'pending_payment') {
        orderIcon = const Icon(Icons.pending, color: AppColors.surfaceColor);
      } else if (orderStatus == 'cancelled') {
        orderIcon = const Icon(Icons.cancel, color: AppColors.danger);
      } else if (orderStatus == 'processing') {
        orderIcon = const Icon(
          Icons.hourglass_bottom,
          color: AppColors.primaryColor,
        );
      } else if (orderStatus == 'delivering') {
        orderIcon = const Icon(
          Icons.delivery_dining,
          color: AppColors.primaryColor,
        );
      } else if (orderStatus == 'delivered') {
        orderIcon = const Icon(Icons.check, color: AppColors.success);
      } else if (orderStatus == 'paid') {
        orderIcon = const Icon(Icons.credit_card, color: AppColors.success);
      } else {
        orderIcon = const Icon(Icons.pending, color: AppColors.surfaceColor);
      }

      String primaryText1;
      Color primaryColor;
      // generate switch for order status
      switch (orderStatus) {
        case 'paid':
          primaryText1 = "Paid";
          primaryColor = AppColors.primaryColor;
          break;
        case 'delivering':
          primaryText1 = "Delivering";
          primaryColor = AppColors.primaryColor;
          break;
        case 'delivered':
          primaryText1 = "Delivered";
          primaryColor = AppColors.success;
          break;
        case 'processing':
          primaryText1 = "Processing";
          primaryColor = AppColors.primaryColor;
          break;
        case 'cancelled':
          primaryText1 = "Cancelled";
          primaryColor = AppColors.danger;
          break;
        default:
          primaryText1 = "Paid";
          primaryColor = AppColors.primaryColor;
          break;
      }

      final itemData = TableItemData(
        leadingWidget: buildImage(order.items[0].item.imageUrl),
        primaryText: order.items[0].item.name + " - [ $primaryText1 ]",
        primaryTextColor: primaryColor,
        secondaryText: order.orderDate.toString(),
        rightText: order.totalAmount.toString() + "\$",
        badgeColorOverride: AppColors.primaryLight,
        onTap: (context) async {
          // final result = await NavigationUtils.push(
          //   context,
          //   ViewOrderDetail(order: order, isSeller: true),
          // );

          // if (result == true) {
          //   await _fetchOrders();
          // }
        },
      );

      if (orderStatus == 'pending_payment' || orderStatus == 'pending') {
        // _penddingOrders.add(itemData);
      } else {
        _orders.add(itemData);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Confirmed Order",
        automaticallyImplyLeading: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: AppConstants.kMaxContentWidth,
            ),
            padding: EdgeInsets.all(AppConstants.kDefaultPadding),
            child: CustomTable(
              title: "Deliver Orders",
              items: _orders,
              titleBackgroundColor: AppColors.primaryColor,
              titleTextColor: AppColors.surfaceColor,
            ),
          ),
        ),
      ),
    );
  }
}
