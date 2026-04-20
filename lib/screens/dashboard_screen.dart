import 'package:flutter/material.dart';
import 'package:grocery_app_admin/screens/notifications_screen.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 0);
    final pkrFormat = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

    final filteredOrders = _searchQuery.isEmpty
        ? data.orders.take(5).toList()
        : data.orders
              .where(
                (o) =>
                    o.customerName.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    o.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    (o.orderNumber?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false) ||
                    o.items.any(
                      (item) => item.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    ),
              )
              .toList();

    // Sort orders by time descending (newest first)
    filteredOrders.sort((a, b) => b.time.compareTo(a.time));

    final filteredProducts = _searchQuery.isEmpty
        ? []
        : data.products
              .where(
                (p) =>
                    p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    p.sku.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

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
            const Text(
              'Diesel Cash & Carry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Badge(
              child: Icon(
                Icons.notifications_outlined,
                color: AppTheme.textDark,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminNotificationScreen(),
                ),
              );
            },
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
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search products, orders...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_searchQuery.isNotEmpty) ...[
              if (filteredProducts.isNotEmpty) ...[
                const Text(
                  'MATCHING PRODUCTS',
                  style: TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 13,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
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
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.bgGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'SKU: ${product.sku} • ${product.category}',
                                  style: const TextStyle(
                                    color: AppTheme.textGrey,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            pkrFormat.format(product.salePrice),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              const Text(
                'MATCHING ORDERS',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (filteredOrders.isEmpty)
                const Center(
                  child: Text(
                    'No matching orders found',
                    style: TextStyle(color: AppTheme.textGrey),
                  ),
                )
              else
                _buildOrderList(filteredOrders, pkrFormat),
              const SizedBox(height: 40),

              const Divider(),
              const SizedBox(height: 20),
            ],

            if (_searchQuery.isEmpty) ...[
              const Text(
                'TODAY\'S OVERVIEW',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildMainStatCard(currencyFormat, data.totalSales),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildSmallStatCard(
                      'ACTIVE ORDERS',
                      data.activeOrders.toString(),
                      '+12%',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSmallStatCard(
                      'OUT OF STOCK',
                      data.outOfStockItems.toString(),
                      '-5%',
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _buildChartSection(context),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RECENT ORDERS',
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 13,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => data.setTabIndex(1),
                    child: const Text(
                      'VIEW ALL',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildOrderList(data.orders.take(5).toList(), pkrFormat),
            ],
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
              const Text(
                'Total Sales (PKR)',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.payments_outlined,
                color: AppTheme.accentGreen.withOpacity(0.8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                format.format(value),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green, size: 16),
                    Text(
                      ' +12.5%',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(
    String title,
    String value,
    String trend,
    Color trendColor,
  ) {
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
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    final data = context.watch<DataProvider>();
    final revenueData = data.monthlyRevenueTrend;
    final currencyFormat = NumberFormat.simpleCurrency(
      name: 'PKR',
      decimalDigits: 0,
    );

    double maxRevenue = revenueData.reduce((a, b) => a > b ? a : b);
    if (maxRevenue == 0) maxRevenue = 1000;

    List<FlSpot> spots = [];
    for (int i = 0; i < revenueData.length; i++) {
      spots.add(FlSpot(i.toDouble(), revenueData[i]));
    }

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
                children: [
                  const Text(
                    'Monthly Revenue Trend',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Peak: ${currencyFormat.format(maxRevenue)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Text(
                    'This Year ',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.green,
                    size: 14,
                  ),
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
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 10,
                        );
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        int index = value.toInt();
                        if (index >= 0 && index < 12) {
                          // Show every 2nd month to avoid crowding
                          if (index % 2 == 0)
                            return Text(months[index], style: style);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: maxRevenue * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
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

  Widget _buildOrderList(List<Order> orders, NumberFormat format) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
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
                decoration: BoxDecoration(
                  color: AppTheme.bgGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  color: AppTheme.textGrey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#ORD-${order.id.split('-')[0].toUpperCase()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.customerName} • ${DateFormat('MMM dd').format(order.time)}',
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                format.format(order.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
