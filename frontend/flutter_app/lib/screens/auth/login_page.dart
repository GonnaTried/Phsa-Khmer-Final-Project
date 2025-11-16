import 'package:flutter/material.dart';
import 'package:flutter_app/services/token_service.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/auth_service.dart';
import '../../../utils/responsive.dart';
import '../home/home_content.dart';

enum AuthState { initial, awaitingTelegram, registrationNeeded, loggedIn }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TokenService _tokenService = TokenService();
  final AuthService _authService = AuthService(TokenService());
  AuthState _currentState = AuthState.initial;
  String? _oneTimeCode;
  String _statusMessage = '';
  Timer? _checkTimer;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // --- Step 1: Initiate Auth & Get Code ---
  void _initiateLogin() async {
    if (!mounted) return;
    setState(() {
      _statusMessage = 'Initiating login...';
    });

    final code = await _authService.initiateAuth();

    if (code != null) {
      _oneTimeCode = code;
      setState(() {
        _currentState = AuthState.awaitingTelegram;
        _statusMessage = 'Please verify login via Telegram.';
      });
      _openTelegramBot(code);
      _startStatusPolling(code);
    } else {
      setState(() {
        _statusMessage = 'Failed to get verification code.';
      });
    }
  }

  // --- Step 2: Open Telegram Link ---
  void _openTelegramBot(String code) async {
    final universalUrl = 'https://t.me/phsakhmer_bot?start=$code';
    final universalUri = Uri.parse(universalUrl);

    bool launched = false;

    if (await canLaunchUrl(universalUri)) {
      launched = await launchUrl(
        universalUri,
        mode: LaunchMode.externalApplication,
      );
      print(
        'Attempted Universal Link Launch (forcing external app/browser): $launched',
      );
    }

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open browser. Please manually copy the link: $universalUrl',
          ),
          duration: const Duration(seconds: 15),
        ),
      );
    }
  }

  // --- Step 3: Polling for Status ---
  void _startStatusPolling(String code) {
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final result = await _authService.checkAuthStatus(code);

      setState(() {
        _statusMessage = result.message;
      });

      if (result.status == 'verified') {
        _checkTimer?.cancel();
        if (result.registered == false) {
          setState(() {
            _currentState = AuthState.registrationNeeded;
          });
        } else {
          _handleSuccessfulLogin(result);
        }
      } else if (result.status == 'success') {
        _checkTimer?.cancel();
        _handleSuccessfulLogin(result);
      } else if (result.status == 'expired' ||
          result.status == 'invalid_code' ||
          result.status == 'network_error') {
        _checkTimer?.cancel();
        setState(() {
          _currentState = AuthState.initial;
          _statusMessage = result.message;
        });
      }
    });
  }

  // --- Step 4: Final Registration ---
  void _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_oneTimeCode == null) return;

    setState(() {
      _statusMessage = 'Finalizing registration...';
    });

    final result = await _authService.finalAuth(
      code: _oneTimeCode!,
      phoneNumber: _phoneController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    if (result.status == 'success' && result.accessToken != null) {
      _handleSuccessfulLogin(result);
    } else {
      setState(() {
        _statusMessage = result.message;
      });
    }
  }

  // --- Final Step: Login Success ---
  void _handleSuccessfulLogin(AuthResult result) async {
    if (result.accessToken != null && result.refreshToken != null) {
      await _tokenService.saveTokens(result.accessToken!, result.refreshToken!);
    }

    _checkTimer?.cancel();
    setState(() {
      _currentState = AuthState.loggedIn;
    });

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => HomeContent()));
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: Responsive.build(
          context,
          mobile: _buildLoginContainer(context, 350),
          desktop: _buildLoginContainer(context, 450),
        ),
      ),
    );
  }

  Widget _buildLoginContainer(BuildContext context, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          if (_currentState == AuthState.initial) _buildInitialView(),

          if (_currentState == AuthState.awaitingTelegram) _buildAwaitingView(),

          if (_currentState == AuthState.registrationNeeded)
            _buildRegistrationView(),

          const SizedBox(height: 15),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _getStatusColor()),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_currentState == AuthState.awaitingTelegram ||
        _currentState == AuthState.registrationNeeded) {
      return Colors.blueGrey;
    }

    final messageLower = _statusMessage.toLowerCase();
    if (messageLower.contains('failed') ||
        messageLower.contains('error') ||
        messageLower.contains('expired')) {
      return Colors.red.shade700;
    }

    return Colors.grey;
  }

  Widget _buildInitialView() {
    return ElevatedButton.icon(
      onPressed: _initiateLogin,
      icon: const Icon(Icons.telegram),
      label: const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Text('Login with Telegram', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildAwaitingView() {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        const Text('Awaiting verification...', textAlign: TextAlign.center),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => _openTelegramBot(_oneTimeCode!),
          child: const Text('Open Telegram Bot again'),
        ),
      ],
    );
  }

  Widget _buildRegistrationView() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
            'Complete your profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number (Required)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name (Optional)',
              hintText: 'Telegram name used if empty',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name (Optional)',
              hintText: 'Telegram name used if empty',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitRegistration,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text('Complete Registration & Log In'),
            ),
          ),
        ],
      ),
    );
  }
}
