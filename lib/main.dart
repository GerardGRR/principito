import 'package:flutter/material.dart';
import 'sesion.dart';
import 'home.dart';
import 'impresiones.dart';
import 'productos.dart';
import 'tramites.dart';

void main() => runApp(const ElPrincipitoApp());

class ElPrincipitoApp extends StatelessWidget {
  const ElPrincipitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFF1A4661)),
      home: const LoginPage(),
    );
  }
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    // Detectamos si la pantalla es pequeña (Móvil)
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF1A4661),
          elevation: 0,
          // Aumentamos el alto del AppBar en móvil para acomodar dos filas
          toolbarHeight: isMobile ? 120 : 80,
          title: Padding(
            padding: EdgeInsets.only(top: 10),
            child: isMobile
                ? _buildMobileHeader() // Logo arriba, buscador abajo
                : _buildWebHeader(),   // Todo en una sola fila (PC)
          ),
          bottom: TabBar(
            indicatorColor: Color(0xFFF1C40F),
            indicatorWeight: 4,
            isScrollable: true, // EVITA QUE LAS PESTAÑAS SE AMONTONEN
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Inicio"),
              Tab(text: "Impresiones"),
              Tab(text: "Productos"),
              Tab(text: "Servicios"),
              Tab(text: "Gestionar"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HomePage(),
            ImpresionesPage(),
            ProductosPage(),
            TramitesPage(),
            Center(child: Text("Panel de Gestión")),
          ],
        ),
      ),
    );
  }

  // --- DISEÑO PARA CELULAR ---
  Widget _buildMobileHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Color(0xFFF1C40F), size: 24),
                SizedBox(width: 8),
                Text("El Principito", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            _buildUploadButton(true), // Botón compacto
          ],
        ),
        SizedBox(height: 12),
        _buildSearchBar(), // El buscador toma todo el ancho disponible abajo
      ],
    );
  }

  // --- DISEÑO PARA COMPUTADORA ---
  Widget _buildWebHeader() {
    return Row(
      children: [
        Icon(Icons.star, color: Color(0xFFF1C40F), size: 28),
        SizedBox(width: 8),
        Text("El Principito", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(width: 30),
        Expanded(child: _buildSearchBar()),
        SizedBox(width: 30),
        _buildUploadButton(false),
      ],
    );
  }

  // COMPONENTE: Buscador estilizado
  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child:  TextField(
        decoration: InputDecoration(
          hintText: "Buscar Productos...",
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF1A4661)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  // COMPONENTE: Botón de Subida
  Widget _buildUploadButton(bool small) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon:  Icon(Icons.upload, size: 16),
      label: Text(
          small ? "Subir" : "Subir Impresión",
          style: TextStyle(fontSize: 11)
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A4661),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 12),
        elevation: 0,
      ),
    );
  }
}