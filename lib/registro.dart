import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _nameError;
  String? _userError;
  String? _emailError;
  String? _passwordError;

  Future<void> registrar() async {
    setState(() {
      _nameError = null;
      _userError = null;
      _emailError = null;
      _passwordError = null;
    });

    bool hasError = false;

    if (nameController.text.isEmpty) {
      setState(() => _nameError = "El nombre es obligatorio");
      hasError = true;
    }
    if (userController.text.isEmpty) {
      setState(() => _userError = "El usuario es obligatorio");
      hasError = true;
    }
    if (emailController.text.isEmpty) {
      setState(() => _emailError = "El correo es obligatorio");
      hasError = true;
    }
    if (passwordController.text.isEmpty) {
      setState(() => _passwordError = "La contraseña es obligatoria");
      hasError = true;
    } else if (passwordController.text.length < 4) {
      setState(() => _passwordError = "Mínimo 4 caracteres");
      hasError = true;
    }

    if (hasError) return;

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = cred.user!.uid;

      await _firestore.collection('usuarios').doc(uid).set({
        'uid': uid,
        'email': emailController.text.trim(),
        'username': userController.text.trim(),
        'name': "${nameController.text.trim()} ${lastNameController.text.trim()}",
        'role': 'Usuario', // Cambiado de vendedor a empleado según requerimiento previo
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado correctamente')),
        );
        Navigator.pop(context);
      }

    } on FirebaseAuthException catch(e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _emailError = "El correo ya está en uso";
        } else if (e.code == 'invalid-email') {
          _emailError = "Formato de correo inválido";
        } else if (e.code == "weak-password") {
          _passwordError = "La contraseña es muy débil";
        } else {
          _emailError = "Error: ${e.message}";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Cuenta"),
        backgroundColor: const Color(0xFF1A4661),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 80, color: Color(0xFF1A4661)),
            const SizedBox(height: 30),
            _buildTextField("Nombre", nameController, errorText: _nameError),
            const SizedBox(height: 15),
            _buildTextField("Apellidos", lastNameController),
            const SizedBox(height: 15),
            _buildTextField("Usuario", userController, errorText: _userError),
            const SizedBox(height: 15),
            _buildTextField("Correo Electrónico", emailController, keyboardType: TextInputType.emailAddress, errorText: _emailError),
            const SizedBox(height: 15),
            _buildTextField("Contraseña", passwordController, isPassword: true, errorText: _passwordError),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: registrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4D03F),
                  foregroundColor: const Color(0xFF1A4661),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("REGISTRARSE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false, TextInputType keyboardType = TextInputType.text, String? errorText}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorText != null ? Colors.red : Colors.grey.shade400),
        ),
      ),
    );
  }
}
