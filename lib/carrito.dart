import 'package:flutter/material.dart';
import 'database/firebase_service.dart';
import 'database/cart_manager.dart';
import 'models/sale.dart';
import 'models/user.dart';

//Analíticas de Firebase
import 'package:firebase_analytics/firebase_analytics.dart';

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final CartManager _cartManager = CartManager();

  Future<void> _showConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    Color confirmColor = const Color(0xFF1A4661),
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("CONFIRMAR"),
          ),
        ],
      ),
    );
  }

  Future<void> _checkout() async {
    if (_cartManager.products.value.isEmpty &&
        _cartManager.services.value.isEmpty)
      return;

    _showConfirmDialog(
      title: "Confirmar Compra",
      message:
          "¿Estás seguro de procesar esta venta por un total de \$${_cartManager.total.toStringAsFixed(2)}?",
      onConfirm: () async {
        AppUser? user = await _firebaseService.getCurrentUserData();

        final sale = Sale(
          products: List.from(_cartManager.products.value),
          services: List.from(_cartManager.services.value),
          total: _cartManager.total,
          userId: user?.uid ?? "unknown",
          userName: user?.name ?? "Desconocido",
          date: DateTime.now().toIso8601String(),
        );

        await _firebaseService.registerSale(sale);

        // --- NUEVO CÓDIGO: RANKING DE PRODUCTOS VENDIDOS ---
        try {
          for (var p in sale.products) {
            await FirebaseAnalytics.instance.logEvent(
              name: 'producto_vendido',
              parameters: {
                'nombre_articulo': p.name,
                'cantidad': p.quantity,
              },
            );
          }

          // Si también quieres monitorear los servicios:
          for (var s in sale.services) {
            await FirebaseAnalytics.instance.logEvent(
              name: 'servicio_vendido',
              parameters: {
                'nombre_articulo': s.name,
                'cantidad': s.quantity,
              },
            );
          }
        } catch (e) {
          debugPrint("Error registrando analíticas: $e");
        }
        // ---------------------------------------------------

        // Usar clearWithoutRestocking porque el stock ya fue reducido al agregar al carrito
        _cartManager.clearWithoutRestocking();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Venta realizada con éxito"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF1A4661).withOpacity(0.05),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Color(0xFF1A4661)),
                const SizedBox(width: 10),
                const Text(
                  "Resumen de tu pedido",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A4661),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    if (_cartManager.products.value.isNotEmpty ||
                        _cartManager.services.value.isNotEmpty) {
                      _showConfirmDialog(
                        title: "Vaciar Carrito",
                        message:
                            "¿Deseas eliminar todos los artículos del carrito?",
                        confirmColor: Colors.red,
                        onConfirm: () => _cartManager.clear(),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  label: const Text(
                    "Vaciar",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([
                _cartManager.products,
                _cartManager.services,
              ]),
              builder: (context, _) {
                final products = _cartManager.products.value;
                final services = _cartManager.services.value;

                if (products.isEmpty && services.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Tu carrito está vacío",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (products.isNotEmpty) ...[
                      const Text(
                        "PRODUCTOS",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Divider(),
                      ...products.map(
                        (p) => _buildCartItem(p, isProduct: true),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (services.isNotEmpty) ...[
                      const Text(
                        "SERVICIOS",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Divider(),
                      ...services.map(
                        (s) => _buildCartItem(s, isProduct: false),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          _buildTotalSection(),
        ],
      ),
    );
  }

  Widget _buildCartItem(dynamic item, {required bool isProduct}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("\$${item.price.toStringAsFixed(2)} c/u"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Color(0xFF1A4661),
              ),
              onPressed: () => isProduct
                  ? _cartManager.removeProduct(item)
                  : _cartManager.removeService(item),
            ),
            Text(
              "${item.quantity}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF1A4661),
              ),
              onPressed: () => isProduct
                  ? _cartManager.addProduct(item)
                  : _cartManager.addService(item),
            ),
            const SizedBox(width: 10),
            Text(
              "\$${(item.price * item.quantity).toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _cartManager.products,
        _cartManager.services,
      ]),
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL A PAGAR",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "\$${_cartManager.total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A4661),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      (_cartManager.products.value.isEmpty &&
                          _cartManager.services.value.isEmpty)
                      ? null
                      : _checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1C40F),
                    foregroundColor: const Color(0xFF1A4661),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "PROCESAR VENTA",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
