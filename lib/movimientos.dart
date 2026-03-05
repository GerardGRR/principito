import 'package:flutter/material.dart';

class MovimientosPage extends StatelessWidget {
  const MovimientosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildTotalBanner(),
          Padding(
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
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: 8,
              itemBuilder: (context, index) => _buildTransactionCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Color(0xFF1A4661),
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage('https://via.placeholder.com/400x100'), // Simulación de fondo
          opacity: 0.1,
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ventas Totales Acumuladas", style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 8),
          Text("\$24,560.00", style: TextStyle(color: Color(0xFFF1C40F), fontSize: 30, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(int index) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFF1C40F),
          child: Icon(Icons.receipt_long, color: Color(0xFF1A4661)),
        ),
        title: Text("Venta #102$index", style:TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Productos: Cuadernos, Copias\nServicio: CURP"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("\$125.00", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A4661))),
            Text("12:45 PM", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}