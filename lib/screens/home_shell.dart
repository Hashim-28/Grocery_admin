import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'orders_screen.dart';
import 'admin_console_screen.dart';
import 'reports_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<DataProvider>();
    final isAdmin = auth.role == UserRole.admin;

    final List<Map<String, dynamic>> tabs = [
      if (isAdmin) {'title': 'Home', 'icon': Icons.grid_view_rounded, 'screen': const DashboardScreen()},
      {'title': 'Orders', 'icon': Icons.receipt_long_rounded, 'screen': const OrdersScreen()},
      {'title': 'Inventory', 'icon': Icons.inventory_2_rounded, 'screen': const InventoryScreen()},
      if (isAdmin) {'title': 'Reports', 'icon': Icons.bar_chart_rounded, 'screen': const ReportsScreen()},
      if (isAdmin) {'title': 'Admin', 'icon': Icons.settings_rounded, 'screen': const AdminConsoleScreen()},
      if (!isAdmin) {'title': 'Profile', 'icon': Icons.person_outline, 'screen': const AdminConsoleScreen()}, // Added for staff to fix crash
    ];

    int safeIndex = data.currentTabIndex;
    if (safeIndex >= tabs.length) {
      safeIndex = 0;
    }

    return Scaffold(
      backgroundColor: AppTheme.bgGrey,
      body: IndexedStack(
        index: safeIndex,
        children: tabs.map<Widget>((t) => t['screen'] as Widget).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (index) => data.setTabIndex(index),
          backgroundColor: const Color(0xFF0F172A),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          items: tabs
              .map(
                (t) => BottomNavigationBarItem(
                  icon: Icon(t['icon']),
                  label: t['title'],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
