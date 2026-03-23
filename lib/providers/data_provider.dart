import 'package:flutter/material.dart';

enum OrderStatus { pending, dispatched, cancelled }
enum StockStatus { inStock, lowStock, outOfStock }

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({required this.name, required this.quantity, required this.price});
}

class Order {
  final String id;
  final String customerName;
  final String address;
  final List<OrderItem> items;
  final double amount;
  final DateTime time;
  OrderStatus status;

  Order({
    required this.id,
    required this.customerName,
    required this.address,
    required this.items,
    required this.amount,
    required this.time,
    this.status = OrderStatus.pending,
  });
}

class Product {
  final String id;
  String name;
  String sku;
  String category;
  double price;
  int stockCount;
  StockStatus status;
  String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stockCount,
    required this.status,
    this.imagePath,
  });
}

class Staff {
  final String id;
  String name;
  String role;
  String status;

  Staff({required this.id, required this.name, required this.role, required this.status});
}

class DataProvider with ChangeNotifier {
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  final List<Order> _orders = [
    Order(
      id: '8821', 
      customerName: 'Mr. Bilal', 
      address: 'House 42, Block C, Gulshan-e-Iqbal, Karachi',
      items: [
        OrderItem(name: 'Premium Basmati Rice', quantity: 2, price: 450),
        OrderItem(name: 'Organic Wild Honey', quantity: 1, price: 1200),
      ],
      amount: 12400, 
      time: DateTime.now().subtract(const Duration(minutes: 2))
    ),
    Order(
      id: '8822', 
      customerName: 'Sarah Khan', 
      address: 'Apartment 4B, Sky Towers, Clifton, Karachi',
      items: [
        OrderItem(name: 'Aero Max Sneakers', quantity: 1, price: 8500),
      ],
      amount: 8500, 
      time: DateTime.now().subtract(const Duration(minutes: 15))
    ),
    Order(
      id: '8823', 
      customerName: 'Ahmed Raza', 
      address: 'Plot 10, Sector 5, North Nazimabad, Karachi',
      items: [
        OrderItem(name: 'Retro Instant Camera', quantity: 1, price: 12000),
        OrderItem(name: 'Wireless Headphones', quantity: 1, price: 3200),
      ],
      amount: 15200, 
      time: DateTime.now().subtract(const Duration(hours: 1))
    ),
    Order(
      id: '8824', 
      customerName: 'Fatima Zohra', 
      address: 'Suite 201, Business Center, Shahra-e-Faisal',
      items: [
        OrderItem(name: 'Premium Basmati Rice', quantity: 5, price: 450),
      ],
      amount: 4300, 
      time: DateTime.now().subtract(const Duration(hours: 2))
    ),
    Order(
      id: '8825', 
      customerName: 'Usman Ali', 
      address: 'Near Bilal Masjid, Defence Phase 6, Karachi',
      items: [
        OrderItem(name: 'Organic Wild Honey', quantity: 2, price: 1200),
        OrderItem(name: 'Wireless Headphones', quantity: 2, price: 3700),
      ],
      amount: 9800, 
      time: DateTime.now().subtract(const Duration(hours: 3))
    ),
  ];

  final List<Product> _products = [
    Product(id: '1', name: 'Premium White Basmati', sku: 'W-402', category: 'Groceries', price: 450, stockCount: 24, status: StockStatus.inStock),
    Product(id: '2', name: 'Aero Max Sneakers', sku: 'S-109', category: 'Apparel', price: 8500, stockCount: 5, status: StockStatus.lowStock),
    Product(id: '3', name: 'Retro Instant Camera', sku: 'C-881', category: 'Electronics', price: 12000, stockCount: 12, status: StockStatus.inStock),
    Product(id: '4', name: 'Wireless Bass Headphones', sku: 'H-220', category: 'Electronics', price: 3500, stockCount: 0, status: StockStatus.outOfStock),
    Product(id: '5', name: 'Organic Wild Honey', sku: 'G-005', category: 'Groceries', price: 1200, stockCount: 45, status: StockStatus.inStock),
  ];

  final List<Staff> _staff = [
    Staff(id: '1', name: 'Zaid Ahmed', role: 'Staff Member', status: 'Active'),
    Staff(id: '2', name: 'Hamza Khan', role: 'Admin', status: 'Active'),
    Staff(id: '3', name: 'Ayesha Malik', role: 'Staff Member', status: 'Offline'),
  ];

  List<Order> get orders => _orders;
  List<Product> get products => _products;
  List<Staff> get staff => _staff;

  double get totalSales => _orders.fold(0, (sum, item) => sum + item.amount);
  int get activeOrders => _orders.where((o) => o.status == OrderStatus.pending).length;
  int get outOfStockItems => _products.where((p) => p.status == StockStatus.outOfStock).length;

  void dispatchOrder(String id) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index].status = OrderStatus.dispatched;
      notifyListeners();
    }
  }

  void cancelOrder(String id) {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index != -1) {
      _orders[index].status = OrderStatus.cancelled;
      notifyListeners();
    }
  }

  void addProduct(String name, String category, double price, String sku, {String? imagePath}) {
    _products.insert(0, Product(
      id: DateTime.now().toIso8601String(),
      name: name,
      category: category,
      price: price,
      sku: sku,
      stockCount: 1,
      status: StockStatus.inStock,
      imagePath: imagePath,
    ));
    notifyListeners();
  }

  void updateProduct(String id, String name, double price, int stock) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index].name = name;
      _products[index].price = price;
      _products[index].stockCount = stock;
      _products[index].status = stock == 0 ? StockStatus.outOfStock : (stock < 10 ? StockStatus.lowStock : StockStatus.inStock);
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void addStaff(String name, String role) {
    _staff.insert(0, Staff(
      id: DateTime.now().toIso8601String(),
      name: name,
      role: role,
      status: 'Active',
    ));
    notifyListeners();
  }

  void updateStaff(String id, String name, String role, String status) {
    final index = _staff.indexWhere((s) => s.id == id);
    if (index != -1) {
      _staff[index].name = name;
      _staff[index].role = role;
      _staff[index].status = status;
      notifyListeners();
    }
  }

  void deleteStaff(String id) {
    _staff.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
