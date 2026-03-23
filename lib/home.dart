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
              thumbColor: Color(0xFFF1C40F),
              // Amarillo El Principito
              thickness: 8,
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
                    _buildSectionHeader("Productos Destacados",
                        "Novedades y Ofertas Especiales"),
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
              color: Color(0xFFD6EAF8).withOpacity(0.2)
          ),
        ],
      ),
    );
  }

  // --- Componentes de la pantalla --
  Widget _buildHeroBanner() {
    return ClipPath(
      clipper: HeroWaveClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 40, right: 40, top: 60, bottom: 120),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF2A72A0), Color(0xFF7CB6D6)],
              //Ajustes para que quede con el figma
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Todo lo que necesitas para\nbrillar este ciclo escolar",
              style: TextStyle(color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  height: 1.1),),
            SizedBox(height: 20,),
            Text(
              "Encuentra los mejores articulos escolares,\nde oficina y servicios de impresión",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 30,),
            Row(
              children: [
                _heroButton("Ver Catálogo", isYellow: true),
                SizedBox(width: 15,),
                _heroButton("Subir impresión", isYellow: false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroButton(String label, {required bool isYellow}) {
    return Container(
      // Reducimos horizontal de 25 a 16 y vertical de 12 a 8
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isYellow ? Color(0xFFF1C40F) : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: isYellow ? null : Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isYellow ? Color(0xFF1A4661) : Colors.white,
          fontWeight: FontWeight.bold,
          // Reducimos la fuente de 16 a 13 o 14 para que se vea proporcional
          fontSize: 14,
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
                color: Color(0xFF2A72A0)
            ),
          ),
          Text(
              subtitle,
              style: TextStyle(color: Color(0xFF5D9BBD), fontSize: 14)
          ),
        ],
      ),
    );
  }

  Widget _buildDestacadosGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(40),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 25,
              mainAxisSpacing: 25,
              childAspectRatio: 0.75,
            ),
            itemCount: 4,
            // Solo mostramos los 4 destacados
            itemBuilder: (context, index) =>
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4)
                      )
                    ],
                  ),
                  child: Center(
                      child: Icon(
                          Icons.star_outline, color: Colors.black12, size: 60)
                  ),
                ),
          ),
          SizedBox(height: 15,),
          TextButton(
            onPressed: () {},
            child: Text("Ver más prductos", style: TextStyle(
                color: Color(0xFF5D9BBD), fontWeight: FontWeight.bold),),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF8EBFD4), Color(0xFF2A72A0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.star, color: Color(0xFFF1C40F), size: 60),
          SizedBox(height: 20),
          Text(
            "¿Listo para comenzar?",
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Únete a cientos de estudiantes y profesionales que confían en nosotros\npara sus necesidades escolares y de oficina.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
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
      padding: EdgeInsets.all(20),
      color: Color(0xFF1A4661),
      child: Text(
        "© 2026 Papelería El Principito. Todos los derechos reservados.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}

  //La clase para hacer las olas
  class HeroWaveClipper extends CustomClipper<Path> {
    @override
    Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);

    // Primera curva (baja)
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    // Segunda curva (Sube)
    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    // Terminamos de cerrar el trazo
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}