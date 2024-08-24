class Product {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final double price;
  final int discount;
  final bool isOutOfStock;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.price,
    required this.discount,
    required this.isOutOfStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrls: json['imageUrls'] is String
          ? (json['imageUrls'] as String)
              .split(',')
              .map((url) => url.trim())
              .toList()
          : List<String>.from(json['imageUrls'] ?? []),
      price: json['price']?.toDouble() ?? 0.0,
      discount: (json['discount'] as num).toDouble().toInt(),
      isOutOfStock: json['isOutOfStock'] ?? false,
    );
  }
}
