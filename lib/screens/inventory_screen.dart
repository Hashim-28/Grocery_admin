import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_theme.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.role == UserRole.admin;
    final currencyFormat = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

    final filteredProducts = _selectedCategory == 'All'
        ? data.products
        : data.products.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgGrey,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('INVENTORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppTheme.primaryGreen)),
            Text('Management Console', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products, SKU...',
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterChip('All'),
                    const SizedBox(width: 8),
                    _filterChip('Groceries'),
                    const SizedBox(width: 8),
                    _filterChip('Electronics'),
                    const SizedBox(width: 8),
                    _filterChip('Apparel'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
            borderRadius: BorderRadius.circular(16),
            child: _ProductCard(product: product, format: currencyFormat),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
              },
              backgroundColor: AppTheme.primaryGreen,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _filterChip(String category) {
    print('Filter category: $category, selected: $_selectedCategory');
    final isSelected = _selectedCategory == category;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = category),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryGreen : AppTheme.borderGrey),
        ),
        child: Text(
          category,
          style: TextStyle(color: isSelected ? Colors.white : AppTheme.textGrey, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final NumberFormat format;
  const _ProductCard({required this.product, required this.format});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.bgGrey,
              borderRadius: BorderRadius.circular(12),
              image: product.imagePath != null
                  ? DecorationImage(
                      image: FileImage(File(product.imagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.imagePath == null
                ? const Icon(Icons.inventory_2_outlined, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('${product.category} • SKU: ${product.sku}', style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                const SizedBox(height: 8),
                _buildStatusBadge(product.status, product.stockCount),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(format.format(product.price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Text('per unit', style: TextStyle(color: AppTheme.textGrey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(StockStatus status, int count) {
    Color color;
    String label;
    switch (status) {
      case StockStatus.inStock:
        color = Colors.green;
        label = 'In Stock: $count';
        break;
      case StockStatus.lowStock:
        color = Colors.orange;
        label = 'Low Stock: $count';
        break;
      case StockStatus.outOfStock:
        color = Colors.red;
        label = 'Out of Stock';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
