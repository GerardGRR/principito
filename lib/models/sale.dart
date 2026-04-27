import 'product.dart';
import 'service.dart';

class Sale {
  final String? saleId;
  final List<Product> products;
  final List<Service> services;
  final double total;
  final String userId;
  final String date;

  Sale({
    this.saleId,
    required this.products,
    required this.services,
    required this.total,
    required this.userId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'saleId': saleId,
      'products': products.map((p) => p.toMap()).toList(),
      'services': services.map((s) => s.toMap()).toList(),
      'total': total,
      'userId': userId,
      'date': date,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, [String? id]) {
    return Sale(
      saleId: id ?? map['saleId'],
      products: (map['products'] as List? ?? [])
          .map((p) => Product.fromMap(p as Map<String, dynamic>))
          .toList(),
      services: (map['services'] as List? ?? [])
          .map((s) => Service.fromMap(s as Map<String, dynamic>))
          .toList(),
      total: (map['total'] ?? 0.0).toDouble(),
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
    );
  }
}
