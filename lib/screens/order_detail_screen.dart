import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Order #${order.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _getStatusColor(order.status)),
                  const SizedBox(width: 12),
                  Text(
                    'This order is currently ${order.status.name.toUpperCase()}',
                    style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text('CUSTOMER INFO', style: TextStyle(color: AppTheme.textGrey, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(order.customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Expanded(child: Text(order.address, style: const TextStyle(color: AppTheme.textGrey, fontSize: 14))),
              ],
            ),
            const SizedBox(height: 32),

            const Text('ORDERED ITEMS', style: TextStyle(color: AppTheme.textGrey, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...order.items.map((item) => _buildItemTile(item, currencyFormat)).toList(),

            const Divider(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(currencyFormat.format(order.amount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(OrderItem item, NumberFormat format) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.inventory_2_outlined, size: 20, color: AppTheme.textGrey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Quantity: ${item.quantity}', style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Text(format.format(item.price * item.quantity), style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.dispatched: return Colors.green;
      case OrderStatus.cancelled: return Colors.red;
    }
  }
}
