class Product {
  const Product({required this.id, required this.name, this.description, this.imageUrl});

  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class Bundle {
  const Bundle({
    required this.id,
    required this.name,
    this.description,
    required this.storeUrl,
    this.price,
    required this.products,
  });

  final int id;
  final String name;
  final String? description;
  final String storeUrl;
  final double? price;
  final List<Product> products;

  factory Bundle.fromJson(Map<String, dynamic> json) {
    return Bundle(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      storeUrl: json['storeUrl'] as String,
      price: (json['price'] as num?)?.toDouble(),
      products: (json['products'] as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
