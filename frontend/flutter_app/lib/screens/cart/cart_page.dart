import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/private/cart_api_service.dart';
import 'package:flutter_app/models/payment/checkout_response.dart';
import 'package:flutter_app/models/user_profile.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/screens/payment/payment_flow_page.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/cart_provider.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _handleCheckout(BuildContext context) async {
    final cartApiService = Provider.of<CartApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUserId;
    final String clientType = kIsWeb ? 'web' : 'mobile';

    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to proceed to checkout.')),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found. Please relog.')),
      );
      return;
    }

    // Show loading indicator before API call
    final overlay = Overlay.of(context).context;
    // Simple way to show loading, you might use a dedicated package like loading_overlay
    showDialog(
      context: overlay,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Initiate Checkout API Call
      final CheckoutResponse response = await cartApiService
          .initiateStripeCheckout(userId, clientType: clientType);

      // Close loading indicator
      Navigator.of(overlay).pop();

      // 2. Launch Stripe Checkout URL
      final url = Uri.parse(response.checkoutUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode
              .externalApplication, // Use external application for mobile/web
        );
      } else {
        throw 'Could not launch $url';
      }

      // Note: After launching the URL, the user is redirected to Stripe.
      // After payment, Stripe redirects to your Spring Boot endpoint,
      // which redirects using the Deep Link (`st25app://...`),
      // which then launches your Flutter app and navigates to the Polling Page.
    } catch (e) {
      // Ensure the loading indicator is closed on error
      if (Navigator.canPop(overlay)) Navigator.of(overlay).pop();

      print('Checkout Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start checkout: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        titleText: "My Cart",
        automaticallyImplyLeading: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading && cartProvider.cart == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cartProvider.errorMessage != null) {
            return Center(child: Text("Error: ${cartProvider.errorMessage}"));
          }
          if (cartProvider.cart == null || cartProvider.cart!.items.isEmpty) {
            return const Center(child: Text("Your cart is empty."));
          }

          final cart = cartProvider.cart!;
          final double cartTotal = cart.items.fold(
            0.0,
            (sum, current) => sum + (current.item.price * current.quantity),
          );

          // Use a LayoutBuilder to constrain the width centered,
          // and wrap the content in SingleChildScrollView for overall scrollability.
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: AppConstants.kMaxContentWidth,
                    ),
                    padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListView.builder(
                          physics:
                              const NeverScrollableScrollPhysics(), // Managed by SingleChildScrollView
                          shrinkWrap:
                              true, // Crucial when ListView is inside Column/SingleChildScrollView
                          itemCount: cart.items.length,
                          itemBuilder: (context, index) {
                            final cartItem = cart.items[index];
                            return ListTile(
                              contentPadding:
                                  EdgeInsets.zero, // Adjust padding as needed
                              leading: Image.network(
                                cartItem.item.imageUrl,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(cartItem.item.name),
                              subtitle: Text(
                                '\$${cartItem.item.price.toStringAsFixed(2)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: cartItem.quantity > 1
                                        ? () => cartProvider.updateItem(
                                            cartItem.item.id,
                                            cartItem.quantity - 1,
                                          )
                                        : () => cartProvider.removeItem(
                                            cartItem.item.id,
                                          ),
                                  ),
                                  Text('${cartItem.quantity}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => cartProvider.updateItem(
                                      cartItem.item.id,
                                      cartItem.quantity + 1,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const Divider(height: 30),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${cartTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppConstants.kDefaultPadding),

                        // Checkout Button
                        CustomButton(
                          text: "Check out",
                          onPressed: () {
                            NavigationUtils.push(context, PaymentFlowPage());
                          },
                          icon1: Icon(
                            Icons.shopping_cart_outlined,
                            color: AppColors.primaryColor,
                          ),
                          icon2: Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.primaryColor,
                          ),
                        ),

                        // Placeholder for checkout logic (
                        // Handle checkout logic here)
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
