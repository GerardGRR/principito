import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registrar() async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = cred.user!.uid;

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'email': emailController.text.trim(),
        'rol': 'cliente',
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario registrado correctamente'))
      );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigation()),
      );

    } on FirebaseAuthException catch(e) {
      String mensaje = "Error al registrar";

      if (e.code == 'email-already-in-use') {
        mensaje = "El correo ya esta en uso";
      } else if (e.code == "weak-password") {
        mensaje = "La contraseña es muy debil";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje))
      );

    }
  }

  Future<void> login() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = "Error al iniciar sesión";

      if (e.code == 'user-not-found') {
        mensaje = "Usuario no encontrado";
      } else if (e.code == 'wrong-password') {
        mensaje = "Contraseña incorrecta";
      } else if (e.code == 'invalid-email') {
        mensaje = "Correo inválido";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          buildHeader(),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: WavePainter())),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return buildWebLayout(context);
                    } else {
                      return buildMobileLayout(context);
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
  // ---------------- WEB ----------------
  Widget buildWebLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.only(left: 60.0, right: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Accede con tu usuario",
                    style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                const Text("Accede con tus credenciales para poder usar la app",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(child: buildTextField("Correo", controller: emailController)),
                    const SizedBox(width: 15),
                    Expanded(child: buildTextField("Contraseña",
                        isPassword: true, controller: passwordController)),
                    const SizedBox(width: 15),
                    buildSubmitButton(context),
                  ],
                ),

                SizedBox(height: 20,),

                Center(
                  child: TextButton(
                      onPressed: registrar,
                      child: Text("Registrate",
                        style: TextStyle(color: Color(0xFF2A72A0), fontWeight: FontWeight.bold, fontSize: 16),),
                  ),
                ),

                SizedBox(height: 15),

                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text("Olvide mi contraseña",
                        style: TextStyle(color: Color(0xFF2A72A0), fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Center(
            child: Image.asset('assets/image 1.png',
                fit: BoxFit.contain, width: 400),
          ),
        ),
      ],
    );
  }

  // ---------------- MOBILE ----------------
  Widget buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Column(
        children: [
          Image.asset('assets/image 1.png', height: 200),
          const SizedBox(height: 30),

          const Text("Accede con tu usuario",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),

          const SizedBox(height: 10),

          const Text("Accede con tus credenciales para poder usar la app",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white)),

          const SizedBox(height: 30),

          buildTextField("Correo", controller: emailController),
          const SizedBox(height: 15),
          buildTextField("Contraseña",
              isPassword: true, controller: passwordController),

          SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: buildSubmitButton(context),
          ),

          SizedBox(height: 10,),

          ElevatedButton(
              onPressed: registrar,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Color(0xFF1A4661)),
              child: Text("Registrate"),
          ),

          SizedBox(height: 30),

          TextButton(
            onPressed: () {},
            child: Text("Olvide mi contraseña",
                style: TextStyle(color: Color(0xFF2A72A0), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ---------------- INPUT ----------------
  Widget buildTextField(String texto,
      {bool isPassword = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: texto,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ---------------- BOTÓN ----------------
  Widget buildSubmitButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF4D03F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: login,
        icon: Icon(Icons.arrow_forward, color: Colors.black87),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget buildHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.star, color: Color(0xFFF4D03F)),
          SizedBox(width: 10),
          Text("El Principito",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

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

    final pathInferior = Path();
    pathInferior.lineTo(0, size.height * 0.9);
    pathInferior.quadraticBezierTo(size.width * 0.25, size.height * 1.05, size.width * 0.5, size.height * 0.85);
    pathInferior.quadraticBezierTo(size.width * 0.75, size.height * 0.65, size.width, size.height * 0.9);
    pathInferior.lineTo(size.width, 0);
    pathInferior.close();
    canvas.drawPath(pathInferior, paintInferior);

    final pathSuperior = Path();
    pathSuperior.lineTo(0, size.height * 0.85);
    pathSuperior.quadraticBezierTo(size.width * 0.22, size.height * 0.95, size.width * 0.45, size.height * 0.75);
    pathSuperior.quadraticBezierTo(size.width * 0.65, size.height * 0.55, size.width * 0.75, 0);
    pathSuperior.lineTo(0, 0);
    pathSuperior.close();

    canvas.drawPath(pathSuperior, paintSuperior);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}