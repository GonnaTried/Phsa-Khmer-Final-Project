// lib/presentation/pages/sign_in_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/auth_provider.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app/core/utils/app_logger.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  Future<void> _initiateTelegramAuth() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Initiate Auth and get the one-time code
      final String oneTimeCode = await _authRepository.initiateAuth();

      // 2. Construct the Telegram Deep Link
      final String deepLink = 'https://t.me/phsakhmer_bot?start=$oneTimeCode';
      final Uri uri = Uri.parse(deepLink);

      // 3. Launch the link
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // --- IMPORTANT: Next Step Prompt ---
        // Since we launched the link, we should inform the user what to do next.
        _showNextStepsDialog(oneTimeCode);
      } else {
        throw Exception('Could not launch Telegram app. Is it installed?');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign-in Error: ${e.toString()}')));
      appLogger.e('Sign-in Initialization Error', error: e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showNextStepsDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (ctx) => AlertDialog(
        title: const Text('Action Required'),
        content: Text(
          'Please confirm the login request in the Telegram Chatbot. Your unique code is: $code',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          // Once the link is launched, we can start polling the backend for the token
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _startPolling(code);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Waiting for Telegram confirmation...'),
                ),
              );
            },
            child: const Text('I Confirmed in Telegram'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ... (Text widgets remain the same)
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : _initiateTelegramAuth, // Disable button while loading
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.telegram, size: 30),
                label: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Text(
                    _isLoading
                        ? 'Initiating...'
                        : 'Sign In with Telegram Chatbot',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ... (Bottom text remains the same)
            ],
          ),
        ),
      ),
    );
  }

  Timer? _pollingTimer;
  void _startPolling(String code) {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      appLogger.d('Polling server with code: $code');
      final token = await _authRepository.checkAuthStatus(code);

      if (token != null) {
        timer.cancel();

        await ref.read(authProvider.notifier).signInWithToken(token);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful! Welcome!')),
        );
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Update _showNextStepsDialog to start polling when the user presses 'I Confirmed'
}
