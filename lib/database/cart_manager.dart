import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/service.dart';
import 'firebase_service.dart';

class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final ValueNotifier<List<Product>> products = ValueNotifier([]);
  final ValueNotifier<List<Service>> services = ValueNotifier([]);

  // Mapeo para rastrear el stock original de cada producto
  final Map<String?, int> _originalStock = {};

  void addProduct(Product product) {
    List<Product> current = List.from(products.value);
    int index = current.indexWhere((p) => p.productId == product.productId);

    if (index != -1) {
      current[index] = current[index].copyWith(
        quantity: current[index].quantity + 1,
      );
    } else {
      current.add(product.copyWith(quantity: 1));
      // Guardar stock original si es la primera vez
      if (!_originalStock.containsKey(product.productId)) {
        _originalStock[product.productId] = product.quantity;
      }
    }
    products.value = current;

    // Actualizar stock en Firestore (restar 1)
    if (product.productId != null) {
      final originalStock =
          _originalStock[product.productId] ?? product.quantity;
      final currentCarted = current
          .firstWhere((p) => p.productId == product.productId)
          .quantity;
      _firebaseService.updateProductQuantity(
        product.productId!,
        originalStock - currentCarted,
      );
    }
  }

  void removeProduct(Product product) {
    List<Product> current = List.from(products.value);
    int index = current.indexWhere((p) => p.productId == product.productId);
    if (index != -1) {
      if (current[index].quantity > 1) {
        current[index] = current[index].copyWith(
          quantity: current[index].quantity - 1,
        );
      } else {
        current.removeAt(index);
      }

      // Restaurar stock en Firestore
      if (product.productId != null) {
        final originalStock =
            _originalStock[product.productId] ?? product.quantity;
        final cartedCount = current
            .where((p) => p.productId == product.productId)
            .fold<int>(0, (sum, p) => sum + p.quantity);
        _firebaseService.updateProductQuantity(
          product.productId!,
          originalStock - cartedCount,
        );
      }
    }
    products.value = current;
  }

  void addService(Service service) {
    List<Service> current = List.from(services.value);
    int index = current.indexWhere((s) => s.serviceId == service.serviceId);
    if (index != -1) {
      current[index] = current[index].copyWith(
        quantity: current[index].quantity + 1,
      );
    } else {
      current.add(service.copyWith(quantity: 1));
    }
    services.value = current;
  }

  void removeService(Service service) {
    List<Service> current = List.from(services.value);
    int index = current.indexWhere((s) => s.serviceId == service.serviceId);
    if (index != -1) {
      if (current[index].quantity > 1) {
        current[index] = current[index].copyWith(
          quantity: current[index].quantity - 1,
        );
      } else {
        current.removeAt(index);
      }
    }
    services.value = current;
  }

  void clear() {
    // Restaurar stock de todos los productos antes de limpiar
    for (var product in products.value) {
      if (product.productId != null) {
        final originalStock =
            _originalStock[product.productId] ?? product.quantity;
        _firebaseService.updateProductQuantity(
          product.productId!,
          originalStock, // Restaurar stock original
        );
      }
    }
    products.value = [];
    services.value = [];
    _originalStock.clear();
  }

  void clearWithoutRestocking() {
    // Limpiar carrito sin restaurar stock (para usar después de completar venta)
    products.value = [];
    services.value = [];
    _originalStock.clear();
  }

  double get total {
    double pTotal = products.value.fold(
      0.0,
      (sum, p) => sum + (p.price * p.quantity),
    );
    double sTotal = services.value.fold(
      0.0,
      (sum, s) => sum + (s.price * s.quantity),
    );
    return pTotal + sTotal;
  }
}
