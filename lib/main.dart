import 'package:flutter/material.dart';
import 'sesion.dart';
import 'home.dart';
import 'impresiones.dart';
import 'productos.dart';
import 'tramites.dart';
import 'movimientos.dart';

void main() => runApp(const ElPrincipitoApp());

class ElPrincipitoApp extends StatelessWidget {
  const ElPrincipitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFF1A4661)),
      home: const Loginscreen(),
    );
  }
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return DefaultTabController(
      length: 5, // Restaurado a 5 pestañas
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A4661),
          elevation: 0,
          toolbarHeight: isMobile ? 120 : 80,
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: isMobile ? _buildMobileHeader() : _buildWebHeader(),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFF1C40F),
            indicatorWeight: 4,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Inicio"),
              Tab(text: "Impresiones"),
              Tab(text: "Productos"),
              Tab(text: "Trámites"), // Sección recuperada
              Tab(text: "Movimientos"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HomePage(),
            ImpresionesPage(),
            ProductosPage(), // Aquí sigue el botón de "Gestionar"
            TramitesPage(),   // Contenido de trámites restaurado
            MovimientosPage(), // Historial de ventas
          ],
        ),
      ),
    );
  }

  // --- CABECERAS (Iguales a tu diseño original) ---
  Widget _buildMobileHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.star, color: Color(0xFFF1C40F), size: 32),
                SizedBox(width: 8),
                Text("El Principito", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            _buildUploadButton(true),
          ],
        ),
        const SizedBox(height: 12),
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildWebHeader() {
    return Row(
      children: [
        const Icon(Icons.star, color: Color(0xFFF1C40F), size: 32),
        const SizedBox(width: 8),
        const Text("El Principito", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(width: 30),
        Expanded(child: _buildSearchBar()),
        const SizedBox(width: 30),
        _buildUploadButton(false),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Buscar...",
          hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
          prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF1A4661)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildUploadButton(bool small) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.upload, size: 20),
        label: Text(small ? "Subir" : "Subir Impresión", style: const TextStyle(fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A4661),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
        ),
      ),
    );
  }
}