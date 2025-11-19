import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/screens/home/home_page.dart';
import 'package:flutter_app/services/stripe_payment_service.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentFlowPage extends StatefulWidget {
  final int customerId = 13;

  const PaymentFlowPage({super.key});

  @override
  State<PaymentFlowPage> createState() => _PaymentFlowPageState();
}

class _PaymentFlowPageState extends State<PaymentFlowPage>
    with WidgetsBindingObserver {
  // Use late final for initialization in initState
  late final StripePaymentService _service;

  String _paymentStatus = 'IDLE';
  String? _currentSessionId;
  Timer? _pollingTimer;

  // Add observer to detect when the app returns from the external browser
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize the service using dependencies provided by Provider
    final tokenService = context.read<TokenService>();
    _service = StripePaymentService(tokenService);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Called when the application lifecycle changes (e.g., app resumed from background)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only start polling if we are returning to the app AND we initiated a payment flow
    if (state == AppLifecycleState.resumed &&
        _currentSessionId != null &&
        _paymentStatus.contains('STRIPE')) {
      startPolling(_currentSessionId!);
    }
  }

  // --- 1. Initiate Checkout and Launch Browser ---
  Future<void> startPaymentFlow() async {
    // Get the current user ID from the authentication provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerId = authProvider.currentUserId;

    if (customerId == null || !authProvider.isLoggedIn) {
      setState(() {
        _paymentStatus = 'AUTHENTICATION REQUIRED. Please log in.';
      });
      return;
    }

    setState(() {
      _paymentStatus = 'INITIATING... (Customer ID: $customerId)';
    });

    try {
      // 1. Call Spring backend (JWT token included by _service)
      final sessionDetails = await _service.initiateCheckout(customerId);
      final sessionUrl = sessionDetails['sessionUrl']!;
      _currentSessionId = sessionDetails['sessionId']!;

      setState(() {
        _paymentStatus = 'REDIRECTING TO STRIPE...';
      });

      // 2. Launch the Stripe URL in the external browser/new tab
      final success = await launchUrl(
        Uri.parse(sessionUrl),
        // Use platformDefault for broad compatibility (new tab on web, external app on mobile)
        mode: LaunchMode.platformDefault,
      );

      if (success) {
        setState(() {
          _paymentStatus = 'AWAITING RETURN FROM STRIPE...';
        });
      } else {
        setState(() {
          _paymentStatus =
              'Failed to open Stripe page. Check popup blocker or logs.';
        });
      }
    } catch (e) {
      setState(() {
        _paymentStatus = 'Error initiating payment: ${e.toString()}';
      });
    }
  }

  // --- 2. Polling for Status ---
  void startPolling(String sessionId) {
    _pollingTimer?.cancel(); // Stop any existing timer

    setState(() {
      _paymentStatus = 'Waiting for payment confirmation (Polling)...';
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final status = await _service!.checkPaymentStatus(sessionId);
        handleStatusResponse(status, timer);
      } catch (e) {
        print('Polling error: $e');
        // Continue polling if network error
      }
    });
  }

  // --- 3. Handle Polling Response ---
  void handleStatusResponse(String status, Timer timer) {
    // Check for final states defined by your Java backend
    if (status == 'SUCCESS') {
      timer.cancel();
      _currentSessionId = null;
      setState(() {
        _paymentStatus =
            'Payment SUCCESSFUL! Order Fulfilled and Cart Cleared.';
      });
      NavigationUtils.showAppSnackbar(context, "Payment Successful!", isError: false);
      NavigationUtils.pushAndRemoveUntil(context, HomePage());
    } else if (status == 'FAILED') {
      timer.cancel();
      _currentSessionId = null;
      setState(() {
        _paymentStatus = 'Payment FAILED. Please try again.';
      });
    } else {
      setState(() {
        _paymentStatus = 'Payment status: $status. Polling continues...';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPolling = _pollingTimer != null && _pollingTimer!.isActive;
    bool isFinalState =
        _paymentStatus.contains('SUCCESS') ||
        _paymentStatus.contains('FAILED') ||
        _paymentStatus.contains('Error');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Stripe Checkout Flow')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Customer ID: ${widget.customerId}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              'Status: $_paymentStatus',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: isPolling
                    ? Colors.orange
                    : (isFinalState && _paymentStatus.contains('SUCCESS')
                          ? Colors.green
                          : Colors.black),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            if (isPolling || _paymentStatus.contains('AWAITING RETURN'))
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: startPaymentFlow,
                child: Text(isFinalState ? 'Start New Payment' : 'Pay Now'),
              ),
          ],
        ),
      ),
    );
  }
}
