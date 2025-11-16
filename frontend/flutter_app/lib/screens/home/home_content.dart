
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/profile/profile_page.dart';
import 'package:flutter_app/utils/app_constants.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import 'package:flutter_app/widgets/custom_app_bar.dart';
import 'package:flutter_app/widgets/custom_bottom_nav.dart';
import 'package:flutter_app/widgets/custom_name.dart';
import 'package:flutter_app/widgets/custom_carousel.dart';
import 'package:flutter_app/widgets/custom_product_card.dart';
import 'package:flutter_app/widgets/custom_sidebar.dart';

class ShopContent extends StatelessWidget {
  const ShopContent({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Shop Content'));
}

class SellContent extends StatelessWidget {
  const SellContent({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Sell Content'));
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Profile Content'));
}

const String dummyVideoUrl =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

final List<Widget> _mobileScreens = [
  HomeContent(),
  const ShopContent(),
  const SellContent(),
  const Center(child: Text('Wishlist Content')),
  const ProfilePage(),
];

// --- Main Shell Widget ---

class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  bool _isWebLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.kTabletBreakpoint;
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = _isWebLayout(context);

    // Common AppBar definition

    if (isWeb) {
      // --- WEB/DESKTOP LAYOUT ---
      return Scaffold(
        appBar: CustomAppBar(
          titleText: "Phsa Khmer",
          actions: [
            CartActionButton(itemCount: 4),
            IconButton(
              onPressed: () {
                NavigationUtils.push(context, const ProfilePage());
              },
              icon: Icon(Icons.person),
            ),
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomSidebar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.kMaxContentWidth,
                      ),
                      child: Center(child: HomeContent()),
                    ),
                    const CustomFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // --- MOBILE LAYOUT ---
      return Scaffold(
        appBar: CustomAppBar(
          titleText: "Phsa Khmer",
          actions: [CartActionButton(itemCount: 4)],
        ),
        body: _mobileScreens[_currentIndex],
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      );
    }
  }
}

// --- Home Tab Content Widget ---

class HomeContent extends StatelessWidget {
  HomeContent({super.key});

  final List<Map<String, dynamic>> mockProducts = const [
    {
      "title": "Red T-Shirt",
      "price": 10.00,
      "originalPrice": 15.00,
      "imageUrl": "https://picsum.photos/id/20/400/300",
    },
    {
      "title": "Blue Jeans",
      "price": 35.50,
      "originalPrice": 45.00,
      "imageUrl": "https://picsum.photos/id/25/400/300",
    },
    {
      "title": "Sneakers",
      "price": 89.99,
      "originalPrice": null,
      "imageUrl": "https://picsum.photos/id/30/400/300",
    },
    {
      "title": "Watch",
      "price": 199.99,
      "originalPrice": 250.00,
      "imageUrl": "https://picsum.photos/id/35/400/300",
    },
    {
      "title": "Socks Pack",
      "price": 5.00,
      "originalPrice": null,
      "imageUrl": "https://picsum.photos/id/40/400/300",
    },
  ];

  final List<CarouselItem> carouselData = [
    CarouselItem(
      url: 'https://picsum.photos/id/1018/1000/600',
      type: CarouselMediaType.image,
      caption: 'Summer Sale',
    ),
    // CarouselItem(
    //   url: dummyVideoUrl,
    //   type: CarouselMediaType.video,
    //   caption: 'New Arrivals Video',
    // ),
    CarouselItem(
      url: 'https://picsum.photos/id/1015/1000/600',
      type: CarouselMediaType.image,
      caption: 'Flash Deals',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    bool isWeb =
        MediaQuery.of(context).size.width >= AppConstants.kTabletBreakpoint;

    final int crossAxisCount = isWeb ? 4 : 2;
    final double productCardChildAspectRatio = isWeb ? 0.75 : 0.65;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: CustomCarousel(
              items: carouselData,
              autoPlay: true,
              aspectRatio: isWeb ? 4 : 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.kDefaultPadding,
            ),
            child: Text(
              'Featured Products',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: AppConstants.kSpacingMedium),

          Container(
            constraints: isWeb
                ? const BoxConstraints(maxWidth: AppConstants.kMaxContentWidth)
                : null,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.kDefaultPadding),
              itemCount: mockProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: productCardChildAspectRatio,
                crossAxisSpacing: AppConstants.kSpacingMedium,
                mainAxisSpacing: AppConstants.kSpacingMedium,
              ),
              itemBuilder: (context, index) {
                final product = mockProducts[index];
                return CustomProductCard(
                  imageUrl: product["imageUrl"],
                  title: product["title"],
                  price: product["price"],
                  originalPrice: product["originalPrice"],
                  onTap: () => print('View ${product["title"]}'),
                  onAddToCart: () => print('Add ${product["title"]} to cart'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
