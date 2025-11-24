import 'package:flutter/material.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/cart_provider.dart';
import 'package:flutter_app/screens/address/address_page.dart';
import 'package:flutter_app/screens/auth/login_page.dart';
import 'package:flutter_app/screens/cart/cart_page.dart';
import 'package:flutter_app/screens/home/home_page.dart';
import 'package:flutter_app/screens/orders/view_orders.dart';
import 'package:flutter_app/screens/profile/profile_detail.dart';
import 'package:flutter_app/screens/seller/seller_dashboard_page.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';

import '../../models/user_profile.dart';
import '../../utils/app_colors.dart';

// --- Mock Data ---
// final UserProfile mockUser = UserProfile(
//   userId: 1,
//   username: 'Sok',
//   phoneNumber: '+855 0123456789',
//   telegramUsername: 't.me/@sok',
//   telegramLinked: true,
// );

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isWebLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.kTabletBreakpoint;
  }

  final TokenService _tokenService = TokenService();
  bool _isLoading = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    Future.microtask(() {
      _updateCartCount();
    });
  }

  void _checkLoginStatus() async {
    final loggedIn = await _tokenService.isUserLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isLoading = false;
      });
    }
  }

  int _cartCount = 0;
  void _updateCartCount() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.fetchCart();
    setState(() {
      _cartCount = cartProvider.cart?.items.length ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      return const Center(child: LoginPage());
    }

    final user_profile = authProvider.userProfile;

    if (user_profile == null) {
      return const Center(child: CircularProgressIndicator());
    }
    bool isWeb = _isWebLayout(context);
    if (_isLoggedIn) {
      return Scaffold(
        appBar: CustomAppBar(
          titleText: "Profile",
          automaticallyImplyLeading: true,
        ),
        body: _profileDashbaord(user_profile),
      );
    } else {
      return Scaffold(
        appBar: CustomAppBar(
          titleText: "Profile",
          automaticallyImplyLeading: true,
        ),
        body: Center(child: LoginPage()),
      );
    }
  }

  Widget _buildBasicUserProfile(
    BuildContext context,
    UserProfile user_profile,
  ) {
    bool isWeb = _isWebLayout(context);

    return InkWell(
      onTap: () {},
      child: Container(
        constraints: isWeb
            ? const BoxConstraints(
                minWidth: 600,
                maxWidth: AppConstants.kMaxContentWidth,
              )
            : const BoxConstraints(
                minWidth: 400,
                maxWidth: AppConstants.kMaxContentWidth,
              ),
        padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user_profile.lastName! + " " + user_profile.firstName!,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.left,
            ),
            AppSpaces.smallVertical,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Phone Number: ${user_profile.phoneNumber}"),
                Text("Telegram Username: ${user_profile.telegramUsername}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileDashbaord(UserProfile user_profile) {
    final authProvider = context.read<AuthProvider>();
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.kMaxContentWidth,
          ),
          padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
          child: Column(
            children: [
              // _buildBasicUserProfile(context),
              CustomButton(
                text: user_profile.lastName! + " " + user_profile.firstName!,
                textAlignment: MainAxisAlignment.start,
                textColor: AppColors.primaryColor,
                textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                onPressed: () {
                  NavigationUtils.push(context, ProfileDetail());
                },
                buttonColor: AppColors.transparent,
                icon1: Icon(Icons.person_4),
                icon1Position: IconPosition.left,
                icon1Color: AppColors.primaryColor,
                icon2: Icon(Icons.arrow_right),
                icon2Color: AppColors.primaryColor,
                width: double.infinity,
                height: 86,
                borderRadius: BorderRadius.circular(12.0),
                borderColor: AppColors.primaryColor,
              ),
              const Divider(),
              Container(
                constraints: const BoxConstraints(maxWidth: 600, minWidth: 400),
                child: Column(
                  children: [
                    AppSpaces.smallVertical,
                    CustomButton(
                      text: "Cart",
                      textAlignment: MainAxisAlignment.start,
                      onPressed: () {
                        NavigationUtils.push(context, CartPage());
                      },
                      buttonColor: AppColors.primaryColor,
                      icon1: Icon(Icons.shopping_cart),
                      icon1Position: IconPosition.left,
                      badgeCount: _cartCount,
                      width: double.infinity,
                      height: 56,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    AppSpaces.smallVertical,
                    CustomButton(
                      text: "Orders",
                      textAlignment: MainAxisAlignment.start,
                      onPressed: () {
                        NavigationUtils.push(context, ViewOrders());
                      },
                      buttonColor: AppColors.primaryColor,
                      icon1: Icon(Icons.shopping_bag),
                      icon1Position: IconPosition.left,
                      icon2: Icon(Icons.arrow_right),
                      icon2Position: IconPosition.right,
                      width: double.infinity,
                      height: 56,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    AppSpaces.smallVertical,
                    CustomButton(
                      text: "Shipping Address",
                      textAlignment: MainAxisAlignment.start,
                      onPressed: () {
                        NavigationUtils.push(context, AddressPage());
                      },
                      buttonColor: AppColors.primaryColor,
                      icon1: Icon(Icons.location_city),
                      icon1Position: IconPosition.left,
                      icon2: Icon(Icons.arrow_right),
                      icon2Position: IconPosition.right,
                      width: double.infinity,
                      height: 56,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    AppSpaces.smallVertical,
                    // CustomButton(
                    //   text: "Payment Methods",
                    //   textAlignment: MainAxisAlignment.start,
                    //   onPressed: () {},
                    //   buttonColor: AppColors.primaryColor,
                    //   icon1: Icon(Icons.credit_card),
                    //   icon1Position: IconPosition.left,
                    //   icon2: Icon(Icons.arrow_right),
                    //   icon2Position: IconPosition.right,
                    //   width: double.infinity,
                    //   height: 56,
                    //   borderRadius: BorderRadius.circular(12.0),
                    // ),
                    // AppSpaces.smallVertical,
                    // CustomButton(
                    //   text: "Wishlist",
                    //   textAlignment: MainAxisAlignment.start,
                    //   onPressed: () {},
                    //   buttonColor: AppColors.linkedColor,
                    //   icon1: Icon(Icons.favorite),
                    //   icon1Position: IconPosition.left,
                    //   icon2: Icon(Icons.arrow_right),
                    //   icon2Position: IconPosition.right,
                    //   width: double.infinity,
                    //   height: 56,
                    //   borderRadius: BorderRadius.circular(12.0),
                    // ),
                    // AppSpaces.smallVertical,
                    CustomButton(
                      text: "Seller Dashboard",
                      textAlignment: MainAxisAlignment.start,
                      onPressed: () {
                        NavigationUtils.push(context, SellerDashboardPage());
                      },
                      buttonColor: AppColors.secondaryDark,
                      icon1: Icon(Icons.sell),
                      icon1Position: IconPosition.left,
                      icon2: Icon(Icons.arrow_right),
                      icon2Position: IconPosition.right,
                      width: double.infinity,
                      height: 56,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    AppSpaces.smallVertical,
                    CustomButton(
                      text: "Log Out",
                      textAlignment: MainAxisAlignment.start,
                      onPressed: () {
                        _handleLogout(context, authProvider);
                      },
                      buttonColor: AppColors.danger,
                      icon1: Icon(Icons.exit_to_app),
                      icon1Position: IconPosition.left,
                      icon2: Icon(Icons.arrow_right),
                      icon2Position: IconPosition.right,
                      width: double.infinity,
                      height: 56,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _connectToTG() {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: AppConstants.kMaxContentWidth),
        padding: EdgeInsets.all(AppConstants.kDefaultPadding),
        child: CustomButton(
          text: "Connect to Telegram BOT",
          icon1: Icon(Icons.telegram),
          onPressed: () {},
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) async {
    await authProvider.logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
      (Route<dynamic> route) => false,
    );
  }
}
