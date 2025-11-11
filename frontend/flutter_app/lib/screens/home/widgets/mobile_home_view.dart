import 'package:flutter/material.dart';
import '../../../services/token_service.dart';
import '../../../utils/auth_check.dart';

class MobileHomeView extends StatefulWidget {
  const MobileHomeView({super.key});

  @override
  State<MobileHomeView> createState() => _MobileHomeViewState();
}

class _MobileHomeViewState extends State<MobileHomeView> {
  int _selectedIndex = 0;
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

  void _onAccountTap() async {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Com Mobile'),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: const [
          // 1. Search Bar
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for products, brands...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // 2. Main Carousel/Banner Area
          SizedBox(
            height: 180,
            child: Placeholder(
              child: Center(child: Text('Promotional Carousel')),
            ),
          ),
          SizedBox(height: 16),
          // 3. Quick Access Categories
          Text(
            'Quick Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 100,
            child: Placeholder(child: Text('Category Icons Grid')),
          ),
          SizedBox(height: 16),
          // 4. Trending Products
          Text(
            'Trending Deals',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 300,
            child: Placeholder(child: Text('Product Grid (2 columns)')),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            _onAccountTap();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(_isLoggedIn ? Icons.person : Icons.login),
            label: _isLoggedIn ? 'Account' : 'Sign In',
          ),
        ],
      ),
    );
  }
}
