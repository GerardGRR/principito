import 'package:flutter/material.dart';

class TramitesPage extends StatelessWidget {
  const TramitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController1 = ScrollController();
    final ScrollController _scrollController2 = ScrollController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección Trámites
            _buildBlueHeader("Trámites"),
            _buildHorizontalSection(_scrollController1),

            SizedBox(height: 20),

            // Sección Pago de Servicios
            _buildBlueHeader("Pago de Servicios"),
            _buildHorizontalSection(_scrollController2),

            SizedBox(height: 40),
            _buildSimpleFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlueHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5D9BBD), Color(0xFF8EBFD4)],
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _buildHorizontalSection(ScrollController controller) {
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: ListView.builder(
            controller: controller,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(20),
            itemCount: 6,
            itemBuilder: (context, index) => Container(
              width: 200,
              margin: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Center(child: Icon(Icons.grid_view_rounded, size: 50, color: Colors.black12)),
            ),
          ),
        ),
        // Barra Amarilla de Scroll debajo del carrusel
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFD6EAF8),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: Container(
              width: 150, // Esto debería moverse con el scroll en una app real
              decoration: BoxDecoration(
                color: Color(0xFFF1C40F),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      color: Color(0xFF1A4661),
      child: Text(
        "© 2026 Papelería El Principito. Todos los derechos reservados.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}