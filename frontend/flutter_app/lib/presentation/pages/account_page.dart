// lib/presentation/pages/account_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/auth_provider.dart';
import 'package:flutter_app/presentation/pages/sign_in_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Change StatelessWidget to ConsumerWidget
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state
    final user = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    // If user is null (logged out), show the Sign In Page
    if (user == null) {
      return const SignInPage();
    }

    // If user is not null (logged in), show the Account Dashboard
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, ${user.username}!',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 10),
          Text('Telegram ID: ${user.telegramId}'),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              authNotifier.signOut(); // Trigger logout
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
