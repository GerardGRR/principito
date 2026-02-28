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
        thumbColor: Color(0xFFF1C40F),
        thickness: 12,
        radius: Radius.circular(10),
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SECCIÓN DE OFERTAS
              _buildOffersSection(screenWidth),

              SizedBox(height: 20),

              // 2. CABECERA CON FILTROS (Responsiva)
              _buildCatalogHeader(screenWidth),

              // 3. GRID DE PRODUCTOS (Ajustado a 2 o 4 columnas)
              _buildProductGrid(crossAxisCount),

               SizedBox(height: 50),
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
          padding: EdgeInsets.fromLTRB(25, 40, 25, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5D9BBD), Color(0xFF8EBFD4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Text(
            "Novedades y Ofertas Especiales",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: ListView.builder(
            controller: _offersController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: 5,
            itemBuilder: (context, index) => Container(
              width: width < 600 ? 300 : 450, // Tarjetas más cortas en móvil
              margin: EdgeInsets.only(right: 15, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: Center(child: Icon(Icons.image_outlined, size: 50, color: Colors.black12)),
            ),
          ),
        ),
        // Barra de scroll horizontal para ofertas
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: Container(
            height: 8,
            decoration: BoxDecoration(color: Color(0xFFD6EAF8), borderRadius: BorderRadius.circular(10)),
            child: RawScrollbar(
              controller: _offersController,
              thumbColor:  Color(0xFFF1C40F),
              thickness: 8,
              radius: Radius.circular(10),
              thumbVisibility: true,
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogHeader(double width) {
    return Padding(
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del catálogo
          Text(
            "Nuestro Catálogo",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2A6B91)),
          ),
          Text("Todo lo que buscas aquí", style: TextStyle(color: Color(0xFF5D9BBD), fontSize: 14)),

          SizedBox(height: 20),

          // FILTROS: Usamos Wrap para que no se corten en el celular
          Wrap(
            spacing: 12, // Espacio horizontal entre botones
            runSpacing: 12, // Espacio vertical si bajan de fila
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

  Widget _buildFilterButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2A6B91),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: Text(label, style: TextStyle(fontSize: 13)),
    );
  }

  Widget _buildSortToggle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(color: Color(0xFF2A6B91), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Text("Ordenar por", style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
          Container(
            padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Color(0xFF1A4661), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children:  [
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
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 25),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75, // Ajusta la proporción de la tarjeta
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
                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(child: Icon(Icons.inventory_2_outlined, color: Colors.black12, size: 45)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Producto ${index + 1}",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A4661)),
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
      padding: EdgeInsets.all(25),
      color: Color(0xFF1A4661),
      child: Text(
        "© 2026 Papelería El Principito. Todos los derechos reservados.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}