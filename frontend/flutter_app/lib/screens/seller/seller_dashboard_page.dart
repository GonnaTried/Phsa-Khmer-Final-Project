import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});

  void _navigateToSellProduct(BuildContext context) {
    // Navigates to the form page where the user inputs product details
    Navigator.of(context).pushNamed('/sell');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        actions: [
          // The prominent button to start listing a new product
          IconButton(
            icon: const Icon(Icons.add_circle, size: 30),
            onPressed: () => _navigateToSellProduct(context),
            tooltip: 'List New Product',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Responsive.build(
        context,
        mobile: const SellerDashboardMobileView(),
        desktop: const SellerDashboardDesktopView(),
      ),
    );
  }
}

// --- Dashboard Sub-Views (Responsive Content) ---

class SellerDashboardMobileView extends StatelessWidget {
  const SellerDashboardMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'Your Listed Products',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Divider(),
        _buildProductListPlaceholder(context, columns: 1),
        const SizedBox(height: 20),
        _buildStatsPlaceholder(),
      ],
    );
  }
}

class SellerDashboardDesktopView extends StatelessWidget {
  const SellerDashboardDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Stats/Analytics
        Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: _buildStatsPlaceholder(),
        ),

        // Right Column: Listed Products
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Listed Products',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Divider(),
                _buildProductListPlaceholder(context, columns: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Common Placeholder Widgets ---

Widget _buildStatsPlaceholder() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Sales Overview',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      ListTile(title: Text('Active Listings: 5'), leading: Icon(Icons.list)),
      ListTile(title: Text('Total Sales: \$1,200'), leading: Icon(Icons.paid)),
      ListTile(
        title: Text('Pending Orders: 2'),
        leading: Icon(Icons.access_time),
      ),
      const SizedBox(height: 20),
      // Placeholder for charts or quick links
      Container(
        height: 150,
        color: Colors.grey.shade200,
        child: Center(child: Text('Analytics Chart Placeholder')),
      ),
    ],
  );
}

Widget _buildProductListPlaceholder(
  BuildContext context, {
  required int columns,
}) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 3.5, // Make items wide and short
    ),
    itemCount: 5,
    itemBuilder: (context, index) {
      return Card(
        color: Colors.lightBlue.shade50,
        child: ListTile(
          leading: const Icon(Icons.inventory_2, color: Colors.blue),
          title: Text('Product Name $index'),
          subtitle: Text('Status: Active'),
          trailing: const Icon(Icons.edit),
        ),
      );
    },
  );
}
