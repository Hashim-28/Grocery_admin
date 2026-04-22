import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_theme.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
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
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.role == UserRole.admin;

    final pendingCount = data.orders.where((o) => 
      o.status == OrderStatus.placed || o.status == OrderStatus.confirmed || o.status == OrderStatus.packed).length;
    final dispatchedCount = data.orders.where((o) => o.status == OrderStatus.outForDelivery).length;
    final historyCount = data.orders.where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.cancelled).length;

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
                    Tab(text: 'History ($historyCount)'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search Order ID, Name, or Item',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear), 
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            }
                          ) 
                        : null,
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
            Expanded(
              child: TabBarView(
                children: [
                  _OrdersList(
                    statuses: const [OrderStatus.placed, OrderStatus.confirmed, OrderStatus.packed],
                    searchQuery: _searchQuery,
                  ),
                  _OrdersList(
                    statuses: const [OrderStatus.outForDelivery],
                    searchQuery: _searchQuery,
                  ),
                  _OrdersList(
                    statuses: const [OrderStatus.delivered, OrderStatus.cancelled],
                    searchQuery: _searchQuery,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatefulWidget {
  final List<OrderStatus> statuses;
  final String searchQuery;
  const _OrdersList({required this.statuses, required this.searchQuery});

  @override
  State<_OrdersList> createState() => _OrdersListState();
}

class _OrdersListState extends State<_OrdersList> {
  final Set<String> _updatingOrderIds = {};

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.role == UserRole.admin;
    final currencyFormat =
        NumberFormat.currency(symbol: 'PKR ', decimalDigits: 0);

    final filteredOrders = data.orders.where((o) {
      final matchesStatus = widget.statuses.contains(o.status);
      if (!matchesStatus) return false;

      if (widget.searchQuery.isEmpty) return true;

      final query = widget.searchQuery.toLowerCase();
      final matchesName = o.customerName.toLowerCase().contains(query);
      final matchesId = o.id.toString().toLowerCase().contains(query);
      final matchesOrderNum =
          (o.orderNumber?.toLowerCase().contains(query) ?? false);
      final matchesItems =
          o.items.any((item) => item.name.toLowerCase().contains(query));

      return matchesName || matchesId || matchesOrderNum || matchesItems;
    }).toList();

    // Sort by time descending (newest first)
    filteredOrders.sort((a, b) => b.time.compareTo(a.time));

    if (data.isOrdersLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            if (widget.searchQuery.isEmpty) ...[
              ElevatedButton.icon(
                onPressed: () => data.fetchOrders(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('RETRY FETCH'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Debug section to help identify RLS issues
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text('DEBUG INFO (For Developer)',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('App Role: ${auth.role.toString().split('.').last}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(
                        'Supabase ID: ${Supabase.instance.client.auth.currentUser?.id ?? 'None'}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(
                        'Supabase Role: ${Supabase.instance.client.auth.currentUser?.role ?? 'None'}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => data.fetchOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          final isUpdating = _updatingOrderIds.contains(order.id);

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
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(order: order))),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen.withOpacity(0.05),
                          radius: 24,
                          child: const Icon(Icons.person,
                              color: AppTheme.primaryGreen),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.customerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Order #: ${order.orderNumber ?? order.id}',
                                style: const TextStyle(
                                    color: AppTheme.textGrey, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormat.format(order.amount),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (widget.statuses.contains(OrderStatus.placed) ||
                            widget.statuses.contains(OrderStatus.confirmed) ||
                            widget.statuses.contains(OrderStatus.packed))
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ElevatedButton(
                              onPressed: isUpdating
                                  ? null
                                  : () async {
                                      setState(() {
                                        _updatingOrderIds.add(order.id);
                                      });
                                      try {
                                        if (order.status == OrderStatus.placed) {
                                          await data.updateOrderStatus(
                                              order.id, OrderStatus.confirmed);
                                        } else if (order.status ==
                                            OrderStatus.confirmed) {
                                          await data.updateOrderStatus(
                                              order.id, OrderStatus.packed);
                                        } else {
                                          await data.updateOrderStatus(order.id,
                                              OrderStatus.outForDelivery);
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _updatingOrderIds.remove(order.id);
                                          });
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                minimumSize: const Size(90, 40),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: isUpdating
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      order.status == OrderStatus.placed
                                          ? 'CONFIRM'
                                          : (order.status == OrderStatus.confirmed
                                              ? 'PACK'
                                              : 'DISPATCH'),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if ((widget.statuses.contains(OrderStatus.placed) ||
                        widget.statuses.contains(OrderStatus.confirmed) ||
                        widget.statuses.contains(OrderStatus.packed)) &&
                    isAdmin)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: isUpdating
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Cancel Order'),
                                  content: const Text(
                                      'Do you really want to cancel this order?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(ctx);
                                        setState(() {
                                          _updatingOrderIds.add(order.id);
                                        });
                                        try {
                                          await data.cancelOrder(order.id);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Order #${order.id} cancelled')),
                                            );
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _updatingOrderIds.remove(order.id);
                                            });
                                          }
                                        }
                                      },
                                      child: const Text('Yes',
                                          style: TextStyle(color: Colors.red)),
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
                        child: isUpdating
                            ? const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.red,
                                ),
                              )
                            : const Icon(Icons.close, size: 12, color: Colors.red),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
