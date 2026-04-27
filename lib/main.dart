import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'firebase_options.dart';
import 'sesion.dart';
import 'home.dart';
import 'impresiones.dart';
import 'productos.dart';
import 'tramites.dart';
import 'movimientos.dart';
import 'ventas.dart';
import 'carrito.dart';
import 'admin_usuarios.dart';
import 'database/firebase_service.dart';
import 'models/user.dart';

final ValueNotifier<String?> archivoSeleccionado = ValueNotifier(null);
final ValueNotifier<String> searchQuery = ValueNotifier("");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A4661)),
      ),
      home: const Loginscreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return StreamBuilder<AppUser?>(
      stream: _firebaseService.streamCurrentUserData(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isAdmin = user?.role == 'administrador';

        List<Widget> tabs = [
          const Tab(text: "Inicio"),
          const Tab(text: "Catálogo"),
          const Tab(text: "Impresiones"),
          const Tab(text: "Productos"),
          const Tab(text: "Trámites"),
          const Tab(text: "Carrito"),
          const Tab(text: "Movimientos"),
        ];

        List<Widget> pages = [
          const HomePage(),
          const VentasPage(),
          const ImpresionesPage(),
          const ProductosPage(),
          const TramitesPage(),
          const CarritoPage(),
          const MovimientosPage(),
        ];

        if (isAdmin) {
          tabs.add(const Tab(text: "Usuarios"));
          pages.add(const AdminUsuariosPage());
        }

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF1A4661),
              elevation: 0,
              toolbarHeight: isMobile ? 120 : 80,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.star, color: Color(0xFFF1C40F), size: 30),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: isMobile ? _buildMobileHeader(user) : _buildWebHeader(user),
              ),
              bottom: TabBar(
                indicatorColor: const Color(0xFFF1C40F),
                indicatorWeight: 4,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: tabs,
              ),
            ),
            drawer: _buildDrawer(context, user),
            body: TabBarView(children: pages),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, AppUser? user) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A4661)),
            accountName: Text(user?.name ?? "Usuario"),
            accountEmail: Text(user?.email ?? ""),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Color(0xFFF1C40F),
              child: Icon(Icons.person, size: 40, color: Color(0xFF1A4661)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF1A4661)),
            title: const Text("Cerrar Sesión"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Loginscreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(AppUser? user) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("El Principito",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            _buildUploadButton(true),
          ],
        ),
        const SizedBox(height: 12),
        _buildSearchBar(),
      ],
    );
  }

  Widget _buildWebHeader(AppUser? user) {
    return Row(
      children: [
        const Text("El Principito",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(width: 30),
        Expanded(child: _buildSearchBar()),
        const SizedBox(width: 30),
        _buildUploadButton(false),
        const SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(user?.name ?? "", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            Text(user?.role.toUpperCase() ?? "", style: const TextStyle(color: Color(0xFFF1C40F), fontSize: 10)),
          ],
        ),
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
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );

              if (result != null && result.files.single.path != null) {
                archivoSeleccionado.value = result.files.single.path;
                DefaultTabController.of(context)?.animateTo(2);
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
