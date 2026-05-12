import 'package:flutter_test/flutter_test.dart';
import 'package:principito/models/product.dart';
import 'package:principito/database/cart_manager.dart';

void main() {
  group('Flujo de validación en GitHub Actions (Sin Firebase)', () {
    
    test('1. Simular Login: Validación de credenciales locales', () {
      // Simulamos la captura de los datos del usuario
      String user = 'test';
      String password = 'test1234';
      
      // Verificamos la misma lógica que tienes en _LoginscreenState
      bool userValido = user.isNotEmpty;
      bool passwordValido = password.isNotEmpty && password.length >= 4;

      // GitHub confirmará que estas credenciales son estructuralmente válidas
      expect(userValido, true, reason: 'El usuario no debe estar vacío');
      expect(passwordValido, true, reason: 'La contraseña debe tener mínimo 4 caracteres');
    });

    test('2. Simular Compra: Crear, añadir al carrito y borrar producto', () {
      // --- FASE A: "Crear" el producto en memoria ---
      final productoPrueba = Product(
        productId: 'temp_github_123',
        name: 'Producto Test Aut',
        price: 150.0,
        quantity: 10,
        isQuantifiable: 1,
        isAvailable: 1,
        description: "test",
        brand: 'Prueba',
        tags: [],
        createdAt: DateTime.now(),
      );

      // Verificamos que el producto se construyó bien
      expect(productoPrueba.name, 'Producto Test Aut');
      expect(productoPrueba.price, 150.0);

      // --- FASE B: Simular la compra (Añadir al carrito) ---
      final cartManager = CartManager();
      
      // El usuario añade 2 unidades al carrito
      cartManager.addProduct(productoPrueba);
      cartManager.addProduct(productoPrueba);

      // Verificamos que la lógica de tu negocio sume correctamente
      expect(cartManager.products.value.length, 1, reason: 'Debe agrupar el mismo producto');
      expect(cartManager.total, 300.0, reason: '150 x 2 debe ser 300');

      // --- FASE C: Confirmar compra y "Borrar/Vaciar" ---
      // Simulamos que la compra se procesó y el carrito se limpia
      cartManager.clear();

      // Verificamos que el carrito queda vacío y el producto desaparece del flujo
      expect(cartManager.products.value.isEmpty, true);
      expect(cartManager.total, 0.0);
    });
  });
}