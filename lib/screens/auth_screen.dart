import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _keyController = TextEditingController();
  UserRole _selectedRole = UserRole.none;
  bool _isPasswordVisible = false;

  void _handleLogin() {
    if (_selectedRole == UserRole.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your role first')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      context.read<AuthProvider>().login(
            _selectedRole,
            _idController.text,
            _keyController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final placeholderStyle = TextStyle(color: AppTheme.textGrey.withOpacity(0.35));

    return Scaffold(
      backgroundColor: AppTheme.bgGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.admin_panel_settings, color: AppTheme.primaryGreen),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'DIESEL CASH & CARRY',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),

                // Greeting
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Secure Login',
                        style: theme.textTheme.displayLarge?.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Select your role and enter credentials to\naccess the console.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textGrey, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Role Selection
                const Text('Select Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        role: UserRole.admin,
                        currentSelected: _selectedRole,
                        label: 'Admin',
                        icon: Icons.shield_outlined,
                        onTap: () => setState(() => _selectedRole = UserRole.admin),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RoleCard(
                        role: UserRole.staff,
                        currentSelected: _selectedRole,
                        label: 'Staff',
                        icon: Icons.person_outline,
                        onTap: () => setState(() => _selectedRole = UserRole.staff),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Identifier Field
                const Text('Identifier', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    hintText: 'email or phone',
                    hintStyle: placeholderStyle,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (value) => value!.isEmpty ? 'Identifier is required' : null,
                ),
                const SizedBox(height: 24),

                // Security Key Field
                const Text('Security Key', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _keyController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: '••••••••••••',
                    hintStyle: placeholderStyle,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, size: 20),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Security key is required';
                    if (value.length < 6) return 'Minimum 6 characters required';
                    return null;
                  },
                ),
                const SizedBox(height: 48),

                // Login Button
                ElevatedButton.icon(
                  onPressed: auth.isLoading ? null : _handleLogin,
                  icon: const Icon(Icons.login),
                  label: auth.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Authenticate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 80),

                // Footer
                const Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security, size: 14, color: AppTheme.textGrey),
                          SizedBox(width: 8),
                          Text('End-to-end encrypted session', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '© 2024 Diesel Cash & Carry Admin Panel v4.2.0',
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final UserRole currentSelected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.currentSelected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = role == currentSelected;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderGrey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppTheme.textGrey),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
