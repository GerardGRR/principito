import 'package:flutter/material.dart';
import 'database/firebase_service.dart';
import 'models/user.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  final FirebaseService _firebaseService = FirebaseService();
  String _filterRole = "Todos";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Usuarios"),
        backgroundColor: const Color(0xFF1A4661),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<List<AppUser>>(
              stream: _firebaseService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final users = (snapshot.data ?? []).where((u) {
                  if (_filterRole == "Todos") return true;
                  return u.role == _filterRole.toLowerCase();
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) => _buildUserCard(users[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          const Text("Filtrar por rol:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          DropdownButton<String>(
            value: _filterRole,
            items: ["Todos", "Administrador", "Empleado", "Usuario"].map((role) {
              return DropdownMenuItem(value: role, child: Text(role));
            }).toList(),
            onChanged: (val) => setState(() => _filterRole = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${user.username} | ${user.role.toUpperCase()}"),
        trailing: PopupMenuButton<String>(
          onSelected: (newRole) => _updateRole(user, newRole),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'administrador', child: Text("Hacer Administrador")),
            const PopupMenuItem(value: 'empleado', child: Text("Hacer Empleado")),
            const PopupMenuItem(value: 'usuario', child: Text("Hacer Usuario")),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'administrador': return Colors.red;
      case 'empleado': return Colors.orange;
      default: return Colors.blue;
    }
  }

  Future<void> _updateRole(AppUser user, String newRole) async {
    try {
      await _firebaseService.updateUserRole(user.uid, newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rol actualizado correctamente")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    }
  }
}
