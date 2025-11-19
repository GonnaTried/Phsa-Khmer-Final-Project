// lib/screens/address/address_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/models/address_model.dart';
import 'package:flutter_app/services/address_service.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/services/auth_service.dart'; // IMPORTANT: New Import
import 'package:flutter_app/utils/app_colors.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/screens/address/address_form.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
// import 'package:flutter_app/widgets/custom_app_bar.dart'; // Ensure CustomAppBar is defined or use AppBar

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  // Services
  late AddressService _addressService;
  late AuthService _authService;

  // Data State
  Future<List<ShippingAddress>>? _addressesFuture;
  int? _currentCustomerId;

  @override
  void initState() {
    super.initState();
    final tokenService = TokenService();
    _authService = AuthService(tokenService);
    _addressService = AddressService(tokenService, _authService);

    _initializeData();
  }

  Future<void> _initializeData() async {
    final profile = await _authService.fetchUserProfile();

    if (profile != null) {
      setState(() {
        _currentCustomerId = profile.userId;
        _addressesFuture = _addressService.fetchAddresses();
      });
    } else {
      // Handle the case where the user profile or ID cannot be loaded
      NavigationUtils.showErrorMessage(
        context,
        'Authentication required to manage addresses.',
      );
      // Optionally navigate away here
    }
  }

  void _refreshAddresses() {
    if (_currentCustomerId != null) {
      setState(() {
        _addressesFuture = _addressService.fetchAddresses();
      });
    }
  }

  // Handle CRUD operations
  Future<void> _handleSaveAddress(ShippingAddress address) async {
    ShippingAddress? result;
    // The customerId is automatically injected by AddressService
    if (address.id == null) {
      result = await _addressService.createAddress(address);
    } else {
      result = await _addressService.updateAddress(address);
    }

    if (result != null) {
      NavigationUtils.showSuccessMessage(
        context,
        address.id == null ? 'Address created!' : 'Address updated!',
      );
      _refreshAddresses();
    } else {
      NavigationUtils.showErrorMessage(
        context,
        'Failed to save address. Check logs or network.',
      );
    }
  }

  Future<void> _handleDeleteAddress(int addressId) async {
    final confirmed = await NavigationUtils.showConfirmationDialog(
      context,
      title: 'Confirm Deletion',
      content: 'Are you sure you want to delete this address?',
      confirmText: 'Delete',
      confirmButtonColor: AppColors.danger,
    );

    if (confirmed == true) {
      final success = await _addressService.deleteAddress(addressId);
      if (success) {
        NavigationUtils.showSuccessMessage(context, 'Address deleted.');
        _refreshAddresses();
      } else {
        NavigationUtils.showErrorMessage(context, 'Failed to delete address.');
      }
    }
  }

  Future<void> _handleSetDefaultAddress(int addressId) async {
    final success = await _addressService.setDefaultAddress(addressId);
    if (success) {
      NavigationUtils.showSuccessMessage(context, 'Default address set.');
      _refreshAddresses();
    } else {
      NavigationUtils.showErrorMessage(
        context,
        'Failed to set default address.',
      );
    }
  }

  void _showAddressForm({ShippingAddress? address}) {
    if (_currentCustomerId == null) {
      NavigationUtils.showErrorMessage(
        context,
        'Please wait, user data is loading.',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddressForm(
            initialAddress:
                address ?? ShippingAddress.empty(_currentCustomerId!),
            onSave: _handleSaveAddress,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine which AppBar to use (using standard AppBar as CustomAppBar source wasn't provided)
    final preferredAppBar = CustomAppBar(
      titleText: "Shipping Addresses",
      automaticallyImplyLeading: true,
    );

    if (_currentCustomerId == null || _addressesFuture == null) {
      return Scaffold(
        appBar: preferredAppBar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: preferredAppBar,
      body: FutureBuilder<List<ShippingAddress>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Provide feedback if the API call failed after getting the customer ID
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading addresses: ${snapshot.error}'),
                  TextButton(
                    onPressed: _refreshAddresses,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No addresses found. Add one below!'),
                  TextButton(
                    onPressed: _refreshAddresses,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          final addresses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return AddressCard(
                address: address,
                onEdit: () => _showAddressForm(address: address),
                onDelete: () => _handleDeleteAddress(address.id!),
                onSetDefault: () => _handleSetDefaultAddress(address.id!),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(),
        label: const Text('Add Address'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
      ),
    );
  }
}

// Widget for displaying a single address (copied from your input, using const)
class AddressCard extends StatelessWidget {
  final ShippingAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  address.recipientName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (address.isDefault)
                  Chip(
                    label: const Text('Default'),
                    backgroundColor: AppColors.success.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppColors.success),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const Divider(height: 10),
            // Removed Text(address.recipientPhone)

            // Display address fields using new names
            Text(
              '${address.streetAddress}, ${address.city}, ${address.province} ${address.zipCode}',
            ),
            Text(address.country),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: onSetDefault,
                    child: const Text('Set Default'),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete,
                    size: 18,
                    color: AppColors.danger,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
