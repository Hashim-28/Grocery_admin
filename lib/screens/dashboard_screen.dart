import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';
import 'add_product_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppTheme.bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store, color: AppTheme.primaryGreen),
            ),
            const SizedBox(width: 12),
            const Text('Diesel Cash & Carry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Badge(child: Icon(Icons.notifications_outlined, color: AppTheme.textDark)),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search products, orders...',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('TODAY\'S OVERVIEW', style: TextStyle(color: AppTheme.textGrey, fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            _buildMainStatCard(currencyFormat, data.totalSales),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSmallStatCard('ACTIVE ORDERS', data.activeOrders.toString(), '+12%', Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSmallStatCard('OUT OF STOCK', data.outOfStockItems.toString(), '-5%', Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 32),

            _buildChartSection(context),
            const SizedBox(height: 32),

            const Text('QUICK ACTIONS', style: TextStyle(color: AppTheme.textGrey, fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildQuickActions(context),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RECENT ORDERS', style: TextStyle(color: AppTheme.textGrey, fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => data.setTabIndex(1), 
                  child: const Text('VIEW ALL', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12))
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentOrders(data, NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStatCard(NumberFormat format, double value) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Sales (PKR)', style: TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w500)),
              Icon(Icons.payments_outlined, color: AppTheme.accentGreen.withOpacity(0.8)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(format.format(value), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green, size: 16),
                    Text(' +12.5%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String title, String value, String trend, Color trendColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: trendColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(trend, style: TextStyle(color: trendColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Revenue Trend', style: TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('PKR 750k', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: const [
                  Text('24h growth ', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                  Icon(Icons.north_east, color: Colors.green, size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: AppTheme.textGrey, fontSize: 10);
                        switch (value.toInt()) {
                          case 0: return const Text('6am', style: style);
                          case 6: return const Text('10am', style: style);
                          case 12: return const Text('2pm', style: style);
                          case 18: return const Text('6pm', style: style);
                          case 23: return const Text('10pm', style: style);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 24,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3), FlSpot(2, 5), FlSpot(4, 4), FlSpot(6, 6),
                      FlSpot(8, 4), FlSpot(10, 5), FlSpot(12, 3), FlSpot(14, 4),
                      FlSpot(16, 7), FlSpot(18, 5), FlSpot(20, 6), FlSpot(22, 4), FlSpot(24, 6),
                    ],
                    isCurved: true,
                    color: AppTheme.accentGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.accentGreen.withOpacity(0.3),
                          AppTheme.accentGreen.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final data = context.read<DataProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _QuickAction(
          icon: Icons.add,
          label: 'New Product',
          color: AppTheme.accentGreen,
          isPrimary: true,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())),
        ),
        _QuickAction(icon: Icons.inventory_2_outlined, label: 'Inventory', color: Colors.white, onTap: () => data.setTabIndex(2)),
        _QuickAction(icon: Icons.people_outline, label: 'Staff', color: Colors.white, onTap: () => data.setTabIndex(4)),
        _QuickAction(icon: Icons.bar_chart, label: 'Reports', color: Colors.white, onTap: () => data.setTabIndex(3)),
      ],
    );
  }

  Widget _buildRecentOrders(DataProvider data, NumberFormat format) {
    final recent = data.orders.take(3).toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.length,
      itemBuilder: (context, index) {
        final order = recent[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderGrey),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.bgGrey, shape: BoxShape.circle),
                child: const Icon(Icons.shopping_cart_outlined, color: AppTheme.textGrey, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#ORD-${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Recently • 4 items', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              Text(format.format(order.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: isPrimary ? null : Border.all(color: AppTheme.borderGrey),
            ),
            child: Icon(icon, color: isPrimary ? Colors.white : AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}
