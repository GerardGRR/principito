import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/firebase_service.dart';
import '../models/product.dart';

class NovedadesCarousel extends StatelessWidget {
  const NovedadesCarousel({super.key, this.height = 220});
  final double height;

  @override
  Widget build(BuildContext context) {
    final FirebaseService fs = FirebaseService();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: StreamBuilder<List<Product>>(
        stream: fs.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return SizedBox(
              height: height,
              child: Center(
                child: Text(
                  'Error cargando novedades',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            );
          }

          final products = (snapshot.data ?? [])
              // Protege por si hay menos de 10
              .take(10)
              .toList();

          if (products.isEmpty) {
            return SizedBox(
              height: height,
              child: const Center(child: Text('Sin novedades por el momento')),
            );
          }

          return SizedBox(
            height: height,
            child: PageView.builder(
              // El más nuevo debe quedar al inicio: ya viene ordenado por
              // getProducts() (createdAt desc)
              controller: PageController(viewportFraction: 0.9),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                final outOfStock =
                    (p.isQuantifiable == 1 && p.quantity <= 0) ||
                    (p.isQuantifiable == 0 && p.isAvailable == 0);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFD6EAF8),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: _ProductImage(imagePath: p.imagePath),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${p.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF1A4661),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              if (outOfStock)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.4),
                                      ),
                                    ),
                                    child: const Text(
                                      'AGOTADO',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: const Icon(Icons.inventory_2, size: 40, color: Colors.grey),
      );
    }

    if (imagePath!.startsWith('http')) {
      return Image.network(imagePath!, fit: BoxFit.cover);
    }

    try {
      final bytes = base64Decode(imagePath!);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      return Container(
        color: Colors.grey.shade100,
        child: const Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey,
        ),
      );
    }
  }
}
