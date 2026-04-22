import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_config.dart';
import 'auth_provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../constants/cloudinary_config.dart';
import '../services/notification_service.dart';
import '../models/payment_account_model.dart';
import '../models/deal_model.dart';
import '../models/support_models.dart';
import '../models/notification_model.dart';

enum OrderStatus {
  placed,
  confirmed,
  packed,
  outForDelivery,
  delivered,
  cancelled,
}

enum StockStatus { inStock, lowStock, outOfStock }

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({required this.name, required this.quantity, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class Order {
  final String id;
  final String? orderNumber;
  final String customerName;
  final String address;
  final String? customerPhone;
  final List<OrderItem> items;
  final double amount;
  final DateTime time;
  OrderStatus status;
  final String deliveryType;

  // Tracking timestamps
  final DateTime? confirmedAt;
  final DateTime? packedAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;
  final String? paymentMethod;
  final String? paymentAccountId;
  final String? paymentProofUrl;

  Order({
    required this.id,
    this.orderNumber,
    required this.customerName,
    required this.address,
    this.customerPhone,
    required this.items,
    required this.amount,
    required this.time,
    this.status = OrderStatus.placed,
    this.deliveryType = 'Standard',
    this.confirmedAt,
    this.packedAt,
    this.outForDeliveryAt,
    this.deliveredAt,
    this.paymentMethod,
    this.paymentAccountId,
    this.paymentProofUrl,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Map status string to enum
    OrderStatus orderStatus = OrderStatus.placed;
    String statusStr = (json['status'] ?? 'order Placed').toString().toLowerCase();

    switch (statusStr) {
      case 'order placed':
      case 'placed':
      case 'pending':
        orderStatus = OrderStatus.placed;
        break;
      case 'confirmed':
        orderStatus = OrderStatus.confirmed;
        break;
      case 'items packed':
      case 'packed':
        orderStatus = OrderStatus.packed;
        break;
      case 'out for delivry':
      case 'out for delivery':
      case 'dispatched':
        orderStatus = OrderStatus.outForDelivery;
        break;
      case 'delivered':
        orderStatus = OrderStatus.delivered;
        break;
      case 'cancelled':
        orderStatus = OrderStatus.cancelled;
        break;
    }

    final List<OrderItem> items = (json['order_items'] as List? ?? [])
        .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList();

    DateTime parseDate(dynamic dateStr) {
      if (dateStr == null) return DateTime.now();
      return DateTime.tryParse(dateStr.toString()) ?? DateTime.now();
    }

    DateTime? tryParseDate(dynamic dateStr) {
      if (dateStr == null) return null;
      return DateTime.tryParse(dateStr.toString());
    }

    return Order(
      id: (json['id'] ?? '').toString(),
      orderNumber: json['order_number']?.toString(),
      customerName: json['customer_name']?.toString() ?? 'Guest',
      address: json['address']?.toString() ?? 'No address',
      customerPhone: json['customer_phone']?.toString(),
      items: items,
      amount: (json['amount'] ?? 0).toDouble(),
      time: parseDate(json['time']),
      status: orderStatus,
      deliveryType: json['delivery_type']?.toString() ?? 'Standard',
      confirmedAt: tryParseDate(json['confirmed_at']),
      packedAt: tryParseDate(json['packed_at']),
      outForDeliveryAt: tryParseDate(json['out_for_delivery_at']),
      deliveredAt: tryParseDate(json['delivered_at']),
      paymentMethod: json['payment_method']?.toString(),
      paymentAccountId: json['payment_account_id']?.toString(),
      paymentProofUrl: json['payment_proof_url']?.toString(),
    );
  }
}

class Product {
  final String id;
  String name;
  String sku;
  String category;
  double salePrice;
  double purchasePrice;
  int stockCount;
  StockStatus status;
  List<String> imageUrls;
  String description;
  String weight;
  String emoji;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.salePrice,
    required this.purchasePrice,
    required this.stockCount,
    required this.status,
    required this.imageUrls,
    this.description = '',
    this.weight = '',
    this.emoji = '',
  });

  // Getter for backward compatibility
  double get price => salePrice;

  factory Product.fromJson(Map<String, dynamic> json) {
    // Map string status to enum
    StockStatus stockStatus = StockStatus.inStock;
    if (json['status'] == 'lowStock') stockStatus = StockStatus.lowStock;
    if (json['status'] == 'outOfStock') stockStatus = StockStatus.outOfStock;

    // Handle image_urls array safely
    List<String> urls = [];
    if (json['image_urls'] != null && json['image_urls'] is List) {
      urls = (json['image_urls'] as List).map((e) => e.toString()).toList();
    }

    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      category: json['category'] ?? '',
      salePrice: (json['sale_price'] ?? json['price'] ?? 0).toDouble(),
      purchasePrice: (json['purchase_price'] ?? 0).toDouble(),
      stockCount: json['stock_count'] ?? 0,
      status: stockStatus,
      imageUrls: urls,
      description: json['description'] ?? '',
      weight: json['weight'] ?? '',
      emoji: json['emoji'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'category': category,
      'sale_price': salePrice,
      'purchase_price': purchasePrice,
      'price': salePrice, // Keep for compatibility
      'stock_count': stockCount,
      'status': status.name,
      'image_urls': imageUrls,
      'description': description,
      'weight': weight,
      'emoji': emoji,
    };
  }

  // Helper to get cover image
  String? get coverImage => imageUrls.isNotEmpty ? imageUrls.first : null;
}

class Staff {
  final String id;
  String name;
  String username;
  String password;
  String role;
  String status;

  Staff({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.role,
    required this.status,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'Staff Member',
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'password': password,
      'role': role,
      'status': status,
    };
  }
}

class Review {
  final String id;
  final String productId;
  final String userName;
  final double rating;
  final String comment;
  final String? reply;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.reply,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      userName: json['user_name'] ?? 'Anonymous',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      reply: json['reply'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class ProductReport {
  final int totalOrders;
  final int totalQuantity;
  final double totalRevenue;
  final double totalProfit;
  final List<DailyStats> salesTrend;
  final List<DailyStats> profitTrend;

  ProductReport({
    required this.totalOrders,
    required this.totalQuantity,
    required this.totalRevenue,
    required this.totalProfit,
    required this.salesTrend,
    required this.profitTrend,
  });
}

class DailyStats {
  final DateTime date;
  final double value;

  DailyStats(this.date, this.value);
}

class DataProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _cloudinary = CloudinaryPublic(
    CloudinaryConfig.cloudName,
    CloudinaryConfig.uploadPreset,
    cache: false,
  );

  RealtimeChannel? _realtimeChannel;

  DataProvider() {
    _initializeRealtime();
    fetchOrders();
    fetchProducts();
    fetchCategories();
    fetchPaymentAccounts();
    fetchDeals();
    fetchStaff();
    fetchAdminNotifications();
  }

  void _initializeRealtime() {
    _realtimeChannel = _supabase
        .channel('admin-updates')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            debugPrint('New order received: ${payload.newRecord}');
            _handleNewOrder(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'reviews',
          callback: (payload) {
            debugPrint('New review received: ${payload.newRecord}');
            _handleNewReview(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'admin_notifications',
          callback: (payload) {
            debugPrint('New admin notification: ${payload.newRecord}');
            fetchAdminNotifications();
          },
        )
        .subscribe();
  }

  void _handleNewOrder(Map<String, dynamic> record) {
    final amount = record['amount'] ?? 0.0;
    final customer = record['customer_name'] ?? 'Guest';

    NotificationService().showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '📦 New Order Received!',
      body: 'Customer: $customer\nAmount: ₨$amount',
    );

    fetchOrders(); // Refresh orders list
  }

  void _handleNewReview(Map<String, dynamic> record) {
    final userName = record['user_name'] ?? 'Anonymuous';
    final rating = record['rating'] ?? 0;

    NotificationService().showNotification(
      id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 1,
      title: '⭐ New Product Review!',
      body: 'User: $userName\nRating: $rating stars',
    );
    // Reviews are fetched on-demand in the detail screen, so no need to refresh global state here
  }

  @override
  void dispose() {
    if (_realtimeChannel != null) {
      _supabase.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  List<Order> _orders = [];
  bool _isOrdersLoading = false;

  List<Product> _products = [];
  bool _isProductsLoading = false;

  List<String> _categories = [
    'Groceries',
    'Electronics',
    'Apparel',
    'Personal Care',
    'Home Essentials',
    'Beverages',
  ];
  bool _isCategoriesLoading = false;

  List<Staff> _staff = [];
  bool _isStaffLoading = false;

  List<AdminNotification> _adminNotifications = [];
  bool _isNotificationsLoading = false;

  List<Order> get orders => _orders;
  bool get isOrdersLoading => _isOrdersLoading;
  List<Product> get products => _products;
  bool get isProductsLoading => _isProductsLoading;
  List<String> get categories => _categories;
  bool get isCategoriesLoading => _isCategoriesLoading;
  List<Staff> get staff => _staff;
  bool get isStaffLoading => _isStaffLoading;

  List<AdminNotification> get adminNotifications => _adminNotifications;
  bool get isNotificationsLoading => _isNotificationsLoading;

  List<Deal> _deals = [];
  bool _isDealsLoading = false;
  List<Deal> get deals => _deals;
  bool get isDealsLoading => _isDealsLoading;

  double get totalSales => _orders.fold(0, (sum, item) => sum + item.amount);
  int get activeOrders => _orders
      .where(
        (o) =>
            o.status == OrderStatus.placed ||
            o.status == OrderStatus.confirmed ||
            o.status == OrderStatus.packed,
      )
      .length;
  int get outOfStockItems =>
      _products.where((p) => p.status == StockStatus.outOfStock).length;

  // Revenue for the chart (Monthly trend for current year)
  List<double> get monthlyRevenueTrend {
    List<double> trend = List.filled(12, 0.0);
    final now = DateTime.now();

    for (var order in _orders) {
      if (order.time.year == now.year) {
        int month = order.time.month - 1; // 0-indexed
        trend[month] += order.amount;
      }
    }
    return trend;
  }

  // --- Products Methods ---

  Future<void> fetchProducts() async {
    _isProductsLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);
      final List data = (response as List?) ?? [];
      _products = data
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      _isProductsLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(
    String name,
    String category,
    double salePrice,
    double purchasePrice,
    String sku, {
    int stock = 1,
    String description = '',
    String weight = '',
    String emoji = '',
    List<String>? imageFilePaths,
  }) async {
    try {
      List<String> uploadedUrls = [];
      if (imageFilePaths != null && imageFilePaths.isNotEmpty) {
        for (String path in imageFilePaths) {
          // Upload each to Cloudinary
          CloudinaryResponse response = await _cloudinary.uploadFile(
            CloudinaryFile.fromFile(path, folder: 'products'),
          );
          uploadedUrls.add(response.secureUrl);
        }
      }

      final status = stock == 0
          ? StockStatus.outOfStock
          : (stock < 10 ? StockStatus.lowStock : StockStatus.inStock);

      final newProductData = {
        'name': name,
        'category': category,
        'sale_price': salePrice,
        'purchase_price': purchasePrice,
        'price': salePrice, // Keep for compatibility
        'sku': sku,
        'stock_count': stock,
        'status': status.name,
        'image_urls': uploadedUrls,
        'description': description,
        'weight': weight,
        'emoji': emoji,
      };

      await _supabase.from('products').insert(newProductData);
      await fetchProducts(); // Refresh list
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(
    String id,
    String name,
    double salePrice,
    double purchasePrice,
    int stock, {
    String? category,
    String? sku,
    String? description,
    String? weight,
    String? emoji,
    List<String>? imageUrls,
    List<String>? newImageFilePaths,
  }) async {
    try {
      List<String> finalUrls = imageUrls ?? [];

      if (newImageFilePaths != null && newImageFilePaths.isNotEmpty) {
        for (String path in newImageFilePaths) {
          CloudinaryResponse response = await _cloudinary.uploadFile(
            CloudinaryFile.fromFile(path, folder: 'products'),
          );
          finalUrls.add(response.secureUrl);
        }
      }

      final status = stock == 0
          ? StockStatus.outOfStock
          : (stock < 10 ? StockStatus.lowStock : StockStatus.inStock);

      final updateData = {
        'name': name,
        'sale_price': salePrice,
        'purchase_price': purchasePrice,
        'price': salePrice,
        'stock_count': stock,
        'status': status.name,
        'image_urls': finalUrls,
        'description': description ?? '',
        'weight': weight ?? '',
        'emoji': emoji ?? '',
      };

      if (category != null) updateData['category'] = category;
      if (sku != null) updateData['sku'] = sku;

      await _supabase.from('products').update(updateData).eq('id', id);

      await fetchProducts();
    } catch (e) {
      debugPrint('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _supabase.from('products').delete().eq('id', id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting product: $e');
      rethrow;
    }
  }

  // --- Categories Methods ---

  Future<void> fetchCategories() async {
    _isCategoriesLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('categories')
          .select()
          .order('name', ascending: true);
      debugPrint('Supabase Categories Response: $response');
      final List data = (response as List?) ?? [];
      _categories = data
          .map((item) => (item['name'] ?? '').toString())
          .where((name) => name.isNotEmpty)
          .toList();
      if (_categories.isEmpty) {
        debugPrint('No categories found in Supabase, using defaults.');
        _categories = [
          'Groceries',
          'Electronics',
          'Apparel',
          'Personal Care',
          'Home Essentials',
          'Beverages',
        ];
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String name, {String? imageFilePath}) async {
    try {
      String? imageUrl;
      if (imageFilePath != null && imageFilePath.isNotEmpty) {
        CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(imageFilePath, folder: 'categories'),
        );
        imageUrl = response.secureUrl;
      }

      final data = <String, dynamic>{'name': name};
      if (imageUrl != null) data['image_url'] = imageUrl;

      await _supabase.from('categories').insert(data);
      await fetchCategories();
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    }
  }

  // --- Orders Methods ---

  Future<void> fetchOrders() async {
    _isOrdersLoading = true;
    notifyListeners();

    try {
      dynamic data;
      try {
        // Primary attempt: fetch orders with items in one join query
        data = await _supabase
            .from('orders')
            .select('*, order_items(*)');
      } catch (e) {
        debugPrint('Primary join fetch failed, attempting fallback: $e');
        
        // Fallback: fetch orders and items separately (RLS might allow one but not the join)
        final ordersData = await _supabase.from('orders').select();
        
        List<dynamic> itemsData = [];
        try {
          itemsData = await _supabase.from('order_items').select();
        } catch (e2) {
          debugPrint('Items fetch failed in fallback: $e2');
        }
        
        // Map items to their respective orders
        data = (ordersData as List).map((order) {
          final orderId = order['id'].toString();
          final orderItems = itemsData.where((item) => 
            item['order_id']?.toString() == orderId
          ).toList();
          
          return {
            ...order,
            ...order, // Duplicate to ensure map spreading works in all dart versions
            'order_items': orderItems,
          };
        }).toList();
      }

      final List dataList = (data as List?) ?? [];
      _orders = dataList.map((item) {
        try {
          return Order.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Error parsing individual order: $e');
          // Return a dummy order or skip? Let's try to parse what we can
          return Order.fromJson({'id': 'error', 'customer_name': 'Error parsing order'});
        }
      }).toList();
      
      // Remove dummy error orders
      _orders.removeWhere((o) => o.id == 'error');
    } catch (e, stackTrace) {
      debugPrint('CRITICAL: Error fetching orders: $e');
      print('StackTrace: $stackTrace');
      _orders = []; // Ensure orders is at least an empty list
    } finally {
      _isOrdersLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String id, OrderStatus newStatus) async {
    try {
      String statusStr = 'order Placed';
      Map<String, dynamic> updateData = {};

      switch (newStatus) {
        case OrderStatus.placed:
          statusStr = 'order Placed';
          break;
        case OrderStatus.confirmed:
          statusStr = 'Confirmed';
          updateData['confirmed_at'] = DateTime.now().toIso8601String();
          break;
        case OrderStatus.packed:
          statusStr = 'Items Packed';
          updateData['packed_at'] = DateTime.now().toIso8601String();
          break;
        case OrderStatus.outForDelivery:
          statusStr = 'Out For Delivry';
          updateData['out_for_delivery_at'] = DateTime.now().toIso8601String();
          break;
        case OrderStatus.delivered:
          statusStr = 'Delivered';
          updateData['delivered_at'] = DateTime.now().toIso8601String();
          break;
        case OrderStatus.cancelled:
          statusStr = 'cancelled';
          break;
      }

      updateData['status'] = statusStr;

      final response = await _supabase
          .from('orders')
          .update(updateData)
          .eq('id', id)
          .select('*, order_items(*)')
          .single();

      // Update the order in the local list
      final index = _orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        _orders[index] = Order.fromJson(response as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  Future<void> dispatchOrder(String id) async {
    // Legacy support, map to outForDelivery
    await updateOrderStatus(id, OrderStatus.outForDelivery);
  }

  Future<void> cancelOrder(String id) async {
    await updateOrderStatus(id, OrderStatus.cancelled);
  }

  // --- Staff Methods ---

  Future<void> fetchStaff() async {
    _isStaffLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('staff_members')
          .select()
          .order('name', ascending: true);

      final List data = (response as List?) ?? [];
      _staff = data
          .map((item) => Staff.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching staff: $e');
    } finally {
      _isStaffLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStaff(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      // 1. Register the user in Supabase Auth using a temporary client 
      // to avoid logging out the current admin.
      String? userId;
      
      // 1. Attempt to register the user in Supabase Auth (Optional step)
      // We do this so Admins can have real Auth accounts, but we don't let it block
      // the creation of Staff Members if it fails.
      try {
        final tempSupabase = SupabaseClient(
          SupabaseConfig.url, 
          SupabaseConfig.anonKey,
          authOptions: const AuthClientOptions(
            authFlowType: AuthFlowType.implicit,
          ),
        );
        
        final authResponse = await tempSupabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': name,
            'role': role.toLowerCase().contains('admin') ? 'admin' : 'staff',
          },
        );
        userId = authResponse.user?.id;
      } catch (e) {
        debugPrint('Auth registration skipped or failed (User might already exist): $e');
        // We continue anyway because loginStaff uses the staff_members table directly.
      }

      // 2. Add to staff_members table for management UI
      final newStaff = {
        if (userId != null) 'id': userId,
        'name': name,
        'username': email,
        'password': password,
        'role': role,
        'status': 'Active',
      };

      await _supabase.from('staff_members').upsert(newStaff, onConflict: 'username');
      await fetchStaff();
    } catch (e) {
      debugPrint('Error adding staff: $e');
      rethrow;
    }
  }

  Future<void> updateStaff(
    String id,
    String name,
    String username,
    String password,
    String role,
    String status,
  ) async {
    try {
      final updateData = {
        'name': name,
        'username': username,
        'password': password,
        'role': role,
        'status': status,
      };

      await _supabase.from('staff_members').update(updateData).eq('id', id);
      await fetchStaff();
    } catch (e) {
      debugPrint('Error updating staff: $e');
      rethrow;
    }
  }

  Future<void> deleteStaff(String id) async {
    try {
      await _supabase.from('staff_members').delete().eq('id', id);
      _staff.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting staff: $e');
      rethrow;
    }
  }

  // --- Reviews Methods ---

  Future<List<Review>> fetchReviews(String productId) async {
    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      final List data = (response as List?) ?? [];
      return data
          .map((item) => Review.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      return [];
    }
  }

  Future<void> replyToReview(String reviewId, String reply) async {
    try {
      await _supabase
          .from('reviews')
          .update({'reply': reply})
          .eq('id', reviewId);
    } catch (e) {
      debugPrint('Error replying to review: $e');
      rethrow;
    }
  }

  // --- Analytics Methods ---

  ProductReport getProductReport(Product product) {
    int totalOrders = 0;
    int totalQuantity = 0;
    double totalRevenue = 0;
    double totalProfit = 0;
    Map<String, double> salesMap = {};
    Map<String, double> profitMap = {};

    for (var order in _orders) {
      bool orderHasProduct = false;
      for (var item in order.items) {
        if (item.name == product.name) {
          orderHasProduct = true;
          totalQuantity += item.quantity;
          totalRevenue += (item.price * item.quantity);
          // Profit = (Sale Price - Purchase Price) * Quantity
          totalProfit += (item.price - product.purchasePrice) * item.quantity;

          String dateKey = DateFormat('yyyy-MM-dd').format(order.time);
          salesMap[dateKey] =
              (salesMap[dateKey] ?? 0) + item.quantity.toDouble();
          profitMap[dateKey] =
              (profitMap[dateKey] ?? 0) +
              ((item.price - product.purchasePrice) * item.quantity);
        }
      }
      if (orderHasProduct) totalOrders++;
    }

    // Sort trends by date
    List<String> sortedDates = salesMap.keys.toList()..sort();
    List<DailyStats> salesTrend = sortedDates
        .map((d) => DailyStats(DateTime.parse(d), salesMap[d]!))
        .toList();
    List<DailyStats> profitTrend = sortedDates
        .map((d) => DailyStats(DateTime.parse(d), profitMap[d]!))
        .toList();

    // If no sales, add a zero entry for today
    if (salesTrend.isEmpty) {
      salesTrend.add(DailyStats(DateTime.now(), 0));
      profitTrend.add(DailyStats(DateTime.now(), 0));
    }

    return ProductReport(
      totalOrders: totalOrders,
      totalQuantity: totalQuantity,
      totalRevenue: totalRevenue,
      totalProfit: totalProfit,
      salesTrend: salesTrend,
      profitTrend: profitTrend,
    );
  }

  // --- Delivery Config Methods ---

  Future<Map<String, dynamic>?> fetchDeliveryConfig() async {
    try {
      final response = await _supabase
          .from('delivery_config')
          .select()
          .eq('id', 1)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error fetching delivery config: $e');
      return null;
    }
  }

  Future<void> updateDeliveryConfig(String field, dynamic value) async {
    try {
      await _supabase.from('delivery_config').upsert({
        'id': 1,
        field: value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error updating delivery config: $e');
      rethrow;
    }
  }

  // --- Payment Accounts Methods ---

  List<PaymentAccount> _paymentAccounts = [];
  bool _isPaymentAccountsLoading = false;
  List<PaymentAccount> get paymentAccounts => _paymentAccounts;
  bool get isPaymentAccountsLoading => _isPaymentAccountsLoading;

  Future<void> fetchPaymentAccounts() async {
    _isPaymentAccountsLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('payment_accounts')
          .select()
          .order('created_at', ascending: false);
      final List data = (response as List?) ?? [];
      _paymentAccounts = data
          .map((item) => PaymentAccount.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching payment accounts: $e');
    } finally {
      _isPaymentAccountsLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPaymentAccount(PaymentAccount account) async {
    try {
      await _supabase.from('payment_accounts').insert(account.toJson());
      await fetchPaymentAccounts();
    } catch (e) {
      debugPrint('Error adding payment account: $e');
      rethrow;
    }
  }

  Future<void> deletePaymentAccount(String id) async {
    try {
      await _supabase.from('payment_accounts').delete().eq('id', id);
      _paymentAccounts.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting payment account: $e');
      rethrow;
    }
  }

  // --- Deals Methods ---

  Future<void> fetchDeals() async {
    _isDealsLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('deals')
          .select('*, deal_items(*, products(*))')
          .order('created_at', ascending: false);

      final List data = (response as List?) ?? [];
      _deals = data
          .map((item) => Deal.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching deals: $e');
    } finally {
      _isDealsLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDeal({
    required String name,
    String? description,
    required double price,
    double? originalPrice,
    DateTime? expiresAt,
    String? imagePath,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      String? imageUrl;
      if (imagePath != null && imagePath.isNotEmpty) {
        CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(imagePath, folder: 'deals'),
        );
        imageUrl = response.secureUrl;
      }

      final dealData = {
        'name': name,
        'description': description,
        'price': price,
        'original_price': originalPrice,
        'expires_at': expiresAt?.toIso8601String(),
        'image_url': imageUrl,
      };

      final dealResponse = await _supabase
          .from('deals')
          .insert(dealData)
          .select()
          .single();
      final String dealId = dealResponse['id'].toString();

      if (items.isNotEmpty) {
        final List<Map<String, dynamic>> dealItems = items
            .map(
              (item) => {
                'deal_id': dealId,
                'product_id': item['product_id'],
                'quantity': item['quantity'],
              },
            )
            .toList();

        await _supabase.from('deal_items').insert(dealItems);
      }

      await fetchDeals();
    } catch (e) {
      debugPrint('Error adding deal: $e');
      rethrow;
    }
  }

  Future<void> updateDeal({
    required String id,
    required String name,
    String? description,
    required double price,
    double? originalPrice,
    DateTime? expiresAt,
    bool isActive = true,
    String? imageUrl,
    String? newImagePath,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      String? finalImageUrl = imageUrl;
      if (newImagePath != null && newImagePath.isNotEmpty) {
        CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(newImagePath, folder: 'deals'),
        );
        finalImageUrl = response.secureUrl;
      }

      final dealData = {
        'name': name,
        'description': description,
        'price': price,
        'original_price': originalPrice,
        'expires_at': expiresAt?.toIso8601String(),
        'is_active': isActive,
        'image_url': finalImageUrl,
      };

      await _supabase.from('deals').update(dealData).eq('id', id);

      // Simple approach: delete all deal items and re-insert
      await _supabase.from('deal_items').delete().eq('deal_id', id);

      if (items.isNotEmpty) {
        final List<Map<String, dynamic>> dealItems = items
            .map(
              (item) => {
                'deal_id': id,
                'product_id': item['product_id'],
                'quantity': item['quantity'],
              },
            )
            .toList();

        await _supabase.from('deal_items').insert(dealItems);
      }

      await fetchDeals();
    } catch (e) {
      debugPrint('Error updating deal: $e');
      rethrow;
    }
  }

  Future<void> deleteDeal(String id) async {
    try {
      await _supabase.from('deals').delete().eq('id', id);
      _deals.removeWhere((d) => d.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting deal: $e');
      rethrow;
    }
  }

  // --- Support / Help Center Methods ---

  List<Faq> _faqs = [];
  bool _isFaqsLoading = false;
  List<Faq> get faqs => _faqs;
  bool get isFaqsLoading => _isFaqsLoading;

  Future<void> fetchFaqs() async {
    _isFaqsLoading = true;
    notifyListeners();
    try {
      final response = await _supabase
          .from('faqs')
          .select()
          .order('created_at', ascending: true);
      final List data = (response as List?) ?? [];
      _faqs = data
          .map((item) => Faq.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching FAQs: $e');
    } finally {
      _isFaqsLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFaq(String question, String answer) async {
    try {
      await _supabase.from('faqs').insert({
        'question': question,
        'answer': answer,
      });
      await fetchFaqs();
    } catch (e) {
      debugPrint('Error adding FAQ: $e');
      rethrow;
    }
  }

  Future<void> updateFaq(String id, String question, String answer) async {
    try {
      await _supabase
          .from('faqs')
          .update({'question': question, 'answer': answer})
          .eq('id', id);
      await fetchFaqs();
    } catch (e) {
      debugPrint('Error updating FAQ: $e');
      rethrow;
    }
  }

  Future<void> deleteFaq(String id) async {
    try {
      await _supabase.from('faqs').delete().eq('id', id);
      _faqs.removeWhere((f) => f.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting FAQ: $e');
      rethrow;
    }
  }

  List<ContactDetail> _contactDetails = [];
  bool _isContactLoading = false;
  List<ContactDetail> get contactDetails => _contactDetails;
  bool get isContactLoading => _isContactLoading;

  Future<void> fetchContactDetails() async {
    _isContactLoading = true;
    notifyListeners();
    try {
      final response = await _supabase
          .from('contact_details')
          .select()
          .order('created_at', ascending: true);
      final List data = (response as List?) ?? [];
      _contactDetails = data
          .map((item) => ContactDetail.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching contact details: $e');
    } finally {
      _isContactLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContactDetail(
    String label,
    String value, {
    String? icon,
  }) async {
    try {
      await _supabase.from('contact_details').insert({
        'label': label,
        'value': value,
        'icon': icon,
      });
      await fetchContactDetails();
    } catch (e) {
      debugPrint('Error adding contact detail: $e');
      rethrow;
    }
  }

  Future<void> deleteContactDetail(String id) async {
    try {
      await _supabase.from('contact_details').delete().eq('id', id);
      _contactDetails.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting contact detail: $e');
      rethrow;
    }
  }

  String _aboutApp = 'Welcome to our app!';
  bool _isAboutAppLoading = false;
  String get aboutApp => _aboutApp;
  bool get isAboutAppLoading => _isAboutAppLoading;

  Future<void> fetchAboutApp() async {
    _isAboutAppLoading = true;
    notifyListeners();
    try {
      final response = await _supabase
          .from('app_info')
          .select()
          .limit(1)
          .maybeSingle();
      if (response != null) {
        _aboutApp = response['content'] ?? '';
      }
    } catch (e) {
      debugPrint('Error fetching about app: $e');
    } finally {
      _isAboutAppLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAboutApp(String content) async {
    try {
      final existing = await _supabase
          .from('app_info')
          .select()
          .limit(1)
          .maybeSingle();
      if (existing == null) {
        await _supabase.from('app_info').insert({'content': content});
      } else {
        await _supabase
            .from('app_info')
            .update({'content': content})
            .eq('id', existing['id']);
      }
      _aboutApp = content;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating about app: $e');
      rethrow;
    }
  }

  // --- Admin Notifications ---

  Future<void> fetchAdminNotifications() async {
    _isNotificationsLoading = true;
    notifyListeners();

    try {
      final response = await _supabase
          .from('admin_notifications')
          .select()
          .order('created_at', ascending: false);

      final List data = (response as List?) ?? [];
      _adminNotifications = data
          .map((e) => AdminNotification.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint('Error fetching admin notifications: $e');
    } finally {
      _isNotificationsLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAdminNotificationRead(String id) async {
    try {
      await _supabase
          .from('admin_notifications')
          .update({'is_read': true})
          .eq('id', id);
      await fetchAdminNotifications();
    } catch (e) {
      debugPrint('Error marking admin notification as read: $e');
    }
  }

  Future<void> clearAdminNotifications() async {
    try {
      await _supabase
          .from('admin_notifications')
          .delete()
          .neq('id', '0'); // Delete all
      _adminNotifications.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing admin notifications: $e');
    }
  }
}
