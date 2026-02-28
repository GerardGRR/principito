import 'package:flutter/material.dart';
import '../main.dart'; // Importante para navegar a MainNavigation

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Barra superior azul marino
          Container(
            height: 50,
            color: Color(0xFF1A4661),
          ),

          // 2. Encabezado con Logo y Nombre
          Padding(
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
                  children:[
                    Text(
                      "El Principito",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A4661),
                      ),
                    ),
                    Text(
                      "Papelería & Impresiones",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Cuerpo principal con Ondas e Ilustración
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

                // Contenido del Formulario e Ilustración
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    children: [
                      // Lado Izquierdo: Textos e Inputs
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Accede con tu usuario",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Accede con tus credenciales para poder usar la app",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            SizedBox(height: 30),

                            // Fila de inputs y botón amarillo
                            Row(
                              children: [
                                Expanded(child: _buildInput("Usuario")),
                                SizedBox(width: 10),
                                Expanded(child: _buildInput("Contraseña", isPass: true)),
                                SizedBox(width: 15),

                                // BOTÓN AMARILLO (Navegación)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => MainNavigation()),
                                    );
                                  },
                                  child: Container(
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                      color:  Color(0xFFF1C40F),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                                    ),
                                    child: Icon(Icons.arrow_forward, color: Color(0xFF1A4661), size: 30),
                                  ),
                                ),
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

                      // Lado Derecho: Espacio para la ilustración del Principito
                      Expanded(
                        flex: 1,
                        child: Center(
                          // Aquí puedes poner tu Image.asset('assets/principito.png')
                          child: Icon(Icons.brush, size: 250, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para los campos de texto blancos
  Widget _buildInput(String hint, {bool isPass = false}) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
}

// Clase para dibujar la curva del fondo
class LoginWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.15); // Punto de inicio izquierdo

    var firstControlPoint = Offset(size.width * 0.3, size.height * 0.45);
    var firstEndPoint = Offset(size.width * 0.6, size.height * 0.7);

    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy
    );

    var secondControlPoint = Offset(size.width * 0.85, size.height * 0.95);
    var secondEndPoint = Offset(size.width, size.height * 0.75);

    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}