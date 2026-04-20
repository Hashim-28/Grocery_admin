import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import 'dart:io';
import '../providers/data_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'add_category_screen.dart';

class AddProductScreen extends StatefulWidget {
  final Product? initialProduct;
  const AddProductScreen({super.key, this.initialProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _stockController = TextEditingController(text: '1');
  final _emojiController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = '';
  final List<File> _selectedImages = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DataProvider>().fetchCategories());
    _salePriceController.addListener(_onPriceChanged);
    _purchasePriceController.addListener(_onPriceChanged);

    if (widget.initialProduct != null) {
      _nameController.text = widget.initialProduct!.name;
      _skuController.text = widget.initialProduct!.sku;
      _salePriceController.text = widget.initialProduct!.salePrice.toString();
      _purchasePriceController.text = widget.initialProduct!.purchasePrice.toString();
      _stockController.text = widget.initialProduct!.stockCount.toString();
      _selectedCategory = widget.initialProduct!.category;
      _emojiController.text = widget.initialProduct!.emoji;
      _weightController.text = widget.initialProduct!.weight;
      _descriptionController.text = widget.initialProduct!.description;
      _existingImageUrls = List.from(widget.initialProduct!.imageUrls);
    }
  }

  List<String> _existingImageUrls = [];

  @override
  void dispose() {
    _salePriceController.removeListener(_onPriceChanged);
    _purchasePriceController.removeListener(_onPriceChanged);
    _nameController.dispose();
    _skuController.dispose();
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _stockController.dispose();
    _emojiController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onPriceChanged() {
    setState(() {});
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maximum 3 images allowed')));
      return;
    }

    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        for (var image in images) {
          if (_selectedImages.length < 3) {
            _selectedImages.add(File(image.path));
          }
        }
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.read<DataProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
        title: Text(widget.initialProduct == null ? 'Add New Product' : 'Edit Product'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: _StepIndicator(currentStep: _currentStep),
          ),
          Expanded(
            child: Form(key: _formKey, child: _buildStepContent(data)),
          ),
          _buildBottomButtons(data),
        ],
      ),
    );
  }

  Widget _buildStepContent(DataProvider data) {
    switch (_currentStep) {
      case 0:
        return _buildInfoStep(data);
      case 1:
        return _buildPriceStep();
      case 2:
        return _buildMediaStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoStep(DataProvider data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          const Text(
            'Product Name',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'e.g. Premium Basmati Rice',
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'Product name is required'
                : null,
          ),
          const SizedBox(height: 24),
          const Text(
            'Category',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            readOnly: true,
            onTap: () => _showCategoryBottomSheet(context, data),
            decoration: InputDecoration(
              hintText: 'Select category',
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.textDark,
              ),
              errorStyle: const TextStyle(color: Colors.red),
            ),
            controller: TextEditingController(text: _selectedCategory),
            validator: (value) =>
                _selectedCategory.isEmpty ? 'Please select a category' : null,
            key: ValueKey(_selectedCategory),
          ),
          const SizedBox(height: 24),
          const Text(
            'SKU Code',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _skuController,
            decoration: const InputDecoration(
              hintText: 'e.g. W-402 (Optional)',
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Product Emoji',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emojiController,
            decoration: const InputDecoration(
              hintText: 'e.g. 🍎',
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Weight / Unit',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(
              hintText: 'e.g. 1 kg, 500g, or 1 unit',
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter product description...',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryBottomSheet(BuildContext context, DataProvider data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryBottomSheet(
        data: data,
        selectedCategory: _selectedCategory,
        onSelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
          Navigator.pop(context);
        },
        onAddNew: _navigateToAddCategory,
      ),
    );
  }

  Widget _buildPriceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set your purchase and sale prices to calculate profit/loss.',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 32),
          const Text(
            'Purchase Price (PKR)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _purchasePriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Rs 0.00'),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Purchase price is required';
              if (double.tryParse(value) == null) return 'Enter a valid number';
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Sale Price (PKR)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _salePriceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Rs 0.00'),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Sale price is required';
              if (double.tryParse(value) == null) return 'Enter a valid number';
              return null;
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Initial Stock Quantity',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _quantityButton(Icons.remove, () {
                int val = int.tryParse(_stockController.text) ?? 1;
                if (val > 0) _stockController.text = (val - 1).toString();
              }),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stockController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '0'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (int.tryParse(value) == null) return 'Invalid';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              _quantityButton(Icons.add, () {
                int val = int.tryParse(_stockController.text) ?? 0;
                _stockController.text = (val + 1).toString();
              }),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.bgGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profit Calculation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (context) {
                          final sale =
                              double.tryParse(_salePriceController.text) ?? 0;
                          final purchase =
                              double.tryParse(_purchasePriceController.text) ??
                              0;
                          final profit = sale - purchase;
                          return Text(
                            profit >= 0
                                ? 'Estimated profit per unit: Rs ${profit.toStringAsFixed(2)}'
                                : 'Warning: Potential loss of Rs ${(-profit).toStringAsFixed(2)} per unit',
                            style: TextStyle(
                              color: profit >= 0 ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGrey),
        ),
        child: Icon(icon, color: AppTheme.textDark, size: 20),
      ),
    );
  }

  Widget _buildMediaStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Media',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload high-quality images of your product to showcase it to customers.',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 32),
          const Text(
            'Product Images',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildUploadBox(),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(DataProvider data) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 56),
                side: const BorderSide(color: AppTheme.borderGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == 0 ? 'Cancel' : 'Back',
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _handleNext(data),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                minimumSize: const Size(0, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep == 2 
                          ? (widget.initialProduct == null ? 'Add Product' : 'Update Product')
                          : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext(DataProvider data) async {
    if (_formKey.currentState!.validate()) {
      if (_currentStep < 2) {
        _nextStep();
      } else {
        setState(() => _isLoading = true);
        try {
          if (widget.initialProduct == null) {
            await data.addProduct(
              _nameController.text,
              _selectedCategory,
              double.tryParse(_salePriceController.text) ?? 0.0,
              double.tryParse(_purchasePriceController.text) ?? 0.0,
              _skuController.text,
              stock: int.tryParse(_stockController.text) ?? 1,
              emoji: _emojiController.text,
              weight: _weightController.text,
              description: _descriptionController.text,
              imageFilePaths: _selectedImages.map((e) => e.path).toList(),
            );
          } else {
            await data.updateProduct(
              widget.initialProduct!.id,
              _nameController.text,
              double.tryParse(_salePriceController.text) ?? 0.0,
              double.tryParse(_purchasePriceController.text) ?? 0.0,
              int.tryParse(_stockController.text) ?? 1,
              category: _selectedCategory,
              sku: _skuController.text,
              emoji: _emojiController.text,
              weight: _weightController.text,
              description: _descriptionController.text,
              imageUrls: _existingImageUrls,
              newImageFilePaths: _selectedImages.map((e) => e.path).toList(),
            );
          }
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.initialProduct == null ? 'Product added successfully' : 'Product updated successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error saving product: $e')));
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    }
  }

  void _navigateToAddCategory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
    );
    if (result != null && result is String) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  Widget _buildUploadBox() {
    final totalImages = _existingImageUrls.length + _selectedImages.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (totalImages > 0)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  totalImages + (totalImages < 3 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == totalImages) {
                  return _buildAddMoreButton();
                }
                
                final isExisting = index < _existingImageUrls.length;
                final imageUrl = isExisting ? _existingImageUrls[index] : null;
                final file = !isExisting ? _selectedImages[index - _existingImageUrls.length] : null;

                return Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderGrey),
                        image: DecorationImage(
                          image: isExisting 
                              ? (imageUrl!.startsWith('http') 
                                  ? NetworkImage(imageUrl) as ImageProvider 
                                  : FileImage(File(imageUrl)))
                              : FileImage(file!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: index == 0
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Cover',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 16,
                      top: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isExisting) {
                              _existingImageUrls.removeAt(index);
                            } else {
                              _selectedImages.removeAt(index - _existingImageUrls.length);
                            }
                          });
                        },
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        else
          InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.bgGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderGrey),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: AppTheme.textGrey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload Images',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const Text(
                    'Max 3 images',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: AppTheme.bgGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderGrey,
            style: BorderStyle.solid,
          ),
        ),
        child: const Icon(Icons.add_a_photo_outlined, color: AppTheme.textGrey),
      ),
    );
  }
}

