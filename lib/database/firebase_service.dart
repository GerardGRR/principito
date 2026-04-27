import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/service.dart';
import '../models/sale.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Products ---
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    if (product.productId != null) {
      await _firestore.collection('products').doc(product.productId).update(product.toMap());
    }
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).update({'isActive': 0});
  }

  Stream<List<Product>> getProducts() {
    return _firestore.collection('products')
        .where('isActive', isEqualTo: 1)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  // --- Services ---
  Future<void> addService(Service service) async {
    await _firestore.collection('services').add(service.toMap());
  }

  Future<void> updateService(Service service) async {
    if (service.serviceId != null) {
      await _firestore.collection('services').doc(service.serviceId).update(service.toMap());
    }
  }

  Future<void> deleteService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).update({'isActive': 0});
  }

  Stream<List<Service>> getServices() {
    return _firestore.collection('services')
        .where('isActive', isEqualTo: 1)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Service.fromMap(doc.data(), doc.id))
            .toList());
  }

  // --- Sales ---
  Future<void> registerSale(Sale sale) async {
    WriteBatch batch = _firestore.batch();

    // Register sale
    DocumentReference saleRef = _firestore.collection('sales').doc();
    batch.set(saleRef, sale.toMap());

    // Update product quantities
    for (var product in sale.products) {
      if (product.productId != null && product.isQuantifiable == 1) {
        DocumentReference prodRef = _firestore.collection('products').doc(product.productId);
        batch.update(prodRef, {
          'quantity': FieldValue.increment(-product.quantity)
        });
      }
    }

    await batch.commit();
  }

  Stream<List<Sale>> getSales() {
    return _firestore.collection('sales')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Sale.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteSale(String saleId) async {
    await _firestore.collection('sales').doc(saleId).delete();
  }
}
