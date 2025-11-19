import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/services/stripe_payment_service.dart';
import 'package:flutter_app/services/token_service.dart';
import 'package:provider/provider.dart';

class PaymentStatusChecker extends StatefulWidget {
  // Use a mock session ID for testing.
  // In a real app, this would be passed from the previous checkout step.
  final String testSessionId = 'cs_test_a1qT8X5rNlD7y0o1p2q3r4s5t6u7v8w9x0';

  const PaymentStatusChecker({super.key});

  @override
  State<PaymentStatusChecker> createState() => _PaymentStatusCheckerState();
}

class _PaymentStatusCheckerState extends State<PaymentStatusChecker> {
  late final StripePaymentService _service;
  String _currentStatus = 'IDLE';
  Timer? _pollingTimer;
  int _pollCount = 0;
  final int _maxPolls = 20;

  @override
  void initState() {
    super.initState();
    final tokenService = context.read<TokenService>();
    _service = StripePaymentService(tokenService);
  }

  void startPolling() {
    _pollCount = 0;
    _pollingTimer?.cancel();
    setState(() {
      _currentStatus = 'PENDING';
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollCount++;

      if (_pollCount > _maxPolls) {
        timer.cancel();
        setState(() {
          _currentStatus = 'TIMEOUT (Max attempts reached)';
        });
        return;
      }

      try {
        final status = await _service.checkPaymentStatus(widget.testSessionId);
        handleStatusResponse(status, timer);
      } catch (e) {
        // Handle exceptions thrown by the service if needed,
        setState(() {
          _currentStatus = 'CONNECTION_ERROR (Attempt $_pollCount)';
        });
      }
    });
  }

  void handleStatusResponse(String status, Timer timer) {
    if (status == 'CONNECTION_ERROR' ||
        status == 'PENDING' ||
        status == 'NOT_FOUND') {
      // Continue polling
      setState(() {
        _currentStatus = '$status (Attempt $_pollCount)';
      });
      return;
    }

    // SUCCESS or FAILED are final states
    timer.cancel(); // Stop polling

    if (status == 'SUCCESS') {
      setState(() {
        _currentStatus = 'Payment SUCCESSFUL! Cart Cleared!';
      });
      // Logic for post-success: navigation, local database update, etc.
    } else if (status == 'FAILED') {
      setState(() {
        _currentStatus = 'Payment FAILED!';
      });
    } else {
      setState(() {
        _currentStatus = 'UNKNOWN STATUS: $status';
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer
        ?.cancel(); // Important: cancel the timer when the widget is destroyed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPolling = _pollingTimer != null && _pollingTimer!.isActive;

    return Scaffold(
      appBar: AppBar(title: const Text('Stripe Payment Status Checker')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Polling Mechanism Demo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Session ID: ${widget.testSessionId}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              Text(
                'Status:',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              Text(
                _currentStatus,
                style: TextStyle(
                  fontSize: 24,
                  color: isPolling
                      ? Colors.orange
                      : (_currentStatus.contains('SUCCESS')
                            ? Colors.green
                            : Colors.red),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              if (isPolling)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: startPolling,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text('Start Status Check'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
