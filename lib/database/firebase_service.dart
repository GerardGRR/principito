import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/service.dart';
import '../models/sale.dart';
import '../models/user.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Users ---
  Future<AppUser?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, user.uid);
      }
    }
    return null;
  }

  Stream<AppUser?> streamCurrentUserData() {
    User? user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return _firestore.collection('usuarios').doc(user.uid).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, user.uid);
      }
      return null;
    });
  }

  Stream<List<AppUser>> getAllUsers() {
    return _firestore.collection('usuarios').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => AppUser.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    if (newRole != 'administrador') {
      QuerySnapshot admins = await _firestore.collection('usuarios')
          .where('role', isEqualTo: 'administrador').get();
      if (admins.docs.length <= 1 && admins.docs.first.id == uid) {
        throw Exception("No se puede quitar el rol al único administrador");
      }
    }
    await _firestore.collection('usuarios').doc(uid).update({'role': newRole});
  }

  Future<AppUser?> getUserByUsername(String username) async {
    var query = await _firestore.collection('usuarios')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return AppUser.fromMap(query.docs.first.data(), query.docs.first.id);
    }
    return null;
  }

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
  Future<String> _getNextDailyId() async {
    String today = DateTime.now().toIso8601String().split('T')[0];
    DocumentReference counterRef = _firestore.collection('counters').doc(today);

    return await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(counterRef);

      int currentCount = 1;
      if (snapshot.exists) {
        currentCount = (snapshot.data() as Map<String, dynamic>)['count'] + 1;
      }

      transaction.set(counterRef, {'count': currentCount});
      return currentCount.toString().padLeft(3, '0');
    });
  }

  Future<void> registerSale(Sale sale) async {
    WriteBatch batch = _firestore.batch();
    
    String dailyId = await _getNextDailyId();
    DocumentReference saleRef = _firestore.collection('sales').doc();
    
    Sale saleWithId = Sale(
      saleId: saleRef.id,
      dailyId: dailyId,
      products: sale.products,
      services: sale.services,
      total: sale.total,
      userId: sale.userId,
      userName: sale.userName,
      date: sale.date,
    );

    Map<String, dynamic> data = saleWithId.toMap();
    data['isReturned'] = false; // Flag to prevent multiple returns

    batch.set(saleRef, data);

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

  Future<void> registerReturn(Sale originalSale, Map<String, int> returns, String reason) async {
    WriteBatch batch = _firestore.batch();
    
    // Check if already returned (safety check, should be handled by UI too)
    DocumentReference originalRef = _firestore.collection('sales').doc(originalSale.saleId);
    batch.update(originalRef, {'isReturned': true});

    double refundTotal = 0;
    List<Product> returnedProducts = [];

    returns.forEach((productId, qty) {
      if (qty > 0) {
        DocumentReference prodRef = _firestore.collection('products').doc(productId);
        batch.update(prodRef, {
          'quantity': FieldValue.increment(qty)
        });
        
        var p = originalSale.products.firstWhere((element) => element.productId == productId);
        refundTotal += (p.price * qty);
        returnedProducts.add(p.copyWith(quantity: qty));
      }
    });

    DocumentReference returnRef = _firestore.collection('sales').doc();
    
    Sale returnRecord = Sale(
      saleId: returnRef.id,
      dailyId: "DEV-${originalSale.dailyId}", 
      products: returnedProducts,
      services: [], 
      total: -refundTotal,
      userId: originalSale.userId,
      userName: "DEVOLUCIÓN: ${originalSale.userName} (Motivo: $reason)",
      date: DateTime.now().toIso8601String(),
    );

    Map<String, dynamic> returnData = returnRecord.toMap();
    returnData['isReturned'] = true; // Returns themselves cannot be returned

    batch.set(returnRef, returnData);

    await batch.commit();
  }

  Stream<List<Sale>> getSales() {
    return _firestore.collection('sales')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              // Create sale object and inject the 'isReturned' field if needed
              // or handle it in the model. Let's handle it here for now or update Sale model.
              return Sale.fromMap(data, doc.id);
            })
            .toList());
  }

  Future<bool> isSaleReturned(String saleId) async {
    DocumentSnapshot doc = await _firestore.collection('sales').doc(saleId).get();
    if (doc.exists) {
      return (doc.data() as Map<String, dynamic>)['isReturned'] ?? false;
    }
    return false;
  }

  Future<void> deleteSale(String saleId) async {
    await _firestore.collection('sales').doc(saleId).delete();
  }
}
