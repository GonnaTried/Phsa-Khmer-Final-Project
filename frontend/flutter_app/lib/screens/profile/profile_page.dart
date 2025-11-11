import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/token_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TokenService _tokenService = TokenService();
  late final AuthService _authService;

  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(_tokenService);
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;

    final profile = await _authService.fetchUserProfile();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (profile != null) {
        _userProfile = profile;
        _error = null;
      } else {
        _error = "Could not load profile data. Please try logging in again.";
      }
    });
  }

  void _logout() async {
    await _tokenService.deleteTokens();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  void _navigateToSellProduct() {
    Navigator.of(context).pushNamed('/sell');
  }

  void _navigateToSellerDashboard() {
    Navigator.of(context).pushNamed('/dashboard');
  }

  // --- UI Building Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100, // Slightly off-white background
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 16.0,
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildErrorView()
                : _userProfile != null
                ? _buildProfileDetails(context)
                : const Text('No profile data available.'),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context) {
    final telegramStatus = _userProfile!.telegramLinked
        ? 'Linked'
        : 'Not Linked';
    final telegramLinkColor = _userProfile!.telegramLinked
        ? Colors.green.shade600
        : Colors.red.shade600;

    return Card(
      elevation:
          0, // CRITICAL FIX: Set elevation to 0 to remove the floating shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        // Use a Container inside the Card for inner background color/padding
        color: Colors
            .white, // Ensure a clean white background inside the card area
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Header (Blue/Primary Color for contrast)
            Text(
              'Welcome, ${_userProfile!.username}',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor, // Use primary color
              ),
              textAlign: TextAlign.start, // Align to start (left)
            ),
            const Divider(height: 30, thickness: 1.0), // Reduced thickness
            // Info Rows
            _buildInfoRow('PHSA Username:', _userProfile!.username),
            _buildInfoRow('PHSA Phone Number:', _userProfile!.phoneNumber),
            _buildInfoRow('Telegram Username:', _userProfile!.telegramUsername),
            _buildInfoRow(
              'Telegram Account Status:',
              telegramStatus,
              valueColor: telegramLinkColor,
            ),

            const SizedBox(height: 40),

            // --- NEW: Sell Product Button ---
            ElevatedButton.icon(
              onPressed: _navigateToSellerDashboard,
              icon: const Icon(Icons.sell),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text('Seller Dashboard', style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor, // Use app primary color (blue)
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),

            const SizedBox(height: 15),

            // Logout Button
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text('Logout', style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
