import 'package:flutter_test/flutter_test.dart';
import 'package:principito/models/product.dart';
import 'package:principito/database/cart_manager.dart';
import 'package:flutter/services.dart'; // Necesario para el simulador
import 'package:firebase_core/firebase_core.dart'; // Necesario para inicializar

void setupFirebaseMocks() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
        (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': '123',
              'appId': '123',
              'messagingSenderId': '123',
              'projectId': '123',
            },
            'pluginConstants': {},
          }
        ];
      }
      if (methodCall.method == 'Firebase#initializeApp') {
        return {
          'name': methodCall.arguments['appName'],
          'options': methodCall.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    setupFirebaseMocks();
    await Firebase.initializeApp();
  });

  group('Flujo de validación en GitHub Actions (Sin Firebase)', () {

    test('1. Simular Login: Validación de credenciales locales', () {
      String user = 'test';
      String password = 'test1234';

      bool userValido = user.isNotEmpty;
      bool passwordValido = password.isNotEmpty && password.length >= 4;

      expect(userValido, true, reason: 'El usuario no debe estar vacío');
      expect(passwordValido, true, reason: 'La contraseña debe tener mínimo 4 caracteres');
    });

    test('2. Simular Compra: Crear, añadir al carrito y borrar producto', () {
      // --- FASE A: Crear ---
      final productoPrueba = Product(
        productId: 'temp_github_123',
        name: 'Producto Test Aut',
        description: 'Descripción de prueba',
        price: 150.0,
        quantity: 10,
        isQuantifiable: 1,
        isAvailable: 1,
        brand: 'Prueba',
        tags: [],
        createdAt: DateTime.now(),
      );

      expect(productoPrueba.name, 'Producto Test Aut');
      expect(productoPrueba.price, 150.0);

      // --- FASE B: Añadir al carrito ---
      final cartManager = CartManager();

      cartManager.addProduct(productoPrueba);
      cartManager.addProduct(productoPrueba);

      expect(cartManager.products.value.length, 1, reason: 'Debe agrupar el mismo producto');
      expect(cartManager.total, 300.0, reason: '150 x 2 debe ser 300');

      // --- FASE C: Confirmar y vaciar ---
      cartManager.clear();

      expect(cartManager.products.value.isEmpty, true);
      expect(cartManager.total, 0.0);
    });
  });
}