import 'package:flutter/material.dart';
import 'database/firebase_service.dart';
import 'models/sale.dart';
import 'models/user.dart';

import 'package:firebase_analytics/firebase_analytics.dart';


class MovimientosPage extends StatefulWidget {
  const MovimientosPage({super.key});
  @override
  State<MovimientosPage> createState() => _MovimientosPageState();
}

class _MovimientosPageState extends State<MovimientosPage> {
  final FirebaseService _firebaseService = FirebaseService();

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }

  void _showSaleDetails(Sale sale, bool isAdmin) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isReturn = sale.dailyId?.startsWith("DEV-") ?? false;
          bool alreadyReturned = sale.isReturned;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Column(
              children: [
                Icon(
                  isReturn ? Icons.assignment_return : Icons.receipt_long,
                  size: 50,
                  color: isReturn ? Colors.orange : const Color(0xFF1A4661),
                ),
                const SizedBox(height: 10),
                Text(
                  isReturn
                      ? "Devolución #${sale.dailyId}"
                      : "Ticket #${sale.dailyId}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Fecha: ${_formatDate(sale.date)}"),
                    Text(sale.userName),
                    if (alreadyReturned && !isReturn)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          "ESTADO: DEVUELTA",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Divider(height: 30),
                    if (sale.products.isNotEmpty) ...[
                      const Text(
                        "PRODUCTOS",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      ...sale.products.map(
                        (p) => ListTile(
                          dense: true,
                          title: Text(p.name),
                          subtitle: Text(
                            "${p.quantity} x \$${p.price.toStringAsFixed(2)}",
                          ),
                          trailing: Text(
                            "\$${(p.quantity * p.price).toStringAsFixed(2)}",
                          ),
                        ),
                      ),
                    ],
                    if (sale.services.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        "SERVICIOS (No reembolsables)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                      ...sale.services.map(
                        (s) => ListTile(
                          dense: true,
                          title: Text(s.name),
                          subtitle: Text(
                            "${s.quantity} x \$${s.price.toStringAsFixed(2)}",
                          ),
                          trailing: Text(
                            "\$${(s.quantity * s.price).toStringAsFixed(2)}",
                          ),
                        ),
                      ),
                    ],
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TOTAL",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "\$${sale.total.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isReturn
                                ? Colors.red
                                : const Color(0xFF1A4661),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (isAdmin && !isReturn && !alreadyReturned)
                ElevatedButton.icon(
                  onPressed: () => _showReturnDialog(sale),
                  icon: const Icon(Icons.keyboard_return, color: Colors.white),
                  label: const Text("REGISTRAR DEVOLUCIÓN"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReturnDialog(Sale sale) {
    final TextEditingController reasonController = TextEditingController();
    Map<String, int> returns = {};
    for (var p in sale.products) {
      returns[p.productId!] = p.quantity;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Devolución"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Se creará un registro espejo de devolución."),
              const SizedBox(height: 10),
              const Text(
                "Artículos a devolver (stock reintegrado):",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              ...sale.products.map((p) => Text("• ${p.name} (x${p.quantity})")),
              if (sale.services.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  "Nota: Los servicios NO se reembolsan ni se reintegran.",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: "Motivo de la devolución",
                  border: OutlineInputBorder(),
                  hintText: "Ej. Producto defectuoso, error en cobro...",
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Por favor ingresa un motivo")),
                );
                return;
              }
              await _firebaseService.registerReturn(
                sale,
                returns,
                reasonController.text.trim(),
              );

              // --- ANALÍTICAS DE DEVOLUCIÓN ---
              try {
                List<AnalyticsEventItem> itemsDevueltos = [];
                double valorReembolsado = 0;

                for (var p in sale.products) {
                  itemsDevueltos.add(AnalyticsEventItem(
                    itemId: p.productId,
                    itemName: p.name,
                    quantity: p.quantity,
                    price: p.price,
                  ));
                  valorReembolsado += (p.price * p.quantity);
                }

                await FirebaseAnalytics.instance.logRefund(
                  currency: "MXN",
                  value: valorReembolsado, // Solo el valor de los productos
                  items: itemsDevueltos,
                );
              } catch (e) {
                debugPrint("Error registrando reembolso en analíticas: $e");
              }
              // ----------------------------------------------

              if (mounted) {
                Navigator.pop(context); // Cierra confirmación
                Navigator.pop(context); // Cierra detalle
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Devolución registrada exitosamente"),
                  ),
                );
              }
            },
            child: const Text("CONFIRMAR DEVOLUCIÓN"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: _firebaseService.streamCurrentUserData(),
      builder: (context, userSnapshot) {
        final userRole = userSnapshot.data?.role?.toLowerCase();
        final isAdmin = userRole == 'administrador';
        final isEmployee = userRole == 'empleado' || isAdmin;

        // Si es un usuario común, no puede ver el historial
        if (userRole == 'usuario') {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  "Acceso Restringido",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "Solo empleados pueden ver el historial.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: StreamBuilder<List<Sale>>(
            stream: _firebaseService.getSales(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1A4661)),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              final sales = snapshot.data ?? [];
              double totalSales = sales.fold(
                0,
                (sum, item) => sum + item.total,
              );

              return Column(
                children: [
                  // Solo administradores ven el balance total
                  if (isAdmin) _buildTotalBanner(totalSales),
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Registro de Movimientos",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A4661),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: sales.isEmpty
                        ? const Center(
                            child: Text(
                              "No hay ventas registradas",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: sales.length,
                            itemBuilder: (context, index) =>
                                _buildTransactionCard(sales[index], isAdmin),
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTotalBanner(double totalSales) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF1A4661),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Balance Total (Ventas - Devoluciones)",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${totalSales.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Color(0xFFF1C40F),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Sale sale, bool isAdmin) {
    bool isReturn = sale.dailyId?.startsWith("DEV-") ?? false;
    bool alreadyReturned = sale.isReturned;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isReturn
              ? Colors.orange.shade100
              : (alreadyReturned ? Colors.red.shade50 : Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        onTap: () => _showSaleDetails(sale, isAdmin),
        leading: CircleAvatar(
          backgroundColor: isReturn
              ? Colors.orange.shade100
              : (alreadyReturned
                    ? Colors.red.shade50
                    : const Color(0xFFF1C40F)),
          child: Icon(
            isReturn ? Icons.assignment_return : Icons.receipt,
            color: const Color(0xFF1A4661),
            size: 20,
          ),
        ),
        title: Text(
          isReturn ? "Devolución #${sale.dailyId}" : "Venta #${sale.dailyId}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isReturn
                ? Colors.orange.shade900
                : (alreadyReturned ? Colors.red.shade900 : Colors.black),
            decoration: alreadyReturned && !isReturn
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sale.userName,
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
            ),
            Text(_formatDate(sale.date), style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "\$${sale.total.toStringAsFixed(2)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isReturn ? Colors.red : const Color(0xFF1A4661),
              ),
            ),
            const Text(
              "Ver detalle >",
              style: TextStyle(fontSize: 10, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
