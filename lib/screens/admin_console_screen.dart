import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_theme.dart';
import 'manage_staff_screen.dart';
import 'delivery_settings_screen.dart';
import 'payment_accounts_screen.dart';
import 'manage_deals_screen.dart';
import 'profile_screen.dart';
import 'support_center_screen.dart';
import 'manage_categories_screen.dart';

class AdminConsoleScreen extends StatelessWidget {
  const AdminConsoleScreen({super.key});

  void _showChangePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Current Password'),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                    ),
                  );
                },
                child: const Text('Update Password'),
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: const [
            Text(
              'ADMIN CONSOLE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'DIESEL CASH & CARRY',
              style: TextStyle(
                fontSize: 9,
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.bgGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderGrey),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryGreen,
                    backgroundImage: auth.photoUrl != null
                        ? NetworkImage(auth.photoUrl!)
                        : null,
                    child: auth.photoUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.fullName ?? 'Admin User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          auth.role == UserRole.admin
                              ? 'Super Administrator'
                              : 'Staff Member',
                          style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.email ?? 'admin@diesel.com',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Security Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.verified_user,
                      color: AppTheme.accentGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'High Security Mode Active',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Session encrypted and monitored',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Access Control Section
            const _SectionHeader(title: 'MY ACCOUNT'),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Icons.person_outline_rounded,
              label: 'Personal Information',
              subtitle: 'Update your name and profile details',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            const SizedBox(height: 12),
            const _SectionHeader(title: 'ACCESS CONTROL'),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Icons.lock_outline,
              label: 'Change Password',
              subtitle: 'Last updated 14 days ago',
              onTap: () => _showChangePassword(context),
            ),
            if (auth.role == UserRole.admin) ...[
              const SizedBox(height: 12),
              _SettingTile(
                icon: Icons.group_outlined,
                label: 'Manage Staff',
                subtitle: '8 active administrators',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageStaffScreen()),
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Store Settings Section
            const _SectionHeader(title: 'STORE SETTINGS'),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Icons.category_outlined,
              label: 'Category Settings',
              subtitle: 'Manage product categories, icons & sorting',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageCategoriesScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Icons.local_shipping_outlined,
              label: 'Delivery Information',
              subtitle: 'Charges, thresholds & delivery options',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeliverySettingsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Icons.account_balance_outlined,
              label: 'Online Payment Settings',
              subtitle: 'Manage bank accounts for customer payments',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentAccountsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Icons.local_offer_outlined,
              label: 'Deals & Bundles',
              subtitle: 'Create multi-product discounted offers',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ManageDealsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SettingTile(
              icon: Icons.support_agent_rounded,
              label: 'Support / Help Center',
              subtitle: 'Manage FAQs, contact info & about app',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SupportCenterScreen(),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Terminate Session Button
            OutlinedButton.icon(
              onPressed: () => context.read<AuthProvider>().logout(),
              icon: const Icon(Icons.logout, color: AppTheme.textGrey),
              label: const Text(
                'TERMINATE SESSION',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: AppTheme.borderGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textGrey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey.withOpacity(0.5)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.borderGrey,
          size: 20,
        ),
      ),
    );
  }
}
