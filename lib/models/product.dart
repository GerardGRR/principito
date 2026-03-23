class Product {
  final int? productId;
  final String name;
  final String description;
  final int quantity;
  final List<String> tags;
  final double price;
  final String branch;
  final int isActive; // 1 for true, 0 for false

  Product({
    this.productId,
    required this.name,
    required this.description,
    required this.quantity,
    required this.tags,
    required this.price,
    required this.branch,
    this.isActive = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'tags': tags.join(','),
      'price': price,
      'branch': branch,
      'isActive': isActive,
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
      branch: map['branch'],
      isActive: map['isActive'] ?? 1,
    );
  }

  Product copyWith({
    int? productId,
    String? name,
    String? description,
    int? quantity,
    List<String>? tags,
    double? price,
    String? branch,
    int? isActive,
  }) {
    return Product(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      branch: branch ?? this.branch,
      isActive: isActive ?? this.isActive,
    );
  }
}
