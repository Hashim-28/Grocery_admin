import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  XFile? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.fullName);
    _emailController = TextEditingController(text: auth.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = image);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await context.read<AuthProvider>().updateProfile(
        fullName: _nameController.text.trim(),
        imagePath: _imageFile?.path,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final localFormKey = GlobalKey<FormState>();
    bool isUpdating = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Form(
                key: localFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter new password';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      validator: (value) {
                        if (value != newPasswordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating ? null : () => Navigator.pop(dialogContext),
                  child: const Text('CANCEL', style: TextStyle(color: AppTheme.textGrey)),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          if (localFormKey.currentState!.validate()) {
                            setStateDialog(() => isUpdating = true);
                            try {
                              await context.read<AuthProvider>().changePassword(
                                    newPasswordController.text.trim(),
                                  );
                              if (mounted) {
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password updated successfully'),
                                    backgroundColor: AppTheme.primaryGreen,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              setStateDialog(() => isUpdating = false);
                            }
                          }
                        },
                  child: isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('UPDATE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.role == UserRole.admin;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('MY PROFILE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Center(
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                        backgroundImage: _imageFile != null
                            ? FileImage(File(_imageFile!.path))
                            : (auth.photoUrl != null
                                ? NetworkImage(auth.photoUrl!)
                                : null) as ImageProvider?,
                        child: _imageFile == null && auth.photoUrl == null
                            ? const Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: AppTheme.primaryGreen,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  isAdmin ? 'Super Administrator' : 'Staff Member',
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Inputs
              const Text(
                'Full Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: 24),

              const Text(
                'Email Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                enabled:
                    false, // Email should not be updated as per user request
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.bgGrey,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Email cannot be changed from here. Please contact support if needed.',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),

              // Action Buttons
              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('SAVE CHANGES'),
                ),

              const SizedBox(height: 24),

              // Change Password Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderGrey),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: AppTheme.textGrey,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Change Password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showChangePasswordDialog(context),
                      child: const Text('UPDATE'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
