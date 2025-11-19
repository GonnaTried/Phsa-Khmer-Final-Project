import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/private/cart_api_service.dart'; // Ensure correct import path
import 'package:flutter_app/screens/home/home_page.dart'; // Import HomePage
import 'package:provider/provider.dart';

// Define the statuses to match the backend
const String STATUS_PENDING = "PENDING";
const String STATUS_SUCCESS = "SUCCESS";
const String STATUS_FAILED = "FAILED";
const String STATUS_NOT_FOUND = "NOT_FOUND";

class PaymentPollingPage extends StatefulWidget {
  final String sessionId;
  
  const PaymentPollingPage({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<PaymentPollingPage> createState() => _PaymentPollingPageState();
}

class _PaymentPollingPageState extends State<PaymentPollingPage> {
  String _status = STATUS_PENDING;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  Future<void> checkStatus() async {
    final cartApiService = Provider.of<CartApiService>(context, listen: false);

    try {
      final statusResponse = await cartApiService.checkPaymentStatus(widget.sessionId);
      final newStatus = statusResponse.status;

      if (_status != newStatus) {
        setState(() {
          _status = newStatus;
        });
        
        // Check if polling should stop
        if (newStatus == STATUS_SUCCESS) {
          _timer?.cancel();
          _navigateToSuccess();
        } else if (newStatus == STATUS_FAILED || newStatus == STATUS_NOT_FOUND) {
          _timer?.cancel();
          _navigateToCancel();
        }
      }
    } catch (e) {
      print("Polling failed: $e");
      // If polling fails repeatedly due to network error, you might want to stop the timer eventually.
    }
  }

  void _startPolling() {
    // Start polling immediately, then every 5 seconds
    checkStatus(); 
    // Start timer for subsequent polls (every 5 seconds)
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkStatus();
    });
  }

  void _navigateToSuccess() {
    // Navigate to the Confirmation Page, then navigate back to the HomePage
    
    // We navigate to the success page first (where the session ID is displayed)
    // Then we replace the success page with the Home Page. 
    // Alternatively, you can navigate straight to HomePage and show a banner.

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/payment_success', 
      (route) => false, // Clear all previous routes
      arguments: widget.sessionId
    );
  }

  void _navigateToCancel() {
    // Navigate to the Cancel Page, clearing previous routes
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/payment_cancel', 
      (route) => false
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Processing Payment")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              "Checking payment status...",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text("Session ID: ${widget.sessionId}"),
            Text("Current Status: $_status"),
            if (_status == STATUS_PENDING)
              const Text("Waiting for Stripe confirmation...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}