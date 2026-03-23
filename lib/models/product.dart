class Product {
  final int? productId;
  final String name;
  final String description;
  final int quantity;
  final List<String> tags;
  final double price;
  final String brand;
  final String? imagePath;
  final int isActive;
  final int isQuantifiable; // 1: Por cantidad numérica, 0: Solo disponibilidad (booleano)
  final int isAvailable;    // Solo se usa si isQuantifiable es 0 (1: Disponible, 0: Agotado)

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
      'tags': tags.join(','),
      'price': price,
      'brand': brand,
      'imagePath': imagePath,
      'isActive': isActive,
      'isQuantifiable': isQuantifiable,
      'isAvailable': isAvailable,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['productId'],
      name: map['name'],
      description: map['description'],
      quantity: map['quantity'],
      tags: (map['tags'] as String).split(','),
      price: map['price'],
      brand: map['brand'] ?? '',
      imagePath: map['imagePath'],
      isActive: map['isActive'] ?? 1,
      isQuantifiable: map['isQuantifiable'] ?? 1,
      isAvailable: map['isAvailable'] ?? 1,
    );
  }

  Product copyWith({
    int? productId,
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
