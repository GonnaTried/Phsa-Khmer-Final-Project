import 'package:flutter/material.dart';
import '../../../services/token_service.dart';
import '../../../utils/auth_check.dart';

class DesktopHomeView extends StatefulWidget {
  const DesktopHomeView({super.key});

  @override
  State<DesktopHomeView> createState() => _DesktopHomeViewState();
}

class _DesktopHomeViewState extends State<DesktopHomeView> {
  static const double maxWidth = 1200.0;
  bool _isLoggedIn = false;
  final TokenService _tokenService = TokenService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final status = await _tokenService.isUserLoggedIn();
    if (status != _isLoggedIn) {
      setState(() {
        _isLoggedIn = status;
      });
    }
  }

  void _handleProfileOrLogin() async {
    print(
      'Handling profile/login click. Current logged in status: $_isLoggedIn',
    );

    if (_isLoggedIn) {
      Navigator.of(
        context,
      ).pushNamed('/profile').then((_) => _checkLoginStatus());
    } else {
      final wasSuccessful = await checkAuthAndRedirect(context);
      if (wasSuccessful) {
        Navigator.of(
          context,
        ).pushNamed('/profile').then((_) => _checkLoginStatus());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Persistent Top Navigation Bar (Header)
        _buildDesktopHeader(),

        // 2. Main Content Area (Scrollable)
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Sidebar
                      _buildLeftSidebar(),
                      const SizedBox(width: 20),

                      // Main Content Body
                      Expanded(child: _buildMainContentBody()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 3. Footer
        _buildDesktopFooter(),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'E-Com Logo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 100.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for anything...',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                    ),
                  ),
                ),
              ),

              Row(
                children: [
                  TextButton.icon(
                    onPressed: _handleProfileOrLogin,
                    icon: Icon(
                      _isLoggedIn ? Icons.person : Icons.login,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isLoggedIn ? 'Account' : 'Sign In',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.shopping_cart, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftSidebar() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Shop Categories',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Divider(),
          ListTile(title: Text('Electronics')),
          ListTile(title: Text('Fashion')),
          ListTile(title: Text('Home Goods')),
          ListTile(title: Text('Collectibles')),
        ],
      ),
    );
  }

  Widget _buildMainContentBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Large Carousel Banner
        const SizedBox(
          height: 300,
          child: Placeholder(
            child: Center(child: Text('Main Promotional Carousel')),
          ),
        ),
        const SizedBox(height: 20),

        // Featured Deals Section (Grid View)
        const Text(
          'Featured Deals',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            return const Card(child: Center(child: Text('Product Item')));
          },
        ),
      ],
    );
  }

  Widget _buildDesktopFooter() {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: Text('© 2024 E-Com Flutter Platform | Links | Help Center'),
      ),
    );
  }
}
