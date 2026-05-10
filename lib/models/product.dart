import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? productId;
  final DateTime? createdAt;
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
    this.createdAt,
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
      // OJO: si no hay createdAt, Firestore recibe null (y no rompe el orderBy)
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
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
    DateTime? createdAt;
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else {
      createdAt = null;
    }

    return Product(
      productId: id ?? map['productId'],
      createdAt: createdAt,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      quantity: map['quantity'] ?? 0,
      tags: map['tags'] is List
          ? List<String>.from(map['tags'])
          : (map['tags'] as String? ?? '')
                .split(',')
                .where((t) => t.isNotEmpty)
                .toList(),
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
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
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
