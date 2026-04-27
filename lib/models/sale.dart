import 'product.dart';
import 'service.dart';

class Sale {
  final String? saleId; // Firebase Document ID
  final String? dailyId; // 3-digit autoincremental ID (001, 002...)
  final List<Product> products;
  final List<Service> services;
  final double total;
  final String userId;
  final String userName; // "Vendido por"
  final String date;

  Sale({
    this.saleId,
    this.dailyId, // Ahora es opcional en el constructor
    required this.products,
    required this.services,
    required this.total,
    required this.userId,
    required this.userName,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'saleId': saleId,
      'dailyId': dailyId,
      'products': products.map((p) => p.toMap()).toList(),
      'services': services.map((s) => s.toMap()).toList(),
      'total': total,
      'userId': userId,
      'userName': userName,
      'date': date,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, [String? id]) {
    return Sale(
      saleId: id ?? map['saleId'],
      dailyId: map['dailyId'] ?? '000',
      products: (map['products'] as List? ?? [])
          .map((p) => Product.fromMap(p as Map<String, dynamic>))
          .toList(),
      services: (map['services'] as List? ?? [])
          .map((s) => Service.fromMap(s as Map<String, dynamic>))
          .toList(),
      total: (map['total'] ?? 0.0).toDouble(),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Desconocido',
      date: map['date'] ?? '',
    );
  }
}
