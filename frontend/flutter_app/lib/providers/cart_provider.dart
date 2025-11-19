// providers/cart_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/api/private/cart_api_service.dart';
import 'package:flutter_app/models/cart/cart_model.dart';
import 'package:flutter_app/providers/auth_provider.dart';

class CartProvider with ChangeNotifier {
  final CartApiService _apiService;
  // Make this mutable so it can be updated
  AuthProvider _authProvider;

  CartModel? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  // The constructor still takes the initial auth provider
  CartProvider(this._authProvider, this._apiService);

  // --- ADD THIS METHOD ---
  /// Updates the provider with the latest AuthProvider instance.
  void update(AuthProvider newAuthProvider) {
    _authProvider = newAuthProvider;
  }
  // --- END OF ADDITION ---

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalItemCount {
    if (_cart == null) return 0;
    return _cart!.items.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<void> _executeCartOperation(
    Future<CartModel> Function() operation,
  ) async {
    // This now uses the potentially updated _authProvider
    if (!_authProvider.isLoggedIn) {
      _errorMessage = "Please log in to manage your cart.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _cart = await operation();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCart() {
    _cart = null;
    notifyListeners();
  }

  Future<void> fetchCart() =>
      _executeCartOperation(() => _apiService.getMyCart());
  Future<void> addItem(int itemId, int quantity) =>
      _executeCartOperation(() => _apiService.addItemToCart(itemId, quantity));
  Future<void> updateItem(int itemId, int quantity) => _executeCartOperation(
    () => _apiService.updateItemQuantity(itemId, quantity),
  );
  Future<void> removeItem(int itemId) =>
      _executeCartOperation(() => _apiService.removeItemFromCart(itemId));
}
