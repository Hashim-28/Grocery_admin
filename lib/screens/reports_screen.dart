import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/app_theme.dart';
import '../providers/data_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'Today';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgGrey,
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        actions: [
          IconButton(icon: const Icon(Icons.download_outlined), onPressed: () {}),
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
              subtitle: 'Total PKR 1.2M this ${_selectedPeriod.toLowerCase().replaceAll('ly', '')}',
              chart: _buildPieChart(),
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
              child: Column(
                children: [
                  _buildTableTile('Category', 'Total Items', 'Revenue', isHeader: true),
                  _buildTableTile('Groceries', '124', 'PKR 450,000'),
                  _buildTableTile('Electronics', '45', 'PKR 820,000'),
                  _buildTableTile('Apparel', '89', 'PKR 310,000'),
                  _buildTableTile('Others', '12', 'PKR 45,000'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Report Types
            const Text('GENERATED REPORTS', style: TextStyle(color: AppTheme.textGrey, fontSize: 13, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildReportTile(Icons.description_outlined, 'Monthly Sales Summary', 'PDF • 2.4 MB'),
            _buildReportTile(Icons.inventory_2_outlined, 'Inventory Audit Log', 'Excel • 1.1 MB'),
            _buildReportTile(Icons.people_outline, 'Staff Performance', 'PDF • 850 KB'),
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
          Expanded(child: Text(c1, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
          Expanded(child: Text(c2, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 13), textAlign: TextAlign.center)),
          Expanded(child: Text(c3, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 13, color: isHeader ? Colors.black : AppTheme.primaryGreen), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildChartCard({required String title, required String subtitle, required Widget chart}) {
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
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 40, color: AppTheme.primaryGreen, radius: 50, title: '40%', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          PieChartSectionData(value: 30, color: AppTheme.accentGreen, radius: 45, title: '30%', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          PieChartSectionData(value: 20, color: const Color(0xFF0F172A), radius: 40, title: '20%', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          PieChartSectionData(value: 10, color: Colors.orange, radius: 35, title: '10%', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildReportTile(IconData icon, String title, String meta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: ListTile(
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
