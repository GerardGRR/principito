import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:principito/database/firebase_service.dart';
import 'package:principito/models/product.dart';
import 'package:principito/models/sale.dart';
import 'package:principito/models/user.dart';
import 'package:principito/database/cart_manager.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth fakeAuth;
  late FirebaseService firebaseService;
  late CartManager cartManager;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeAuth = MockFirebaseAuth();
    firebaseService = FirebaseService(firestore: fakeFirestore, auth: fakeAuth);
    cartManager = CartManager();
    cartManager.clear();
  });

  group('User Login Flow', () {
    test('Successful login should return user data', () async {
      final uid = 'test-uid';
      final email = 'test@example.com';
      
      // Create user in mock auth
      await fakeAuth.createUserWithEmailAndPassword(email: email, password: 'password123');
      
      // Create user doc in fake firestore
      await fakeFirestore.collection('usuarios').doc(fakeAuth.currentUser!.uid).set({
        'uid': fakeAuth.currentUser!.uid,
        'email': email,
        'username': 'testuser',
        'name': 'Test User',
        'role': 'administrador',
      });

      final userData = await firebaseService.getCurrentUserData();
      expect(userData, isNotNull);
      expect(userData!.email, email);
      expect(userData.username, 'testuser');
    });
  });

  group('Product Management Flow', () {
    test('Should create and then delete a product', () async {
      final product = Product(
        name: 'Cuaderno',
        description: 'Cuaderno de 100 hojas',
        quantity: 10,
        tags: ['escolar'],
        price: 25.50,
        brand: 'Scribe',
      );

      // Add product
      await firebaseService.addProduct(product);
      
      var products = await firebaseService.getProducts().first;
      expect(products.length, 1);
      expect(products.first.name, 'Cuaderno');

      final productId = products.first.productId!;

      // Delete (soft delete)
      await firebaseService.deleteProduct(productId);
      
      products = await firebaseService.getProducts().first;
      expect(products.length, 0); // isAtive = 0 filters it out in getProducts()
    });
  });

  group('Shopping Flow (Checkout)', () {
    test('Should add items to cart and complete checkout', () async {
      // 1. Create a product in DB
      final product = Product(
        productId: 'prod-1',
        name: 'Lápiz',
        description: 'Lápiz HB',
        quantity: 50,
        tags: ['escolar'],
        price: 5.0,
        brand: 'Bic',
      );
      await fakeFirestore.collection('products').doc('prod-1').set(product.toMap()..['isActive'] = 1);

      // 2. Add to cart
      cartManager.addProduct(product);
      expect(cartManager.products.value.length, 1);
      expect(cartManager.total, 5.0);

      // 3. Register Sale
      final sale = Sale(
        products: cartManager.products.value,
        services: [],
        total: cartManager.total,
        userId: 'user-1',
        userName: 'Vendedor Test',
        date: DateTime.now().toIso8601String(),
      );

      await firebaseService.registerSale(sale);

      // 4. Verify Sale in DB
      final sales = await firebaseService.getSales().first;
      expect(sales.length, 1);
      expect(sales.first.total, 5.0);

      // 5. Verify stock reduction
      final updatedProductDoc = await fakeFirestore.collection('products').doc('prod-1').get();
      expect(updatedProductDoc.data()!['quantity'], 49);
    });
  });
}
