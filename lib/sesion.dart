import 'package:flutter/material.dart';
import 'main.dart';

class Loginscreen extends StatelessWidget {
  const Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          buildHeader(),

          //Cuerpo de pantalla (Fondo y contenido)
          Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(
                    painter: WavePainter(),
                  ),),

                  //Contenido responsivo
                  LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 800) {
                          return buildWebLayout(context);
                        } else {
                          return buildMobileLayout(context);
                        }
                      }
                  )
                ],
              )
          )
        ],
      ),
    );
  }

  //Diseño de de we
  Widget buildWebLayout(BuildContext context) {
    return Row(
      //Mitad izquierda
      children: [
        Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.only(left: 60.0, right: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Accede con tu usuario", style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),),
                  SizedBox(height: 10,),
                  Text("Accede con tus credenciales para poder usar la app", style: TextStyle(fontSize: 18, color: Colors.white),),
                  SizedBox(height: 40,),

                  Row(
                    children: [
                      Expanded(child: buildTextField("Usuario")),
                      SizedBox(width: 15,),
                      Expanded(child: buildTextField("Contraseña", isPassword: true)),
                      SizedBox(width: 15,),
                      buildSubmitButtom(context),
                    ],
                  ),
                  SizedBox(height: 60,),

                  //Link de recuperación
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text("Olvide mi contraseña", style: TextStyle(color: Color(0xFF2A72A0), fontWeight: FontWeight.bold, fontSize: 16),),
                    ),
                  ),
                ],
              ),
            )
        ),
        Expanded(
          flex: 4,
          child: Center(
            child: Image.asset('assets/image 1.png', fit: BoxFit.contain, width: 400,),
          ),
        ),
      ],
    );
  }

  //Diseño ṕara celulares
  Widget buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/image 1.png', height: 200, fit: BoxFit.contain,),
          SizedBox(height: 30,),
          Text("Accede con tu usuario", textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),),
          SizedBox(height: 10,),
          Text("Accede con tus credenciales para poder usar la app", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white),),
          SizedBox(height: 30,),

          buildTextField("Usuario"),
          SizedBox(height: 15,),
          buildTextField("Contraseña", isPassword: true),
          SizedBox(height: 20,),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: buildSubmitButtom(context),
          ),

          SizedBox(height: 30,),
          TextButton(
            onPressed: () {},
            child: Text("Olvide mi contraseña", style: TextStyle(color: Color(0xFF2A72A0), fontWeight: FontWeight.bold, fontSize: 16),),
          ),
        ],
      ),
    );
  }

  //Widgets
  Widget buildHeader() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(height: 10, color: Color(0xFF2A72A0)),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              children: [
                Container(width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A72A0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.star, color: Color(0xFFF4D03F)),
                ),
                SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("El principito", style: TextStyle(color: Color(0xFF2A72A0), fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("Papelería & Impresiones", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildTextField(String texto, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: texto,
        labelStyle: TextStyle(color: Color(0xFF2A72A0), fontWeight: FontWeight.bold),
        floatingLabelStyle: TextStyle(color: Color(0xFF1A4661), fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }

  Widget buildSubmitButtom(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF4D03F), //Amarillo
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainNavigation()));
        },
        icon: Icon(Icons.arrow_forward, color: Colors.black87),
      ),
    );
  }
}

// Mantener tu clase LoginWaveClipper igual...
class LoginWaveClipper extends CustomClipper<Path> {
  @override
  void paint(Canvas canvas, Size size) {  //degradados (LinearGradient)

    //Ola inferior
    final Rect rectInferior = Rect.fromLTWH(0, 0, size.width, size.height);
    final Gradient gradientInferior = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2A72A0).withOpacity(0.8),
        Color(0xFF98CAE9).withOpacity(0.8),
      ],
    );

    final paintInferior = Paint()
      ..shader = gradientInferior.createShader(rectInferior)
      ..style = PaintingStyle.fill;

    //Ola superior
    final Rect rectSuperior = Rect.fromLTWH(0, 0, size.width, size.height);
    final Gradient gradientSuperior = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xFF98CAE9),
        Color(0xFF2A72A0),
      ],
    );

    final paintSuperior = Paint()
      ..shader = gradientSuperior.createShader(rectSuperior)
      ..style = PaintingStyle.fill;

    //Dibujo de ola inferior
    final pathInferior = Path();
    pathInferior.lineTo(0, size.height * 0.9);
    pathInferior.quadraticBezierTo(size.width * 0.25, size.height * 1.05, size.width * 0.5, size.height * 0.85);
    pathInferior.quadraticBezierTo(size.width * 0.75, size.height * 0.65, size.width, size.height * 0.9);
    pathInferior.lineTo(size.width, 0);
    pathInferior.close();
    canvas.drawPath(pathInferior, paintInferior);

    //Dibujo de ola superior
    final pathSuperior = Path();
    pathSuperior.lineTo(0, size.height * 0.85);
    pathSuperior.quadraticBezierTo(size.width * 0.22, size.height * 0.95, size.width * 0.45, size.height * 0.75);
    pathSuperior.quadraticBezierTo(size.width * 0.65, size.height * 0.55, size.width * 0.75, 0); // Termina antes para dejar espacio blanco
    pathSuperior.lineTo(0, 0);
    pathSuperior.close();

    canvas.drawPath(pathSuperior, paintSuperior);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}
