import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/service.dart';

class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final ValueNotifier<List<Product>> products = ValueNotifier([]);
  final ValueNotifier<List<Service>> services = ValueNotifier([]);

  void addProduct(Product product) {
    List<Product> current = List.from(products.value);
    int index = current.indexWhere((p) => p.productId == product.productId);
    if (index != -1) {
      current[index] = current[index].copyWith(quantity: current[index].quantity + 1);
    } else {
      current.add(product.copyWith(quantity: 1));
    }
    products.value = current;
  }

  void removeProduct(Product product) {
    List<Product> current = List.from(products.value);
    int index = current.indexWhere((p) => p.productId == product.productId);
    if (index != -1) {
      if (current[index].quantity > 1) {
        current[index] = current[index].copyWith(quantity: current[index].quantity - 1);
      } else {
        current.removeAt(index);
      }
    }
    products.value = current;
  }

  void addService(Service service) {
    List<Service> current = List.from(services.value);
    int index = current.indexWhere((s) => s.serviceId == service.serviceId);
    if (index != -1) {
      current[index] = current[index].copyWith(quantity: current[index].quantity + 1);
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
        current[index] = current[index].copyWith(quantity: current[index].quantity - 1);
      } else {
        current.removeAt(index);
      }
    }
    services.value = current;
  }

  void clear() {
    products.value = [];
    services.value = [];
  }

  double get total {
    double pTotal = products.value.fold(0.0, (sum, p) => sum + (p.price * p.quantity));
    double sTotal = services.value.fold(0.0, (sum, s) => sum + (s.price * s.quantity));
    return pTotal + sTotal;
  }
}
