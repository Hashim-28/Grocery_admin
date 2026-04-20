import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';
import '../models/deal_model.dart';

class AddEditDealScreen extends StatefulWidget {
  final Deal? deal;
  const AddEditDealScreen({super.key, this.deal});

  @override
  State<AddEditDealScreen> createState() => _AddEditDealScreenState();
}

class _AddEditDealScreenState extends State<AddEditDealScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  DateTime? _expiresAt;
  bool _isActive = true;
  String? _imageUrl;
  File? _imageFile;

  List<Map<String, dynamic>> _selectedItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.deal?.name ?? '');
    _descController = TextEditingController(
      text: widget.deal?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.deal?.price.toString() ?? '',
    );
    _expiresAt = widget.deal?.expiresAt;
    _isActive = widget.deal?.isActive ?? true;
    _imageUrl = widget.deal?.imageUrl;

    if (widget.deal != null) {
      _selectedItems = widget.deal!.items
          .map(
            (item) => {
              'product_id': item.productId,
              'product_name': item.productName,
              'quantity': item.quantity,
              'price': item.productPrice,
            },
          )
          .toList();
    }
  }

  double get _totalOriginalPrice {
    return _selectedItems.fold(0.0, (sum, item) {
      return sum + ((item['price'] ?? 0.0) * (item['quantity'] ?? 1));
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final pickedTime = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedTime != null) {
      setState(() {
        _expiresAt = pickedTime;
      });
    }
  }

  void _addProduct() async {
    final products = context.read<DataProvider>().products;
    final selectedProduct = await showDialog<Product>(
      context: context,
      builder: (context) => _ProductSelectionDialog(products: products),
    );

    if (selectedProduct != null) {
      setState(() {
        final existingIdx = _selectedItems.indexWhere(
          (item) => item['product_id'] == selectedProduct.id,
        );
        if (existingIdx >= 0) {
          _selectedItems[existingIdx]['quantity']++;
        } else {
          _selectedItems.add({
            'product_id': selectedProduct.id,
            'product_name': selectedProduct.name,
            'quantity': 1,
            'price': selectedProduct.salePrice,
          });
        }
      });
    }
  }

  Future<void> _saveDeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product to the deal'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<DataProvider>();
      final name = _nameController.text;
      final desc = _descController.text;
      final price = double.parse(_priceController.text);
      final originalPrice = _totalOriginalPrice;

      if (widget.deal == null) {
        print('--- Adding New Deal ---');
        print('Name: $name');
        print('Description: $desc');
        print('Price: $price');
        print('Original Price: $originalPrice');
        print('Expires: $_expiresAt');
        print('Image Path: ${_imageFile?.path}');
        print('Items: $_selectedItems');
        
        await provider.addDeal(
          name: name,
          description: desc,
          price: price,
          originalPrice: originalPrice,
          expiresAt: _expiresAt,
          imagePath: _imageFile?.path,
          items: _selectedItems,
        );
      } else {
        await provider.updateDeal(
          id: widget.deal!.id,
          name: name,
          description: desc,
          price: price,
          originalPrice: originalPrice,
          expiresAt: _expiresAt,
          isActive: _isActive,
          imageUrl: _imageUrl,
          newImagePath: _imageFile?.path,
          items: _selectedItems,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deal ${widget.deal == null ? 'created' : 'updated'} successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving deal: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.deal == null ? 'CREATE NEW DEAL' : 'EDIT DEAL'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePicker(),
                    const SizedBox(height: 32),
                    _buildTextField(
                      _nameController,
                      'Deal Name',
                      'Enter a catchy name like "Summer BBQ Pack"',
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _descController,
                      'Description',
                      'What makes this deal special?',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('PRODUCTS IN THIS DEAL'),
                    const SizedBox(height: 12),
                    _buildProductList(),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _addProduct,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('ADD PRODUCT TO BUNDLE'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildPricingSection(),
                    const SizedBox(height: 32),
                    _buildExpiryAndStatus(),
                    const SizedBox(height: 48),
                    _buildSaveButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.textGrey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.bgGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderGrey),
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              )
            : _imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(_imageUrl!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 40,
                    color: AppTheme.textGrey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload Deal Banner',
                    style: TextStyle(color: AppTheme.textGrey),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.bgGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (val) =>
              val == null || val.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildProductList() {
    if (_selectedItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.bgGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderGrey,
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Text(
            'No products added yet',
            style: TextStyle(color: AppTheme.textGrey),
          ),
        ),
      );
    }

    return Column(
      children: _selectedItems.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderGrey),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['product_name'] ?? 'Product',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₨${item['price']} each',
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (item['quantity'] > 1) {
                          item['quantity']--;
                        } else {
                          _selectedItems.removeAt(idx);
                        }
                      });
                    },
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    '${item['quantity']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        item['quantity']++;
                      });
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                      size: 20,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPricingSection() {
    final original = _totalOriginalPrice;
    final discounted = double.tryParse(_priceController.text) ?? 0.0;
    final savings = original > discounted ? original - discounted : 0.0;
    final percentage = original > 0 ? (savings / original * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calculated Total:',
                style: TextStyle(color: AppTheme.textGrey),
              ),
              Text(
                '₨${original.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            _priceController,
            'Discounted Bundle Price (₨)',
            'e.g. 500',
          ),
          const SizedBox(height: 20),
          if (savings > 0) ...[
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer Savings:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                Text(
                  '₨${savings.toStringAsFixed(0)} ($percentage% OFF)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpiryAndStatus() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expiry Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectExpiryDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.bgGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _expiresAt == null
                            ? 'No Expiry'
                            : '${_expiresAt!.day}/${_expiresAt!.month}/${_expiresAt!.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                  title: Text(
                    _isActive ? 'Active' : 'Draft',
                    style: const TextStyle(fontSize: 14),
                  ),
                  activeColor: AppTheme.primaryGreen,
                  dense: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveDeal,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryGreen,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Text(
        widget.deal == null ? 'CREATE DEAL' : 'SAVE CHANGES',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ProductSelectionDialog extends StatefulWidget {
  final List<Product> products;
  const _ProductSelectionDialog({required this.products});

  @override
  State<_ProductSelectionDialog> createState() =>
      _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<_ProductSelectionDialog> {
  late List<Product> _filteredProducts;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
  }

  void _filter(String query) {
    setState(() {
      _search = query;
      _filteredProducts = widget.products
          .where(
            (p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.category.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select a Product'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filter,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final p = _filteredProducts[index];
                  return ListTile(
                    leading: Text(
                      p.emoji.isNotEmpty ? p.emoji : '📦',
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(p.name),
                    subtitle: Text('₨${p.salePrice} | ${p.category}'),
                    onTap: () => Navigator.pop(context, p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
      ],
    );
  }
}
