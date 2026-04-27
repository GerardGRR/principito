import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'registro.dart';
import 'database/firebase_service.dart';
import 'models/user.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _userError;
  String? _passwordError;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        userController.text = prefs.getString('remembered_user') ?? "";
        passwordController.text = prefs.getString('remembered_password') ?? "";
      }
    });
  }

  Future<void> _saveRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('remembered_user', userController.text.trim());
      await prefs.setString('remembered_password', passwordController.text.trim());
    } else {
      await prefs.remove('remembered_user');
      await prefs.remove('remembered_password');
    }
  }

  Future<void> login() async {
    setState(() {
      _userError = null;
      _passwordError = null;
    });

    String input = userController.text.trim();
    String password = passwordController.text.trim();

    bool hasError = false;
    if (input.isEmpty) {
      setState(() => _userError = "El usuario o correo es obligatorio");
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = "La contraseña es obligatoria");
      hasError = true;
    } else if (password.length < 4) {
      setState(() => _passwordError = "Mínimo 4 caracteres");
      hasError = true;
    }

    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      String email = input;
      if (!input.contains('@')) {
        AppUser? user = await _firebaseService.getUserByUsername(input);
        if (user != null) {
          email = user.email;
        } else {
          setState(() => _userError = "Usuario no encontrado");
          setState(() => _isLoading = false);
          return;
        }
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _saveRememberedUser();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _userError = "Credenciales incorrectas";
          _passwordError = "Credenciales incorrectas";
        } else if (e.code == 'invalid-email') {
          _userError = "Formato de correo inválido";
        } else {
          _userError = "Error al iniciar sesión: ${e.message}";
        }
      });
    } catch (e) {
      setState(() => _userError = "Ocurrió un error inesperado");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  Widget buildWebLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Accede con tu usuario",
                    style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                const Text("Ingresa tu usuario o correo y contraseña",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                const SizedBox(height: 40),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: buildTextField("Usuario o Correo", controller: userController, errorText: _userError)),
                    const SizedBox(width: 15),
                    Expanded(child: buildTextField("Contraseña", isPassword: true, controller: passwordController, errorText: _passwordError)),
                    const SizedBox(width: 15),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : buildSubmitButton(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildRememberMeCheckbox(Colors.white),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroScreen())),
                    child: const Text("¿No tienes cuenta? Regístrate aquí",
                        style: TextStyle(color: Color(0xFF2A72A0), fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Center(child: Image.asset('assets/image 1.png', fit: BoxFit.contain, width: 400)),
        ),
      ],
    );
  }

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
          const SizedBox(height: 30),
          buildTextField("Usuario o Correo", controller: userController, errorText: _userError),
          const SizedBox(height: 15),
          buildTextField("Contraseña", isPassword: true, controller: passwordController, errorText: _passwordError),
          const SizedBox(height: 10),
          _buildRememberMeCheckbox(Colors.white),
          const SizedBox(height: 15),
          SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
            onPressed: _isLoading ? null : login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF4D03F), 
              foregroundColor: const Color(0xFF1A4661),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            child: _isLoading ? const CircularProgressIndicator() : const Text("INICIAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
          )),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroScreen())),
            child: const Text("¿No tienes cuenta? Regístrate", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberMeCheckbox(Color textColor) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (val) => setState(() => _rememberMe = val ?? false),
            activeColor: const Color(0xFFF4D03F),
            checkColor: const Color(0xFF1A4661),
            side: BorderSide(color: textColor, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text("Recordar sesión", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget buildTextField(String texto, {bool isPassword = false, TextEditingController? controller, String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            labelText: texto,
            filled: true,
            fillColor: Colors.white,
            errorText: errorText,
            errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF4D03F), borderRadius: BorderRadius.circular(8)),
      child: IconButton(onPressed: login, icon: const Icon(Icons.arrow_forward, color: Color(0xFF1A4661))),
    );
  }

  Widget buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: const Row(
        children: [
          Icon(Icons.star, color: Color(0xFFF4D03F)),
          SizedBox(width: 10),
          Text("El Principito", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A4661))),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintInferior = Paint()
      ..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2A72A0), Color(0xFF98CAE9)])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final paintSuperior = Paint()
      ..shader = const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF98CAE9), Color(0xFF2A72A0)])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
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
