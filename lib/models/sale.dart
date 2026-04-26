import 'user.dart';
import 'product.dart';
import 'service.dart';

class Sale {
  final int? saleId;
  final List<Product> products;
  final List<Service> services;
  final double total;
  final int userId; // Foreign key to User
  final String date; // Fecha de la venta

  Sale({
    this.saleId,
    required this.products,
    required this.services,
    required this.total,
    required this.userId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {'saleId': saleId, 'total': total, 'userId': userId, 'date': date};
  }

  factory Sale.fromMap(
    Map<String, dynamic> map, {
    List<Product> products = const [],
    List<Service> services = const [],
  }) {
    return Sale(
      saleId: map['saleId'],
      products: products,
      services: services,
      total: map['total'],
      userId: map['userId'],
      date: map['date'] ?? '',
    );
  }
}
