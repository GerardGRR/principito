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
import 'utils/printing_dialog.dart';

final ValueNotifier<String?> archivoSeleccionado = ValueNotifier(null);
final ValueNotifier<String> searchQuery = ValueNotifier("");
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  int _selectedIndex = 0;
  bool _isManagementView = false;
  Widget? _managementPage;
  bool _loading = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isManagementView = false;
      // Limpiar búsqueda cuando cambias de pantalla (excepto en Catálogo)
      if (index != 1) {
        searchQuery.value = "";
      }
    });
  }

  void _openManagement(Widget page) {
    setState(() {
      _managementPage = page;
      _isManagementView = true;
      // Limpiar búsqueda cuando abres gestión
      searchQuery.value = "";
    });
    Navigator.pop(context); // Cerrar drawer
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _mainPages = [
      HomePage(onNavigate: _onItemTapped),
      const VentasPage(),
      const ImpresionesPage(),
      const CarritoPage(),
      const MovimientosPage(),
    ];

    bool isMobile = MediaQuery.of(context).size.width < 700;
    return StreamBuilder<AppUser?>(
      stream: _firebaseService.streamCurrentUserData(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isAdmin = user?.role == 'administrador';
        final isEmployee = user?.role == 'empleado' || isAdmin;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A4661),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Builder(
                  builder: (context) => IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.star,
                      color: Color(0xFFF1C40F),
                      size: 30,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "EL PRINCIPITO",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actions: [
              if (!isMobile) ...[
                _buildUploadButton(false),
                const SizedBox(width: 20),
                _buildUserMiniProfile(user),
                const SizedBox(width: 15),
              ] else
                _buildUploadButton(true),
            ],
          ),
          drawer: _buildDrawer(context, user, isEmployee, isAdmin),
          body: Column(
            children: [
              // Barra de búsqueda solo en Catálogo
              if (!_isManagementView && _selectedIndex == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: _buildSearchBar(),
                ),
              Expanded(
                child: _isManagementView
                    ? (_managementPage ?? const HomePage())
                    : _mainPages[_selectedIndex],
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _isManagementView ? 0 : _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF1A4661),
            selectedItemColor: _isManagementView
                ? Colors.white70
                : const Color(0xFFF1C40F),
            unselectedItemColor: Colors.white70,
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view),
                label: "Catálogo",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.print),
                label: "Impresiones",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: "Carrito",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: "Historial",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserMiniProfile(AppUser? user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          user?.name ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          user?.role.toUpperCase() ?? "",
          style: const TextStyle(color: Color(0xFFF1C40F), fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    AppUser? user,
    bool isEmployee,
    bool isAdmin,
  ) {
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
          if (isEmployee) ...[
            ListTile(
              leading: const Icon(Icons.inventory, color: Color(0xFF1A4661)),
              title: const Text("Gestión de Inventario"),
              onTap: () => _openManagement(const ProductosPage()),
            ),
            ListTile(
              leading: const Icon(
                Icons.miscellaneous_services,
                color: Color(0xFF1A4661),
              ),
              title: const Text("Gestión de Servicios"),
              onTap: () => _openManagement(const TramitesPage()),
            ),
          ],
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF1A4661)),
              title: const Text("Gestión de Usuarios"),
              onTap: () => _openManagement(const AdminUsuariosPage()),
            ),
          const Spacer(),
          const Divider(),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: (value) => searchQuery.value = value,
        decoration: const InputDecoration(
          hintText: "Buscar...",
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton.icon(
            onPressed: _loading
                ? null
                : () {
                    final fs = FirebaseService();
                    PrintingUploadHelper.showUploadDialog(context, fs, (
                      msg, {
                      error = false,
                    }) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          backgroundColor: error ? Colors.red : Colors.green,
                        ),
                      );
                    });
                  },
            icon: const Icon(Icons.upload, size: 18),
            label: Text(
              small ? "Subir" : "Subir Impresión",
              style: const TextStyle(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A4661),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              elevation: 0,
            ),
          ),
        );
      },
    );
  }
}
