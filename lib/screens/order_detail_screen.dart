import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'PKR ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Order #${order.orderNumber ?? order.id.substring(0, 8)}'),
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
                  Icon(
                    Icons.info_outline,
                    color: _getStatusColor(order.status),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STATUS: ${_getStatusText(order.status).toUpperCase()}',
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            if (order.orderNumber != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  'Trace ID: ${order.orderNumber}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textGrey,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: order.deliveryType.toLowerCase() == 'express' 
                                    ? Colors.amber.withOpacity(0.2) 
                                    : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.deliveryType.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: order.deliveryType.toLowerCase() == 'express' 
                                      ? Colors.orange[800] 
                                      : Colors.blue[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context, order),
            const SizedBox(height: 32),

            const Text(
              'CUSTOMER INFO',
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              order.customerName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.address,
                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'ORDERED ITEMS',
              style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...order.items
                .map((item) => _buildItemTile(item, currencyFormat))
                .toList(),

            if (order.paymentProofUrl != null) ...[
              const SizedBox(height: 32),
              const Text(
                'PAYMENT PROOF',
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.bgGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.payment_rounded, size: 16, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Payment via ${order.paymentMethod ?? "Online Bank"}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: Stack(
                              children: [
                                InteractiveViewer(
                                  child: Image.network(order.paymentProofUrl!),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black.withOpacity(0.5),
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          order.paymentProofUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.red[50],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                Text('Failed to load image', style: TextStyle(color: Colors.red, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Tap to view full screen',
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  currencyFormat.format(order.amount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 20,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Quantity: ${item.quantity}',
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            format.format(item.price * item.quantity),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Order order) {
    if (order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    final provider = context.read<DataProvider>();

    String nextLabel = '';
    OrderStatus nextStatus = order.status;
    IconData icon = Icons.check_circle_outline;

    switch (order.status) {
      case OrderStatus.placed:
        nextLabel = 'Confirm Order';
        nextStatus = OrderStatus.confirmed;
        icon = Icons.assignment_turned_in_outlined;
        break;
      case OrderStatus.confirmed:
        nextLabel = 'Pack Items';
        nextStatus = OrderStatus.packed;
        icon = Icons.inventory_2_outlined;
        break;
      case OrderStatus.packed:
        nextLabel = 'Out for Delivery';
        nextStatus = OrderStatus.outForDelivery;
        icon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.outForDelivery:
        nextLabel = 'Mark Delivered';
        nextStatus = OrderStatus.delivered;
        icon = Icons.home_outlined;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => provider.updateOrderStatus(order.id, nextStatus),
            icon: Icon(icon),
            label: Text(nextLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () =>
              provider.updateOrderStatus(order.id, OrderStatus.cancelled),
          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
          tooltip: 'Cancel Order',
        ),
      ],
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.packed:
        return 'Items Packed';
      case OrderStatus.outForDelivery:
        return 'Out For Delivry';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return Colors.blue;
      case OrderStatus.confirmed:
        return Colors.indigo;
      case OrderStatus.packed:
        return Colors.orange;
      case OrderStatus.outForDelivery:
        return Colors.deepPurple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}
