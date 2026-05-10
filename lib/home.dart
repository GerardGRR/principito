import 'package:flutter/material.dart';
import 'main.dart'; // para usar archivoSeleccionado
import 'database/firebase_service.dart';
import 'models/user.dart';
import 'utils/printing_dialog.dart';
import 'utils/home_novedades_carousel.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onNavigate;
  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _fs = FirebaseService();
  bool _loading = false;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _fs.getCurrentUserData().then(
      (u) => mounted ? setState(() => _user = u) : null,
    );
  }

  void _showMsg(String msg, {bool error = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: error ? Colors.red : Colors.green,
        ),
      );
    }
  }

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
                      "Novedades",
                      "Los 10 productos más nuevos del catálogo",
                    ),
                    const NovedadesCarousel(),
                    const SizedBox(height: 20),

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
                    widget.onNavigate?.call(1);
                  },
                ),
                _heroButton(
                  "Subir impresión",
                  isYellow: false,
                  onTap: _loading
                      ? null
                      : () => PrintingUploadHelper.showUploadDialog(
                          context,
                          _fs,
                          _showMsg,
                        ),
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
    return Opacity(
      opacity: onTap == null ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: isYellow ? const Color(0xFFF1C40F) : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            border: isYellow
                ? null
                : Border.all(color: Colors.white, width: 1.5),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isYellow ? const Color(0xFF1A4661) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
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
