# TODO - Carrusel de Novedades (10 productos más nuevos)

- [x] Actualizar `lib/models/product.dart` para agregar campo `createdAt` y manejar `toMap/fromMap`.
- [x] Actualizar `lib/database/firebase_service.dart`:
  - [x] Ordenar `getProducts()` por `createdAt` descendente.
  - [ ] (Opcional) Limitar a 10 en Firestore (por ahora se toma con `.take(10)` en UI).
- [x] Actualizar `lib/productos.dart` para que al guardar un producto nuevo incluya `createdAt` automáticamente.
- [x] Crear `lib/home_novedades_carousel.dart` con `PageView` mostrando 10 productos más nuevos (orden por createdAt).
- [x] Actualizar `lib/home.dart` para mostrar la sección “Novedades” y renderizar el carrusel.
- [ ] Verificar visualmente en la app que el producto más nuevo quede primero al agregar un nuevo producto.