class _CategoryBottomSheet extends StatefulWidget {
  final DataProvider data;
  final String selectedCategory;
  final Function(String) onSelected;
  final VoidCallback onAddNew;

  const _CategoryBottomSheet({
    required this.data,
    required this.selectedCategory,
    required this.onSelected,
    required this.onAddNew,
  });

  @override
  State<_CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<_CategoryBottomSheet> {
  String _searchQuery = '';
  late List<String> _filteredCategories;

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.data.categories;
  }

  void _filterCategories(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCategories = widget.data.categories
          .where((c) => c.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const Text(
                  'Select Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              autofocus: true,
              onChanged: _filterCategories,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                fillColor: AppTheme.bgGrey,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filteredCategories.length,
              itemBuilder: (context, index) {
                final category = _filteredCategories[index];
                final isSelected = category == widget.selectedCategory;
                return ListTile(
                  title: Text(
                    category,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : AppTheme.textDark,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryGreen,
                        )
                      : null,
                  onTap: () => widget.onSelected(category),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onAddNew();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Add New Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepDot(
          label: 'INFO',
          isActive: currentStep >= 0,
          isCurrent: currentStep == 0,
          index: 1,
        ),
        _StepLine(isActive: currentStep >= 1),
        _StepDot(
          label: 'PRICE',
          isActive: currentStep >= 1,
          isCurrent: currentStep == 1,
          index: 2,
        ),
        _StepLine(isActive: currentStep >= 2),
        _StepDot(
          label: 'MEDIA',
          isActive: currentStep >= 2,
          isCurrent: currentStep == 2,
          index: 3,
        ),
      ],
    );
  }

  Widget _StepDot({
    required String label,
    required bool isActive,
    required bool isCurrent,
    required int index,
  }) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 32 : 24,
          height: isCurrent ? 32 : 24,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryGreen : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppTheme.primaryGreen : AppTheme.borderGrey,
              width: 2,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isActive && !isCurrent
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    index.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.white : AppTheme.textGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppTheme.textDark : AppTheme.textGrey,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _StepLine({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 18),
      color: isActive ? AppTheme.primaryGreen : AppTheme.borderGrey,
    );
  }
}
