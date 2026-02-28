import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controlador para la barra de scroll amarilla lateral
    final ScrollController _homeController = ScrollController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // ÁREA PRINCIPAL DE CONTENIDO
          Expanded(
            child: RawScrollbar(
              controller: _homeController,
              thumbColor: Color(0xFFF1C40F), // Amarillo El Principito
              thickness: 12,
              radius: Radius.circular(10),
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _homeController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Principal (Hero Section) con degradado azul
                    _buildHeroBanner(),
                    SizedBox(height: 30),

                    // Título de sección: Productos Destacados
                    _buildSectionHeader("Productos Destacados", "Novedades y Ofertas Especiales"),
                    // Carrusel o Grid de productos destacados
                    _buildDestacadosGrid(),
                    // Sección final: ¿Listo para comenzar?
                    _buildCallToAction(),

                    _buildSimpleFooter(),
                  ],
                ),
              ),
            ),
          ),

          // Margen para la scrollbar lateral
          Container(
              width: 5,
              color:  Color(0xFFD6EAF8).withOpacity(0.2)
          ),
        ],
      ),
    );
  }

  // --- Componentes de la pantalla --
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5D9BBD), Color(0xFF8EBFD4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
            "Todo lo que necesitas para\nbrillar este ciclo escolar",
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Encuentra los mejores artículos escolares,\nde oficina y servicios de impresión.",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 30),
          Row(
            children: [
              _heroButton("→ Ver Catálogo", isYellow: true),
              SizedBox(width: 15),
              _heroButton("↑ Subir Impresión", isYellow: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroButton(String label, {required bool isYellow}) {
    return Container(
      // Reducimos horizontal de 25 a 16 y vertical de 12 a 8
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isYellow ? Color(0xFFF1C40F) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isYellow ? null : Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isYellow ? Color(0xFF1A4661) : Colors.white,
          fontWeight: FontWeight.bold,
          // Reducimos la fuente de 16 a 13 o 14 para que se vea proporcional
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A6B91)
            ),
          ),
          Text(
              subtitle,
              style: TextStyle(color: Color(0xFF5D9BBD), fontSize: 16)
          ),
        ],
      ),
    );
  }

  Widget _buildDestacadosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(40),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 25,
        mainAxisSpacing: 25,
        childAspectRatio: 0.8,
      ),
      itemCount: 4, // Solo mostramos los 4 destacados
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black,
                blurRadius: 15,
                offset: Offset(0, 8)
            )
          ],
        ),
        child: Center(
            child: Icon(Icons.star_outline, color: Colors.black12, size: 60)
        ),
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      decoration: BoxDecoration(
        color: Color(0xFFD6EAF8),
      ),
      child: Column(
        children: [
          Icon(Icons.star, color: Color(0xFFF1C40F), size: 50),
          SizedBox(height: 20),
          Text(
            "¿Listo para comenzar?",
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A4661)
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Únete a cientos de estudiantes y profesionales que confían en nosotros\npara sus necesidades escolares y de oficina.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF2A6B91), fontSize: 16),
          ),
          SizedBox(height: 30),
          _heroButton("Solicita tus materiales ahora", isYellow: true),
        ],
      ),
    );
  }

  Widget _buildSimpleFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      color: Color(0xFF1A4661),
      child: Text(
        "© 2026 Papelería El Principito. Todos los derechos reservados.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}