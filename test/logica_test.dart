import 'package:flutter_test/flutter_test.dart';
import 'package:el_principito/models/product.dart';

void main() {
  group('Flujo de validación en GitHub Actions (Puro Dart)', () {

    test('1. Simular Login: Validación de reglas locales', () {
      String user = 'test';
      String password = 'test1234';

      bool userValido = user.isNotEmpty;
      bool passwordValido = password.isNotEmpty && password.length >= 4;

      expect(userValido, true, reason: 'El usuario no debe estar vacío');
      expect(passwordValido, true, reason: 'La contraseña debe tener mínimo 4 caracteres');
    });

    test('2. Simular Compra: Lógica de carrito y totales', () {
      final productoPrueba = Product(
        productId: 'temp_github_123',
        name: 'Producto Test Aut',
        description: 'Descripción para prueba sin BD',
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

      List<Product> carritoVirtual = [];

      carritoVirtual.add(productoPrueba);
      carritoVirtual.add(productoPrueba);

      double total = carritoVirtual.fold(0, (sum, item) => sum + item.price);

      expect(carritoVirtual.length, 2, reason: 'Debe haber 2 artículos');
      expect(total, 300.0, reason: '150 x 2 debe dar 300 cerrado');

      carritoVirtual.clear();
      total = 0.0;

      expect(carritoVirtual.isEmpty, true, reason: 'El carrito debe quedar limpio');
      expect(total, 0.0, reason: 'El total debe resetearse a 0');
    });
  });
}