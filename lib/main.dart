import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase habilitado
import 'package:file_picker/file_picker.dart';    // Selector de archivos habilitado
import 'firebase_options.dart';
import 'sesion.dart';
import 'home.dart';
import 'impresiones.dart';
import 'productos.dart';
import 'tramites.dart';
import 'movimientos.dart';

// --- NOTIFICADORES GLOBALES (Para búsqueda y archivos) ---
final ValueNotifier<String?> archivoSeleccionado = ValueNotifier(null);
final ValueNotifier<String> searchQuery = ValueNotifier("");

void main() async {
  // Asegura la inicialización de Flutter antes de Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ElPrincipitoApp());
}

class ElPrincipitoApp extends StatelessWidget {
  const ElPrincipitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'El Principito',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A4661),
        // Mantener la coherencia visual con tu azul marino
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A4661)),
      ),
      // --- LOGIN MANTENIDO COMO HOME ---
      home: const Loginscreen(),
    );
  }
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A4661),
          elevation: 0,
          toolbarHeight: isMobile ? 120 : 80,
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: isMobile ? _buildMobileHeader() : _buildWebHeader(),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFF1C40F),
            indicatorWeight: 4,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Inicio"),
              Tab(text: "Impresiones"),
              Tab(text: "Productos"),
              Tab(text: "Trámites"),
              Tab(text: "Movimientos"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HomePage(),
            ImpresionesPage(),
            ProductosPage(),
            TramitesPage(),
            MovimientosPage(),
          ],
        ),
      ),
    );
  }

  // --- CABECERAS ---
  Widget _buildMobileHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.star, color: Color(0xFFF1C40F), size: 32),
                SizedBox(width: 8),
                Text("El Principito",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            _buildUploadButton(true),
          ],
        ),
        const SizedBox(height: 12),
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildWebHeader() {
    return Row(
      children: [
        const Icon(Icons.star, color: Color(0xFFF1C40F), size: 32),
        const SizedBox(width: 8),
        const Text("El Principito",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(width: 30),
        Expanded(child: _buildSearchBar()),
        const SizedBox(width: 30),
        _buildUploadButton(false),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: TextField(
        onChanged: (value) => searchQuery.value = value,
        decoration: const InputDecoration(
          hintText: "Buscar...",
          hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
          prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF1A4661)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildUploadButton(bool small) {
    return Builder(
      builder: (context) {
        return SizedBox(
          height: 38,
          child: ElevatedButton.icon(
            onPressed: () async {
              // Lógica de FilePicker fusionada
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );

              if (result != null && result.files.single.path != null) {
                archivoSeleccionado.value = result.files.single.path;
                // Salta automáticamente a la pestaña de Impresiones (índice 1)
                DefaultTabController.of(context)?.animateTo(1);
              }
            },
            icon: const Icon(Icons.upload, size: 20),
            label: Text(
              small ? "Subir" : "Subir Impresión",
              style: const TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A4661),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 0,
            ),
          ),
        );
      },
    );
  }
}