import 'package:flutter/material.dart';
import 'package:flutter_app/screens/seller/seller_dashboard_page.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_button.dart';

import '../../models/user.dart';
import '../../utils/app_colors.dart';

// --- Mock Data ---
final UserProfile mockUser = UserProfile(
  userId: 1,
  username: 'Sok',
  phoneNumber: '+855 0123456789',
  telegramUsername: 't.me/@sok',
  telegramLinked: true,
);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  bool _isWebLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.kTabletBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = _isWebLayout(context);
    return Scaffold(
      appBar: isWeb
          ? CustomAppBar(titleText: "Profile", automaticallyImplyLeading: true)
          : null,

      body: SingleChildScrollView(
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
                  text: mockUser.username,
                  textAlignment: MainAxisAlignment.start,
                  textColor: AppColors.primaryColor,
                  textStyle: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: () {},
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
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                    minWidth: 400,
                  ),
                  child: Column(
                    children: [
                      // CustomButton(
                      //   text: "Sing in",
                      //   textAlignment: MainAxisAlignment.start,
                      //   onPressed: () {},
                      //   buttonColor: AppColors.primaryColor,
                      //   icon1: Icon(Icons.login),
                      //   icon1Position: IconPosition.left,
                      //   icon2: Icon(Icons.arrow_right),
                      //   icon2Position: IconPosition.right,
                      //   width: double.infinity,
                      //   height: 56,
                      //   borderRadius: BorderRadius.circular(12.0),
                      // ),
                      AppSpaces.smallVertical,
                      CustomButton(
                        text: "Cart",
                        textAlignment: MainAxisAlignment.start,
                        onPressed: () {},
                        buttonColor: AppColors.primaryColor,
                        icon1: Icon(Icons.shopping_cart),
                        icon1Position: IconPosition.left,
                        badgeCount: 10,
                        width: double.infinity,
                        height: 56,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      AppSpaces.smallVertical,
                      CustomButton(
                        text: "Orders",
                        textAlignment: MainAxisAlignment.start,
                        onPressed: () {},
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
                        onPressed: () {},
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
                      CustomButton(
                        text: "Payment Methods",
                        textAlignment: MainAxisAlignment.start,
                        onPressed: () {},
                        buttonColor: AppColors.primaryColor,
                        icon1: Icon(Icons.credit_card),
                        icon1Position: IconPosition.left,
                        icon2: Icon(Icons.arrow_right),
                        icon2Position: IconPosition.right,
                        width: double.infinity,
                        height: 56,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      AppSpaces.smallVertical,
                      CustomButton(
                        text: "Wishlist",
                        textAlignment: MainAxisAlignment.start,
                        onPressed: () {},
                        buttonColor: AppColors.linkedColor,
                        icon1: Icon(Icons.favorite),
                        icon1Position: IconPosition.left,
                        icon2: Icon(Icons.arrow_right),
                        icon2Position: IconPosition.right,
                        width: double.infinity,
                        height: 56,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      AppSpaces.smallVertical,
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
                        onPressed: () {},
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
      ),
    );
  }

  Widget _buildBasicUserProfile(BuildContext context) {
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
              mockUser.username,
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
                Text("Phone Number: ${mockUser.phoneNumber}"),
                Text("Telegram Username: ${mockUser.telegramUsername}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
