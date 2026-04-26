import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'main.dart'; // para usar archivoSeleccionado

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController _homeController = ScrollController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            child: RawScrollbar(
              controller: _homeController,
              thumbColor: const Color(0xFFF1C40F),
              thickness: 8,
              radius: const Radius.circular(10),
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _homeController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(context),
                    const SizedBox(height: 30),
                    _buildSectionHeader(
                      "Productos Destacados",
                      "Novedades y Ofertas Especiales",
                    ),
                    _buildDestacadosGrid(),
                    _buildCallToAction(),
                    _buildSimpleFooter(),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 5, color: const Color(0xFFD6EAF8).withOpacity(0.2)),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return ClipPath(
      clipper: HeroWaveClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(25, 60, 25, 120), // Padding ajustado
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A72A0), Color(0xFF7CB6D6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Todo lo que necesitas para\nbrillar este ciclo escolar",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Encuentra los mejores artículos escolares,\nde oficina y servicios de impresión",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 30),
            // Envolver en Wrap para evitar desbordes en móviles
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: [
                _heroButton(
                  "Ver Catálogo",
                  isYellow: true,
                  onTap: () {
                    DefaultTabController.of(context).animateTo(2);
                  },
                ),
                _heroButton(
                  "Subir impresión",
                  isYellow: false,
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );
                    if (result != null && result.files.single.path != null) {
                      archivoSeleccionado.value = result.files.single.path;
                      DefaultTabController.of(context).animateTo(1);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroButton(
    String label, {
    required bool isYellow,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A72A0),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF5D9BBD), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDestacadosGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              int columns = constraints.maxWidth < 600 ? 2 : 4;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.8,
                ),
                itemCount: 4,
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.star_outline,
                      color: Colors.black12,
                      size: 50,
                    ),
                  ),
                ),
              );
            },
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Ver más productos",
              style: TextStyle(
                color: Color(0xFF5D9BBD),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8EBFD4), Color(0xFF2A72A0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.star, color: Color(0xFFF1C40F), size: 60),
          const SizedBox(height: 20),
          const Text(
            "¿Listo para comenzar?",
            textAlign: TextAlign.center, // Centrado para evitar cortes
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Únete a cientos de estudiantes y profesionales que confían en nosotros para sus necesidades escolares y de oficina.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 30),
          _heroButton("Solicita tus materiales ahora", isYellow: true),
        ],
      ),
    );
  }

  Widget _buildSimpleFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF1A4661),
      child: const Text(
        "© 2026 Papelería El Principito. Todos los derechos reservados.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}

class HeroWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    var secondControlPoint = Offset(
      size.width - (size.width / 3.25),
      size.height - 80,
    );
    var secondEndPoint = Offset(size.width, size.height - 30);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
