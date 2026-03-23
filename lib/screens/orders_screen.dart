import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_theme.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.role == UserRole.admin;

    final pendingCount = data.orders.where((o) => o.status == OrderStatus.pending).length;
    final dispatchedCount = data.orders.where((o) => o.status == OrderStatus.dispatched).length;
    final cancelledCount = data.orders.where((o) => o.status == OrderStatus.cancelled).length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.bgGrey,
        appBar: AppBar(
          title: const Text('Orders Management'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Column(
              children: [
                TabBar(
                  indicatorColor: AppTheme.primaryGreen,
                  labelColor: AppTheme.primaryGreen,
                  unselectedLabelColor: AppTheme.textGrey,
                  tabs: [
                    Tab(text: 'Pending ($pendingCount)'),
                    Tab(text: 'Dispatched ($dispatchedCount)'),
                    Tab(text: 'Cancelled ($cancelledCount)'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search Order ID or Name',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            if (!isAdmin)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.orange.withOpacity(0.1),
                child: Row(
                  children: const [
                    Icon(Icons.lock_person_outlined, size: 14, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Staff View: Restricted Access', style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            const Expanded(
              child: TabBarView(
                children: [
                  _OrdersList(status: OrderStatus.pending),
                  _OrdersList(status: OrderStatus.dispatched),
                  _OrdersList(status: OrderStatus.cancelled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final OrderStatus status;
  const _OrdersList({required this.status});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.role == UserRole.admin;
    final currencyFormat = NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

    final filteredOrders = data.orders.where((o) => o.status == status).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No ${status.name} orders', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderGrey),
          ),
          child: Stack(
            children: [
              InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 24, 16), // Extra right padding
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.05),
                        radius: 24,
                        child: const Icon(Icons.person, color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Order ID: #${order.id}',
                              style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(order.amount),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (status == OrderStatus.pending)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ElevatedButton(
                            onPressed: () {
                              data.dispatchOrder(order.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Order #${order.id} dispatched')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              minimumSize: const Size(80, 40),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('DISPATCH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (status == OrderStatus.pending && isAdmin)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Cancel Order'),
                          content: const Text('Do you really want to cancel this order?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                data.cancelOrder(order.id);
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Order #${order.id} cancelled')),
                                );
                              },
                              child: const Text('Yes', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 1),
                      ),
                      child: const Icon(Icons.close, size: 12, color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
