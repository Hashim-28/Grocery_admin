import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import 'dart:io';
import '../providers/data_provider.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Groceries');
  String _selectedCategory = 'Groceries';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Product'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: _StepIndicator(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Product Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),

                  const Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'e.g. Premium Basmati Rice'),
                  ),
                  const SizedBox(height: 24),

                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: _selectedCategory),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      const options = ['Groceries', 'Electronics', 'Apparel', 'Personal Care', 'Home Essentials', 'Beverages'];
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return options.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _selectedCategory = selection;
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      // Sync external controller if needed
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (value) {
                          _selectedCategory = value;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Type or select category',
                          suffixIcon: Icon(Icons.keyboard_arrow_down, color: AppTheme.textDark),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  const Text('SKU Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _skuController,
                    decoration: const InputDecoration(hintText: 'e.g. W-402'),
                  ),
                  const SizedBox(height: 24),

                  const Text('Price (PKR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Rs 0.00'),
                  ),
                  const SizedBox(height: 24),

                  const Text('Product Images', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  _buildUploadBox(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                      side: const BorderSide(color: AppTheme.borderGrey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty) {
                        data.addProduct(
                          _nameController.text,
                          _selectedCategory,
                          double.tryParse(_priceController.text) ?? 0.0,
                          _skuController.text,
                          imagePath: _selectedImage?.path,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Product added successfully')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGreen,
                      minimumSize: const Size(0, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.bgGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGrey),
          image: _selectedImage != null
              ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
              : null,
        ),
        child: _selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 40, color: AppTheme.textGrey.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  const Text('Upload Images', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 12,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 10, color: Colors.white),
                        onPressed: () => setState(() => _selectedImage = null),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepDot(label: 'INFO', isActive: true),
        _StepLine(),
        _StepDot(label: 'PRICE', isActive: false),
        _StepLine(),
        _StepDot(label: 'MEDIA', isActive: false),
      ],
    );
  }

  Widget _StepDot({required String label, required bool isActive}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 6,
          backgroundColor: isActive ? AppTheme.accentGreen : AppTheme.borderGrey,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppTheme.accentGreen : AppTheme.textGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _StepLine() {
    return Container(
      width: 40,
      height: 1,
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 18),
      color: AppTheme.borderGrey,
    );
  }
}
