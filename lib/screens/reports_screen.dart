import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_theme.dart';
import '../providers/data_provider.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Today';

  List<Order> _getFilteredOrders(List<Order> allOrders) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'Weekly':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Monthly':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Yearly':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case 'Today':
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    return allOrders.where((order) => order.time.isAfter(startDate)).toList();
  }

  Future<void> _exportToCSV(List<Order> filteredOrders, List<Product> products) async {
    try {
      // Create detailed summary
      List<List<dynamic>> rows = [];
      
      // Header row
      rows.add([
        "Order ID",
        "Date",
        "Customer Name",
        "Delivery Status",
        "Item Name",
        "Category",
        "Quantity",
        "Sale Price (PKR)",
        "Purchase Price (PKR)",
        "Item Revenue (PKR)",
        "Item Profit (PKR)"
      ]);

      // Product lookup map
      Map<String, Product> productMap = {for (var p in products) p.name: p};

      double totalRevenue = 0;
      double totalProfit = 0;

      for (var order in filteredOrders) {
        String orderId = order.orderNumber ?? order.id;
        String date = DateFormat('yyyy-MM-dd HH:mm').format(order.time);
        String customer = order.customerName;
        String status = order.status.name;

        for (var item in order.items) {
          double purchasePrice = productMap[item.name]?.purchasePrice ?? 0;
          double itemRevenue = item.price * item.quantity;
          double itemProfit = (item.price - purchasePrice) * item.quantity;
          String category = productMap[item.name]?.category ?? 'Uncategorized';
          
          rows.add([
            orderId,
            date,
            customer,
            status,
            item.name,
            category,
            item.quantity,
            item.price,
            purchasePrice,
            itemRevenue,
            itemProfit,
          ]);

          totalRevenue += itemRevenue;
          totalProfit += itemProfit;
        }
      }

      // Add summary rows at the end
      rows.add([]);
      rows.add(["SUMMARY"]);
      rows.add(["Total Period Revenue (PKR)", totalRevenue]);
      rows.add(["Total Period Profit (PKR)", totalProfit]);
      rows.add(["Total Orders Count", filteredOrders.length]);

      String csvData = csv.encode(rows);

      final directory = await getApplicationDocumentsDirectory();
      final pathOfTheFileToWriteTo = "${directory.path}/reports_${_selectedPeriod.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.csv";
      File file = File(pathOfTheFileToWriteTo);
      await file.writeAsString(csvData);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(pathOfTheFileToWriteTo)],
          text: 'Detailed CSV Report for $_selectedPeriod',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final filteredOrders = _getFilteredOrders(data.orders);
    
    // Calculate metrics based on the filtered orders
    double totalRevenue = 0;
    Map<String, double> categoryRevenues = {};
    Map<String, int> categoryItemsCount = {};

    Map<String, String> productCategoryMap = {for (var p in data.products) p.name: p.category};

    for (var order in filteredOrders) {
      for (var item in order.items) {
        double itemRevenue = item.price * item.quantity;
        totalRevenue += itemRevenue;
        
        String cat = productCategoryMap[item.name] ?? 'Others';
        categoryRevenues[cat] = (categoryRevenues[cat] ?? 0) + itemRevenue;
        categoryItemsCount[cat] = (categoryItemsCount[cat] ?? 0) + item.quantity;
      }
    }

    // Prepare pie chart sections dynamically
    List<PieChartSectionData> pieSections = [];
    final colors = [
      AppTheme.primaryGreen,
      AppTheme.accentGreen,
      const Color(0xFF0F172A),
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.pink,
      Colors.teal
    ];

    int colorIndex = 0;
    categoryRevenues.forEach((cat, rev) {
      if (rev > 0 && totalRevenue > 0) {
        double percentage = (rev / totalRevenue) * 100;
        pieSections.add(
          PieChartSectionData(
            value: percentage,
            color: colors[colorIndex % colors.length],
            radius: percentage > 20 ? 50 : 40,
            title: '${percentage.toStringAsFixed(1)}%',
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        );
        colorIndex++;
      }
    });

    if (pieSections.isEmpty) {
      pieSections.add(PieChartSectionData(
        value: 100,
        color: Colors.grey.shade300,
        radius: 40,
        title: '0%',
        titleStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
      ));
    }

    String formattedRevenue = NumberFormat.compactCurrency(symbol: 'PKR ', decimalDigits: 2).format(totalRevenue);

    return Scaffold(
      backgroundColor: AppTheme.bgGrey,
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => _exportToCSV(filteredOrders, data.products),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   _PeriodChip(
                     label: 'Today', 
                     isSelected: _selectedPeriod == 'Today',
                     onTap: () => setState(() => _selectedPeriod = 'Today'),
                   ),
                   const SizedBox(width: 8),
                   _PeriodChip(
                     label: 'Weekly', 
                     isSelected: _selectedPeriod == 'Weekly',
                     onTap: () => setState(() => _selectedPeriod = 'Weekly'),
                   ),
                   const SizedBox(width: 8),
                   _PeriodChip(
                     label: 'Monthly', 
                     isSelected: _selectedPeriod == 'Monthly',
                     onTap: () => setState(() => _selectedPeriod = 'Monthly'),
                   ),
                   const SizedBox(width: 8),
                   _PeriodChip(
                     label: 'Yearly', 
                     isSelected: _selectedPeriod == 'Yearly',
                     onTap: () => setState(() => _selectedPeriod = 'Yearly'),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sales Chart
            _buildChartCard(
              title: 'Revenue Distribution',
              subtitle: 'Total $formattedRevenue this ${_selectedPeriod.toLowerCase()}',
              chart: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
              categories: categoryRevenues.keys.toList(),
              colors: colors,
            ),
            const SizedBox(height: 16),

            // Detailed Report Table
            const Text('SALES BREAKDOWN', style: TextStyle(color: AppTheme.textGrey, fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderGrey),
              ),
              child: categoryRevenues.isEmpty
                  ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No sales data for this period.")))
                  : Column(
                      children: [
                        _buildTableTile('Category', 'Items', 'Revenue', isHeader: true),
                        ...categoryRevenues.entries.map((entry) {
                          String catName = entry.key;
                          String revStr = NumberFormat.compactCurrency(symbol: 'PKR ', decimalDigits: 1).format(entry.value);
                          String countStr = categoryItemsCount[catName]?.toString() ?? '0';
                          return _buildTableTile(catName, countStr, revStr);
                        }),
                      ],
                    ),
            ),
            const SizedBox(height: 32),

            // Report Types
            const Text('GENERATED REPORTS', style: TextStyle(color: AppTheme.textGrey, fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildReportTile(
              icon: Icons.description_outlined,
              title: 'Detailed Period Summary',
              meta: 'CSV Document • Dynamic',
              onTap: () => _exportToCSV(filteredOrders, data.products),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableTile(String c1, String c2, String c3, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderGrey, width: isHeader ? 2 : 1)),
        color: isHeader ? AppTheme.bgGrey.withOpacity(0.5) : Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(c1, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 13), overflow: TextOverflow.ellipsis)),
          Expanded(child: Text(c2, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 13), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(c3, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 13, color: isHeader ? Colors.black : AppTheme.primaryGreen), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildChartCard({required String title, required String subtitle, required Widget chart, required List<String> categories, required List<Color> colors}) {
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(height: 160, child: chart),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories.asMap().entries.take(5).map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[entry.key % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 10, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportTile({required IconData icon, required String title, required String meta, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.bgGrey, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppTheme.textGrey, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(meta, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
        trailing: const Icon(Icons.download, size: 20, color: AppTheme.primaryGreen),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _PeriodChip({required this.label, required this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryGreen : AppTheme.borderGrey),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : AppTheme.textGrey, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
