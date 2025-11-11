import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class SellProductPage extends StatelessWidget {
  const SellProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell New Product'), elevation: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Responsive.build(
                context,
                mobile: const SellProductForm(),
                desktop: const SellProductWideLayout(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SellProductForm extends StatefulWidget {
  const SellProductForm({super.key});

  @override
  State<SellProductForm> createState() => _SellProductFormState();
}

class _SellProductFormState extends State<SellProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home Goods',
    'Books',
    'Other',
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Logic to gather data and send to backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitting product: ${_titleController.text}')),
      );
      // TODO: Implement API call to POST /api/products/sell/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Product Title and Category
          Text(
            'Product Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 15),

          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Product Title',
              hintText: 'e.g., Apple iPhone 15 Pro Max',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value!.isEmpty ? 'Title cannot be empty' : null,
          ),
          const SizedBox(height: 15),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            value: _selectedCategory,
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 30),

          // Section 2: Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Detailed Description',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            maxLines: 6,
            validator: (value) =>
                value!.length < 20 ? 'Description must be detailed' : null,
          ),
          const SizedBox(height: 30),

          // Section 3: Pricing and Stock
          Text(
            'Pricing & Inventory',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price (\$)',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty || double.tryParse(value) == null
                      ? 'Enter valid price'
                      : null,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty || int.tryParse(value) == null
                      ? 'Enter valid quantity'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Section 4: Image Upload (Placeholder)
          const Text(
            'Product Images (Max 5)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildImageUploadArea(),
          const SizedBox(height: 40),

          // Submit Button
          Center(
            child: ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.send),
              label: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Text('List Product', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildImageUploadArea() {
  return Container(
    height: 150,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, color: Colors.grey.shade600, size: 40),
          const SizedBox(height: 8),
          Text(
            'Click to Add Images',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    ),
  );
}

class SellProductWideLayout extends StatelessWidget {
  const SellProductWideLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // We use the same form logic via the StatefulWidget, but wrap it in a Row/Column structure
    return const Column(
      children: [
        // Using a modified version of the form for layout control
        _SellProductWideContent(),
      ],
    );
  }
}

// Separate stateful widget to handle the dual column layout
class _SellProductWideContent extends StatefulWidget {
  const _SellProductWideContent();

  @override
  State<_SellProductWideContent> createState() =>
      _SellProductWideContentState();
}

class _SellProductWideContentState extends State<_SellProductWideContent> {
  // Use the same controllers and submission logic as the mobile form
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String? _selectedCategory;
  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home Goods',
    'Books',
    'Other',
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitting product: ${_titleController.text}')),
      );
      // TODO: Implement API call
    }
  }

  // Re-use the image widget
  Widget _buildImageUploadArea() {
    // ... (implementation from section 3)
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.grey.shade600, size: 40),
            const SizedBox(height: 8),
            Text(
              'Click to Add Images',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Details (Title, Category, Description)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Product Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Title cannot be empty' : null,
                    ),
                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      items: _categories
                          .map(
                            (String category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (newValue) =>
                          setState(() => _selectedCategory = newValue),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Detailed Description',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 10,
                      validator: (value) => value!.length < 20
                          ? 'Description must be detailed'
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 30),

              // Column 2: Pricing, Stock, and Images
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pricing & Inventory',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price (\$)',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty || double.tryParse(value) == null
                          ? 'Enter valid price'
                          : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Quantity',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty || int.tryParse(value) == null
                          ? 'Enter valid quantity'
                          : null,
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Product Images (Max 5)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildImageUploadArea(),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Submit Button (Full Width)
          Center(
            child: ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.send),
              label: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Text('List Product', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
