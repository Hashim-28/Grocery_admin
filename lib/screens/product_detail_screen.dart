import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _stockController = TextEditingController(text: widget.product.stockCount.toString());
  }

  @override
  Widget build(BuildContext context) {
    final data = context.read<DataProvider>();
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.role == UserRole.admin;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                data.deleteProduct(widget.product.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted')));
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.bgGrey,
                  borderRadius: BorderRadius.circular(24),
                  image: widget.product.imagePath != null
                      ? DecorationImage(
                          image: FileImage(File(widget.product.imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.product.imagePath == null
                    ? const Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 32),
            Text(isAdmin ? 'Edit Information' : 'Product Information', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: _nameController, readOnly: !isAdmin),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text('Price (PKR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                       const SizedBox(height: 8),
                       TextField(controller: _priceController, keyboardType: TextInputType.number, readOnly: !isAdmin),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text('Stock Count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                       const SizedBox(height: 8),
                       TextField(controller: _stockController, keyboardType: TextInputType.number, readOnly: !isAdmin),
                    ],
                  ),
                ),
              ],
            ),
            if (isAdmin) ...[
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  data.updateProduct(
                    widget.product.id,
                    _nameController.text,
                    double.parse(_priceController.text),
                    int.parse(_stockController.text),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product updated')));
                },
                child: const Text('Update Product'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
