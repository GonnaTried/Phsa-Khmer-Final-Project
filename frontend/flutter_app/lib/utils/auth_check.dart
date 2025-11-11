import 'package:flutter/material.dart';
import '../services/token_service.dart';

final TokenService _tokenService = TokenService();

Future<bool> checkAuthAndRedirect(BuildContext context) async {
  final isLoggedIn = await _tokenService.isUserLoggedIn();

  if (!isLoggedIn) {
    await Navigator.of(context).pushNamed('/login');

    final isLoggedInAfterLogin = await _tokenService.isUserLoggedIn();
    return isLoggedInAfterLogin;
  }
  return true;
}

void navigateToProtected(BuildContext context, String routeName) async {
  final canProceed = await checkAuthAndRedirect(context);
  if (canProceed) {
    Navigator.of(context).pushNamed(routeName);
  }
}
