import 'package:flutter/material.dart';
import 'database/firebase_service.dart';
import 'models/sale.dart';

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

  void _showSaleDetails(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          children: [
            const Icon(Icons.receipt_long, size: 50, color: Color(0xFF1A4661)),
            const SizedBox(height: 10),
            Text("Ticket #${sale.dailyId}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Fecha: ${_formatDate(sale.date)}"),
                Text("Vendido por: ${sale.userName}"),
                const Divider(height: 30),
                if (sale.products.isNotEmpty) ...[
                  const Text("PRODUCTOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ...sale.products.map((p) => ListTile(
                    dense: true,
                    title: Text(p.name),
                    subtitle: Text("${p.quantity} x \$${p.price.toStringAsFixed(2)}"),
                    trailing: Text("\$${(p.quantity * p.price).toStringAsFixed(2)}"),
                  )),
                ],
                if (sale.services.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text("SERVICIOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ...sale.services.map((s) => ListTile(
                    dense: true,
                    title: Text(s.name),
                    subtitle: Text("${s.quantity} x \$${s.price.toStringAsFixed(2)}"),
                    trailing: Text("\$${(s.quantity * s.price).toStringAsFixed(2)}"),
                  )),
                ],
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("TOTAL", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("\$${sale.total.toStringAsFixed(2)}", 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A4661))),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Sale>>(
        stream: _firebaseService.getSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1A4661)));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final sales = snapshot.data ?? [];
          double totalSales = sales.fold(0, (sum, item) => sum + item.total);

          return Column(
            children: [
              _buildTotalBanner(totalSales),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Registro de Movimientos",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A4661)),
                  ),
                ),
              ),
              Expanded(
                child: sales.isEmpty
                    ? const Center(child: Text("No hay ventas registradas", style: TextStyle(color: Colors.grey, fontSize: 16)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: sales.length,
                  itemBuilder: (context, index) => _buildTransactionCard(sales[index], index),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalBanner(double totalSales) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: const Color(0xFF1A4661), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ventas Totales Acumuladas", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text("\$${totalSales.toStringAsFixed(2)}",
            style: const TextStyle(color: Color(0xFFF1C40F), fontSize: 30, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Sale sale, int index) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        onTap: () => _showSaleDetails(sale),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFF1C40F),
          child: Icon(Icons.receipt, color: Color(0xFF1A4661), size: 20),
        ),
        title: Text("Venta #${sale.dailyId}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vendido por: ${sale.userName}", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
            Text(_formatDate(sale.date), style: const TextStyle(fontSize: 11)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("\$${sale.total.toStringAsFixed(2)}", 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A4661))),
            const Text("Ver detalle >", style: TextStyle(fontSize: 10, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
