import 'package:flutter/material.dart';
import 'database/firebase_service.dart';
import 'database/cart_manager.dart';
import 'models/product.dart';
import 'models/service.dart';

class VentasPage extends StatefulWidget {
  const VentasPage({super.key});

  @override
  State<VentasPage> createState() => _VentasPageState();
}

class _VentasPageState extends State<VentasPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final CartManager _cartManager = CartManager();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Buscar productos o servicios...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A4661)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _firebaseService.getProducts(),
              builder: (context, prodSnapshot) {
                return StreamBuilder<List<Service>>(
                  stream: _firebaseService.getServices(),
                  builder: (context, servSnapshot) {
                    if (prodSnapshot.connectionState == ConnectionState.waiting || 
                        servSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = (prodSnapshot.data ?? [])
                      .where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();
                    final services = (servSnapshot.data ?? [])
                      .where((s) => s.name.toLowerCase().contains(_searchQuery)).toList();

                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (products.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text("PRODUCTOS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A4661))),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 2.2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                            itemCount: products.length,
                            itemBuilder: (context, index) => _buildItemTile(products[index]),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (services.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text("SERVICIOS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A4661))),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 2.2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                            itemCount: services.length,
                            itemBuilder: (context, index) => _buildItemTile(services[index]),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(dynamic item) {
    bool outOfStock = item is Product && item.isQuantifiable == 1 && item.quantity <= 0;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        onTap: outOfStock ? null : () {
          if (item is Product) _cartManager.addProduct(item);
          else if (item is Service) _cartManager.addService(item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${item.name} añadido al carrito"), duration: const Duration(seconds: 1), behavior: SnackBarBehavior.floating),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text("\$${item.price.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                    if (item is Product) Text("Stock: ${item.quantity}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              if (outOfStock)
                const Text("S/S", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12))
              else
                const Icon(Icons.add_shopping_cart, size: 24, color: Color(0xFF1A4661)),
            ],
          ),
        ),
      ),
    );
  }
}
