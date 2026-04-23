class Category {
  final String id;
  final String name;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}
