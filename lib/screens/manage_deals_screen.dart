import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../core/app_theme.dart';
import '../models/deal_model.dart';
import 'add_edit_deal_screen.dart';

class ManageDealsScreen extends StatelessWidget {
  const ManageDealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<DataProvider>();
    final deals = dataProvider.deals;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('DEALS & BUNDLES'),
        actions: [
          IconButton(
            onPressed: () => dataProvider.fetchDeals(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: dataProvider.isDealsLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            )
          : deals.isEmpty
          ? _buildEmptyState(context)
          : _buildDealsList(context, deals, dataProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditDealScreen()),
        ),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'CREATE DEAL',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Active Deals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create bundles to offer discounts to your customers',
            style: TextStyle(color: AppTheme.textGrey),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditDealScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('CREATE YOUR FIRST DEAL'),
          ),
        ],
      ),
    );
  }

  Widget _buildDealsList(
    BuildContext context,
    List<Deal> deals,
    DataProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: deals.length,
      itemBuilder: (context, index) {
        final deal = deals[index];
        return _DealCard(
          deal: deal,
          onDelete: () => _confirmDelete(context, deal, provider),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Deal deal, DataProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deal?'),
        content: Text('Are you sure you want to delete "${deal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteDeal(deal.id);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback onDelete;

  const _DealCard({required this.deal, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditDealScreen(deal: deal)),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image or Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.bgGrey,
                        borderRadius: BorderRadius.circular(12),
                        image: deal.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(deal.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: deal.imageUrl == null
                          ? const Icon(
                              Icons.local_offer,
                              color: AppTheme.primaryGreen,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  deal.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: deal.isActive
                                      ? AppTheme.primaryGreen.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  deal.isActive ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: deal.isActive
                                        ? AppTheme.primaryGreen
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deal.description ?? 'No description provided',
                            style: const TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '₨${deal.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                  fontSize: 18,
                                ),
                              ),
                              if (deal.originalPrice != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '₨${deal.originalPrice!.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: AppTheme.textGrey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${deal.items.length} Products included',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (deal.expiresAt != null) ...[
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expires soon',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
