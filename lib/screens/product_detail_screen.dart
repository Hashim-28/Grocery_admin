import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';
import '../core/app_theme.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'add_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();

  Future<void> _showReviewsBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewsBottomSheet(product: widget.product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.read<DataProvider>();
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.role == UserRole.admin;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddProductScreen(initialProduct: widget.product),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Product?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  try {
                    await data.deleteProduct(widget.product.id);
                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Product deleted')),
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Image Carousel ---
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        height: 350,
                        width: double.infinity,
                        child: widget.product.imageUrls.isNotEmpty
                            ? PageView.builder(
                                controller: _pageController,
                                itemCount: widget.product.imageUrls.length,
                                itemBuilder: (context, index) {
                                  final imageUrl =
                                      widget.product.imageUrls[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgGrey,
                                      image: DecorationImage(
                                        image: imageUrl.startsWith('http')
                                            ? NetworkImage(imageUrl)
                                                  as ImageProvider
                                            : FileImage(File(imageUrl)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: AppTheme.bgGrey,
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      if (widget.product.imageUrls.length > 1)
                        Positioned(
                          bottom: 20,
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: widget.product.imageUrls.length,
                            effect: const ExpandingDotsEffect(
                              dotHeight: 8,
                              dotWidth: 8,
                              activeDotColor: AppTheme.primaryGreen,
                              dotColor: Colors.white70,
                            ),
                          ),
                        ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Category & Stock Status ---
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.product.category,
                                style: const TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStockBadge(widget.product.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // --- Name ---
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // --- SKU ---
                        if (widget.product.sku.isNotEmpty)
                          Text(
                            'SKU: ${widget.product.sku}',
                            style: const TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // --- Pricing ---
                        Row(
                          children: [
                            _buildPriceInfo(
                              'Sale Price',
                              'PKR ${widget.product.salePrice}',
                              AppTheme.primaryGreen,
                            ),
                            const SizedBox(width: 48),
                            _buildPriceInfo(
                              'Purchase Price',
                              'PKR ${widget.product.purchasePrice}',
                              AppTheme.textGrey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // --- Inventory Details ---
                        const Text(
                          'Inventory Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.inventory_2_outlined,
                          'Stock Count',
                          '${widget.product.stockCount} units available',
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 32),

                        // --- Performance Reports ---
                        const Text(
                          'Performance Reports',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Summary Statistics Cards
                        _buildPerformanceSummary(data.getProductReport(widget.product)),
                        const SizedBox(height: 32),

                        // Sales Volume Chart
                        _buildChartCard(
                          'Sales Volume Trend',
                          'Total quantity sold over time',
                          Icons.trending_up,
                          _buildTrendChart(data.getProductReport(widget.product).salesTrend, AppTheme.primaryGreen),
                        ),
                        const SizedBox(height: 24),

                        // Profit Trend Chart
                        _buildChartCard(
                          'Profitability Trend',
                          'Net profit generated from this product',
                          Icons.account_balance_wallet_outlined,
                          _buildTrendChart(data.getProductReport(widget.product).profitTrend, Colors.blueAccent),
                        ),
                        const SizedBox(height: 48),

                        // --- Reviews Button ---
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _showReviewsBottomSheet(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 56),
                              side: const BorderSide(
                                color: AppTheme.borderGrey,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.star_outline, size: 20),
                                SizedBox(width: 12),
                                Text(
                                  'View All Reviews',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildPerformanceSummary(ProductReport report) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Sold',
                report.totalQuantity.toString(),
                'units',
                Icons.shopping_bag_outlined,
                AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Revenue',
                NumberFormat.compact().format(report.totalRevenue),
                'PKR',
                Icons.payments_outlined,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Profit',
                NumberFormat.compact().format(report.totalProfit),
                'PKR',
                Icons.monetization_on_outlined,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Profit Margin',
                report.totalRevenue > 0
                    ? '${((report.totalProfit / report.totalRevenue) * 100).toStringAsFixed(1)}%'
                    : '0%',
                'ROI',
                Icons.pie_chart_outline,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$title ($unit)',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, String subtitle, IconData icon, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.bgGrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppTheme.textDark),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildTrendChart(List<DailyStats> trend, Color color) {
    if (trend.length < 2) {
      return const Center(
        child: Text(
          'Not enough data to show trend',
          style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.borderGrey,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < trend.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(trend[value.toInt()].date),
                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: trend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: true,
            color: color,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 3,
                strokeColor: color,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => AppTheme.textDark.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${DateFormat('MMM dd').format(trend[spot.x.toInt()].date)}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: spot.y.toString(),
                      style: TextStyle(color: color, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge(StockStatus status) {
    Color color;
    String label;
    switch (status) {
      case StockStatus.inStock:
        color = Colors.green;
        label = 'In Stock';
        break;
      case StockStatus.lowStock:
        color = Colors.orange;
        label = 'Low Stock';
        break;
      case StockStatus.outOfStock:
        color = Colors.red;
        label = 'Out of Stock';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String title, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textGrey, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewsBottomSheet extends StatefulWidget {
  final Product product;
  const _ReviewsBottomSheet({required this.product});

  @override
  State<_ReviewsBottomSheet> createState() => _ReviewsBottomSheetState();
}

class _ReviewsBottomSheetState extends State<_ReviewsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final data = context.read<DataProvider>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Text(
                  'User Reviews',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Review>>(
              future: data.fetchReviews(widget.product.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final reviews = snapshot.data ?? [];
                if (reviews.isEmpty) {
                  return const Center(
                    child: Text('No reviews for this product yet.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 32),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return _ReviewItem(
                      review: review,
                      onReplied: () => setState(() {}),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatefulWidget {
  final Review review;
  final VoidCallback onReplied;
  const _ReviewItem({required this.review, required this.onReplied});

  @override
  State<_ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<_ReviewItem> {
  final _replyController = TextEditingController();
  bool _isReplying = false;

  @override
  void initState() {
    super.initState();
    if (widget.review.reply != null) {
      _replyController.text = widget.review.reply!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.read<DataProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: Text(
                widget.review.userName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.review.userName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < widget.review.rating
                              ? Icons.star
                              : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy',
                        ).format(widget.review.createdAt),
                        style: const TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.review.comment,
          style: const TextStyle(color: AppTheme.textDark),
        ),
        if (widget.review.reply != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.bgGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Reply',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.review.reply!,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (!_isReplying && widget.review.reply == null)
          TextButton.icon(
            onPressed: () => setState(() => _isReplying = true),
            icon: const Icon(Icons.reply, size: 16),
            label: const Text('Reply'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
          ),
        if (_isReplying) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _replyController,
            decoration: InputDecoration(
              hintText: 'Type your reply...',
              fillColor: AppTheme.bgGrey,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: AppTheme.primaryGreen),
                onPressed: () async {
                  if (_replyController.text.isEmpty) return;
                  try {
                    await data.replyToReview(
                      widget.review.id,
                      _replyController.text,
                    );
                    setState(() => _isReplying = false);
                    widget.onReplied();
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _isReplying = false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
