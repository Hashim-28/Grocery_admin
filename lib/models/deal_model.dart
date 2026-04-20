class DealItem {
  final String productId;
  final String? productName;
  final int quantity;
  final double? productPrice;

  DealItem({
    required this.productId,
    this.productName,
    required this.quantity,
    this.productPrice,
  });

  factory DealItem.fromJson(Map<String, dynamic> json) {
    return DealItem(
      productId: json['product_id'].toString(),
      productName: json['products']?['name'],
      quantity: json['quantity'] ?? 1,
      productPrice: (json['products']?['sale_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap(String dealId) {
    return {
      'deal_id': dealId,
      'product_id': productId,
      'quantity': quantity,
    };
  }
}

class Deal {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? imageUrl;
  final bool isActive;
  final DateTime? expiresAt;
  final List<DealItem> items;

  Deal({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    this.isActive = true,
    this.expiresAt,
    this.items = const [],
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    var itemsList = (json['deal_items'] as List? ?? [])
        .map((i) => DealItem.fromJson(i))
        .toList();

    return Deal(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      items: itemsList,
    );
  }

  double get savings => originalPrice != null ? originalPrice! - price : 0;
  int get savingsPercentage => (originalPrice != null && originalPrice! > 0)
      ? ((savings / originalPrice!) * 100).round()
      : 0;
}
