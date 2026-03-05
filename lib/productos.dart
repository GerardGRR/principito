import 'package:flutter/material.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _offersController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Detectamos el ancho de la pantalla para ajustar las columnas
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 2 : 4;

    return Scaffold(
      backgroundColor: Colors.white,
      body: RawScrollbar(
        controller: _verticalController,
        thumbColor: const Color(0xFFF1C40F),
        thickness: 12,
        radius: const Radius.circular(10),
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SECCIÓN DE OFERTAS
              _buildOffersSection(screenWidth),

              const SizedBox(height: 20),

              // 2. CABECERA CON FILTROS Y BOTÓN GESTIONAR
              _buildCatalogHeader(screenWidth),

              // 3. GRID DE PRODUCTOS
              _buildProductGrid(crossAxisCount),

              const SizedBox(height: 50),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOffersSection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5D9BBD), Color(0xFF8EBFD4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Text(
            "Novedades y Ofertas Especiales",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: ListView.builder(
            controller: _offersController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 5,
            itemBuilder: (context, index) => Container(
              width: width < 600 ? 300 : 450,
              margin: const EdgeInsets.only(right: 15, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: const Center(child: Icon(Icons.image_outlined, size: 50, color: Colors.black12)),
            ),
          ),
        ),
      ],
    );
  }

  // CABECERA MODIFICADA: Incluye el botón Gestionar y Título
  Widget _buildCatalogHeader(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Nuestro Catálogo",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2A6B91)),
                  ),
                  Text("Todo lo que buscas aquí", style: TextStyle(color: Color(0xFF5D9BBD), fontSize: 14)),
                ],
              ),
              // BOTÓN GESTIONAR (Movido aquí para administración)
              _buildManageButton(),
            ],
          ),
          const SizedBox(height: 20),
          // FILTROS
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: [
              _buildFilterButton(label: "Categorías", onPressed: () {}),
              _buildSortToggle(),
              _buildFilterButton(label: "Filtros (n)", onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  // NUEVO: Botón para editar productos
  Widget _buildManageButton() {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Accediendo al Panel de Edición de Inventario...")),
        );
      },
      icon: const Icon(Icons.edit_note, size: 20),
      label: const Text("Gestionar"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1A4661),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFilterButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2A6B91),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildSortToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFF2A6B91), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Text("Ordenar por", style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xFF1A4661), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: const [
                Text("Aa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Icon(Icons.circle, size: 8, color: Colors.blueAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Center(child: Icon(Icons.inventory_2_outlined, color: Colors.black12, size: 45)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                "Producto ${index + 1}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A4661)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      color: const Color(0xFF1A4661),
      child: const Text(
        "© 2026 Papelería El Principito. Todos los derechos reservados.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}