import 'package:flutter/material.dart';

class PaymentCancelPage extends StatelessWidget {
  const PaymentCancelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Cancelled")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cancel, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Payment Was Not Completed',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'You can return to the previous screen to try your payment again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to the cart or checkout page
                  Navigator.of(context).pop();
                },
                child: const Text('Return to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
