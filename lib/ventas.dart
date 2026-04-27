import 'dart:io';
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

  void _showQuantityModal(dynamic item) {
    final TextEditingController qtyController = TextEditingController(text: "1");
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Añadir ${item.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("¿Cuántas unidades deseas añadir?"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 32, color: Color(0xFF1A4661)),
                    onPressed: () {
                      if (quantity > 1) {
                        setDialogState(() {
                          quantity--;
                          qtyController.text = quantity.toString();
                        });
                      }
                    },
                  ),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: qtyController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        int? newVal = int.tryParse(val);
                        if (newVal != null && newVal > 0) {
                          quantity = newVal;
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 32, color: Color(0xFF1A4661)),
                    onPressed: () {
                      setDialogState(() {
                        quantity++;
                        qtyController.text = quantity.toString();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A4661),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                for (int i = 0; i < quantity; i++) {
                  if (item is Product) _cartManager.addProduct(item);
                  else if (item is Service) _cartManager.addService(item);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$quantity x ${item.name} añadido(s) al carrito"),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF1A4661),
                  ),
                );
              },
              child: const Text("AÑADIR AL CARRITO"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Buscar productos o servicios...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1A4661)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        if (products.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text("PRODUCTOS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A4661))),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, 
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 10, 
                              mainAxisSpacing: 10
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) => _buildItemTile(products[index]),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (services.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text("SERVICIOS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A4661))),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, 
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 10, 
                              mainAxisSpacing: 10
                            ),
                            itemCount: services.length,
                            itemBuilder: (context, index) => _buildItemTile(services[index]),
                          ),
                        ],
                        const SizedBox(height: 20),
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
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), 
        side: BorderSide(color: outOfStock ? Colors.red.shade100 : Colors.grey.shade200)
      ),
      child: InkWell(
        onTap: outOfStock ? null : () => _showQuantityModal(item),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: item.imagePath != null && item.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.file(
                        File(item.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
                      ),
                    )
                  : const Icon(Icons.inventory_2, size: 30, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${item.price.toStringAsFixed(2)}", 
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)
                            ),
                            if (item is Product) 
                              Text(
                                "Stock: ${item.quantity}", 
                                style: TextStyle(fontSize: 10, color: outOfStock ? Colors.red : Colors.grey)
                              ),
                          ],
                        ),
                        if (outOfStock)
                          const Text("AGOTADO", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
