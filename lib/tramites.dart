import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database/database_helper.dart';
import 'models/service.dart';

class TramitesPage extends StatefulWidget {
  const TramitesPage({super.key});

  @override
  State<TramitesPage> createState() => _TramitesPageState();
}

class _TramitesPageState extends State<TramitesPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();
  List<Service> _services = [];
  bool _isEditingMode = false;
  bool _isDeletingMode = false;
  final Set<int> _selectedForDelete = {};

  final Color _azulMarino = const Color(0xFF1A4661);
  final Color _azulClaro = const Color(0xFF5D9BBD);

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final services = await _dbHelper.getServices();
    setState(() {
      _services = services;
    });
  }

  void _toggleEditingMode() {
    setState(() {
      _isEditingMode = !_isEditingMode;
      _isDeletingMode = false;
      _selectedForDelete.clear();
    });
    _showSnackBar(_isEditingMode ? "Modo edición activado" : "Modo edición desactivado");
  }

  void _toggleDeletingMode() {
    setState(() {
      _isDeletingMode = !_isDeletingMode;
      _isEditingMode = false;
      _selectedForDelete.clear();
    });
    _showSnackBar(_isDeletingMode ? "Selecciona servicios para eliminar" : "Modo eliminación desactivado");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20), // Eleva la snackbar
      ),
    );
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      _showSnackBar("No se pudo abrir el enlace");
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    String? errorText,
  }) {
    bool hasError = errorText != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(color: hasError ? Colors.red : _azulMarino, fontWeight: FontWeight.bold, fontSize: 14)),
              if (isRequired) const Text(" *", style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: hasError ? Colors.red : _azulClaro, width: 1.5),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(color: _azulMarino),
              decoration: InputDecoration(
                prefixText: prefixText,
                prefixStyle: TextStyle(color: _azulMarino, fontWeight: FontWeight.bold),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  void _showServiceForm({Service? service}) {
    final isEditing = service != null;
    final nameController = TextEditingController(text: service?.name ?? '');
    final priceController = TextEditingController(text: service?.price.toString() ?? '');
    final linkController = TextEditingController(text: service?.link ?? '');
    final descController = TextEditingController(text: service?.description ?? '');
    String? selectedImagePath = service?.imagePath;
    Map<String, String?> errors = {};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEditing ? "Editar Servicio" : "Nuevo Servicio",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _azulMarino)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                              if (image != null) setDialogState(() => selectedImagePath = image.path);
                            },
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: _azulClaro, width: 2),
                              ),
                              child: selectedImagePath != null
                                  ? ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.file(File(selectedImagePath!), fit: BoxFit.cover))
                                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.room_service, color: _azulClaro, size: 40), Text("Imagen", style: TextStyle(color: _azulClaro, fontSize: 12))]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildField(label: "Nombre del Trámite/Servicio", controller: nameController, isRequired: true, errorText: errors['name']),
                        _buildField(label: "Precio", controller: priceController, prefixText: "\$ ", keyboardType: TextInputType.number, isRequired: true, errorText: errors['price']),
                        _buildField(label: "Link del sitio oficial (URL)", controller: linkController),
                        _buildField(label: "Descripción", controller: descController),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      setDialogState(() => errors.clear());
                      bool hasErrors = false;
                      if (nameController.text.isEmpty) { errors['name'] = "Campo obligatorio"; hasErrors = true; }
                      if (priceController.text.isEmpty) { errors['price'] = "Campo obligatorio"; hasErrors = true; }
                      if (hasErrors) { setDialogState(() {}); return; }

                      final newService = Service(
                        serviceId: service?.serviceId,
                        name: nameController.text,
                        description: descController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        link: linkController.text,
                        imagePath: selectedImagePath,
                      );

                      if (isEditing) await _dbHelper.updateService(newService);
                      else await _dbHelper.insertService(newService);
                      
                      Navigator.pop(context);
                      _loadServices();
                      _showSnackBar(isEditing ? "Servicio actualizado" : "Servicio creado");
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: _azulMarino, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    child: const Text("GUARDAR SERVICIO", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildServicesGrid(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          if (_isDeletingMode && _selectedForDelete.isNotEmpty)
            Positioned(bottom: 20, left: 20, right: 20,
              child: ElevatedButton.icon(
                onPressed: () {
                   showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirmar"),
                      content: Text("¿Eliminar ${_selectedForDelete.length} servicios?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
                        TextButton(onPressed: () async {
                          for (var id in _selectedForDelete) await _dbHelper.softDeleteService(id);
                          Navigator.pop(context);
                          _toggleDeletingMode();
                          _loadServices();
                        }, child: const Text("Sí", style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                }, 
                icon: const Icon(Icons.delete_forever), 
                label: Text("Eliminar Seleccionados (${_selectedForDelete.length})"), 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
            ),
        ],
      ),
      floatingActionButton: _buildFabMenu(),
    );
  }

  Widget _buildFabMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isEditingMode || _isDeletingMode)
          FloatingActionButton.small(onPressed: () => setState(() { _isEditingMode = false; _isDeletingMode = false; }), backgroundColor: Colors.grey, child: const Icon(Icons.close, color: Colors.white)),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () {},
          backgroundColor: _azulMarino,
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.design_services, color: Colors.white),
            onSelected: (value) {
              if (value == 'add') _showServiceForm();
              if (value == 'edit') _toggleEditingMode();
              if (value == 'delete') _toggleDeletingMode();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'add', child: ListTile(leading: Icon(Icons.add), title: Text("Agregar"))),
              const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text("Editar"))),
              const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text("Borrar"))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Trámites y Servicios", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _azulMarino)),
          Text(_isEditingMode ? "Selecciona un servicio para editar" : _isDeletingMode ? "Selecciona servicios para eliminar" : "Gestión de trámites digitales", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.9),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        bool isSelected = _selectedForDelete.contains(service.serviceId);

        return GestureDetector(
          onTap: () {
            if (_isEditingMode) _showServiceForm(service: service);
            else if (_isDeletingMode) setState(() { if (isSelected) _selectedForDelete.remove(service.serviceId); else _selectedForDelete.add(service.serviceId!); });
            else _launchURL(service.link);
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _isEditingMode ? Colors.blue : (isSelected ? Colors.red : Colors.grey.shade200), width: (_isEditingMode || isSelected) ? 2 : 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                ),
                child: Column(
                  children: [
                    Expanded(child: service.imagePath != null ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.file(File(service.imagePath!), width: double.infinity, fit: BoxFit.cover)) : Icon(Icons.description_outlined, size: 40, color: Colors.grey.shade300)),
                    Padding(padding: const EdgeInsets.all(8.0), child: Column(children: [
                      Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text("\$${service.price}", style: TextStyle(color: _azulMarino, fontSize: 12, fontWeight: FontWeight.bold)),
                      if (service.link != null && service.link!.isNotEmpty)
                        const Icon(Icons.link, size: 14, color: Colors.blue),
                    ])),
                  ],
                ),
              ),
              if (_isEditingMode) const Positioned(top: 5, right: 5, child: CircleAvatar(radius: 12, backgroundColor: Colors.blue, child: Icon(Icons.edit, size: 12, color: Colors.white))),
              if (_isDeletingMode) Positioned(top: 5, right: 5, child: CircleAvatar(radius: 12, backgroundColor: isSelected ? Colors.red : Colors.grey, child: Icon(isSelected ? Icons.check : Icons.delete, size: 12, color: Colors.white))),
            ],
          ),
        );
      },
    );
  }
}
