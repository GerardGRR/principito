import 'package:flutter/material.dart';
import 'main.dart'; // Ajusta la ruta según tu estructura

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Detectamos si la pantalla es móvil o web/tablet
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    return Scaffold(
      backgroundColor: Colors.white,
      // SingleChildScrollView evita el error de "Bottom Overflow" al abrir el teclado
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              // 1. Barra superior azul marino
              Container(
                height: 50,
                color: Color(0xFF1A4661),
              ),

              // 2. Encabezado con Logo y Nombre
              _buildLogoHeader(),

              // 3. Cuerpo principal responsivo
              Expanded(
                child: Stack(
                  children: [
                    // Fondo con forma de onda azul
                    ClipPath(
                      clipper: LoginWaveClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2A6B91), Color(0xFF5D9BBD)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),

                    // Contenido Adaptable
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 25.0 : 40.0),
                      child: isMobile
                          ? _buildMobileLayout(context)
                          : _buildWebLayout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DISEÑO PARA CELULAR (Vertical) ---
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Accede con tu usuario",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30, // Reducido para móvil
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Accede con tus credenciales para usar la app",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        SizedBox(height: 40),

        // Inputs apilados en lugar de fila
        _buildInput("Usuario"),
        SizedBox(height: 15),
        _buildInput("Contraseña", isPass: true),
        SizedBox(height: 25),

        // Botón de acceso ancho completo en móvil
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => _navigateToMain(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF1C40F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Icon(Icons.arrow_forward, color: Color(0xFF1A4661), size: 30),
          ),
        ),

        SizedBox(height: 30),
        Text(
          "Olvidé mi contraseña",
          style: TextStyle(color: Color(0xFF1A4661), fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        // Ilustración reducida para que no tape el texto
        Opacity(
          opacity: 0.3,
          child: Icon(Icons.brush, size: 120, color: Colors.white),
        ),
      ],
    );
  }

  // --- DISEÑO PARA WEB/TABLET (Horizontal) ---
  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Accede con tu usuario",
                style: TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold),
              ),
              Text(
                "Accede con tus credenciales para poder usar la app",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(child: _buildInput("Usuario")),
                  SizedBox(width: 10),
                  Expanded(child: _buildInput("Contraseña", isPass: true)),
                  SizedBox(width: 15),
                  _buildLoginCircleButton(context),
                ],
              ),
              SizedBox(height: 40),
              Text(
                "Olvidé mi contraseña",
                style: TextStyle(color: Color(0xFF1A4661), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Icon(Icons.brush, size: 250, color: Colors.white),
          ),
        ),
      ],
    );
  }
  Widget _buildLogoHeader() {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Color(0xFF1A4661),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(Icons.star, color: Color(0xFFF1C40F), size: 25),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "El Principito",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A4661)),
              ),
              Text("Papelería & Impresiones", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String hint, {bool isPass = false}) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: TextField(
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Color(0xFF2A6B91)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildLoginCircleButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToMain(context),
      child: Container(
        height: 55, width: 55,
        decoration: BoxDecoration(
          color: Color(0xFFF1C40F),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Icon(Icons.arrow_forward, color: Color(0xFF1A4661), size: 30),
      ),
    );
  }

  void _navigateToMain(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainNavigation()),
    );
  }
}

// Mantener tu clase LoginWaveClipper igual...
class LoginWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.15);
    var firstControlPoint = Offset(size.width * 0.3, size.height * 0.45);
    var firstEndPoint = Offset(size.width * 0.6, size.height * 0.7);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 0.85, size.height * 0.95);
    var secondEndPoint = Offset(size.width, size.height * 0.75);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}