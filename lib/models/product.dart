class Product {
  final String? productId;
  final String name;
  final String description;
  final int quantity;
  final List<String> tags;
  final double price;
  final String brand;
  final String? imagePath;
  final int isActive;
  final int isQuantifiable;
  final int isAvailable;

  Product({
    this.productId,
    required this.name,
    required this.description,
    required this.quantity,
    required this.tags,
    required this.price,
    required this.brand,
    this.imagePath,
    this.isActive = 1,
    this.isQuantifiable = 1,
    this.isAvailable = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'tags': tags,
      'price': price,
      'brand': brand,
      'imagePath': imagePath,
      'isActive': isActive,
      'isQuantifiable': isQuantifiable,
      'isAvailable': isAvailable,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, [String? id]) {
    return Product(
      productId: id ?? map['productId'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 0,
      tags: map['tags'] is List ? List<String>.from(map['tags']) : (map['tags'] as String? ?? '').split(',').where((t) => t.isNotEmpty).toList(),
      price: (map['price'] ?? 0.0).toDouble(),
      brand: map['brand'] ?? '',
      imagePath: map['imagePath'],
      isActive: map['isActive'] ?? 1,
      isQuantifiable: map['isQuantifiable'] ?? 1,
      isAvailable: map['isAvailable'] ?? 1,
    );
  }

  Product copyWith({
    String? productId,
    String? name,
    String? description,
    int? quantity,
    List<String>? tags,
    double? price,
    String? brand,
    String? imagePath,
    int? isActive,
    int? isQuantifiable,
    int? isAvailable,
  }) {
    return Product(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      brand: brand ?? this.brand,
      imagePath: imagePath ?? this.imagePath,
      isActive: isActive ?? this.isActive,
      isQuantifiable: isQuantifiable ?? this.isQuantifiable,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
