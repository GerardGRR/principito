import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/sale.dart';

class MovimientosPage extends StatefulWidget {
  const MovimientosPage({super.key});

  @override
  State<MovimientosPage> createState() => _MovimientosPageState();
}

class _MovimientosPageState extends State<MovimientosPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Sale> _sales = [];
  double _totalSales = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final sales = await _dbHelper.getSales();
    final total = await _dbHelper.getTotalSales();
    setState(() {
      _sales = sales;
      _totalSales = total;
      _isLoading = false;
    });
  }

  Future<void> _deleteSale(int saleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Venta"),
        content: const Text("¿Estás seguro de eliminar esta venta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.deleteSale(saleId);
      _loadData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Venta eliminada")));
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }

  String _buildItemsText(Sale sale) {
    List<String> items = [];
    if (sale.products.isNotEmpty) {
      items.add("Productos: ${sale.products.map((p) => p.name).join(', ')}");
    }
    if (sale.services.isNotEmpty) {
      items.add("Servicios: ${sale.services.map((s) => s.name).join(', ')}");
    }
    return items.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A4661)),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF1A4661),
        child: Column(
          children: [
            _buildTotalBanner(),
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
              child: _sales.isEmpty
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
                itemCount: _sales.length,
                itemBuilder: (context, index) =>
                    _buildTransactionCard(_sales[index], index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBanner() {
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
            "Ventas Totales Acumuladas",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${_totalSales.toStringAsFixed(2)}",
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

  Widget _buildTransactionCard(Sale sale, int index) {
    return Dismissible(
      key: Key(sale.saleId.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteSale(sale.saleId!),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: const EdgeInsets.only(bottom: 15),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFF1C40F),
            child: Text(
              "#${sale.saleId}",
              style: const TextStyle(
                color: Color(0xFF1A4661),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            "Venta #${sale.saleId}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${_buildItemsText(sale)}\n${_formatDate(sale.date)}",
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$${sale.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A4661),
                ),
              ),
              Text(
                "${sale.products.length + sale.services.length} items",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}