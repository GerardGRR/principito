import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database/firebase_service.dart';
import 'models/service.dart';

class TramitesPage extends StatefulWidget {
  const TramitesPage({super.key});
  @override
  State<TramitesPage> createState() => _TramitesPageState();
}

class _TramitesPageState extends State<TramitesPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  List<Service> _services = [];
  bool _isEditingMode = false;
  bool _isDeletingMode = false;
  final Set<String> _selectedForDelete = {};
  final Color _azulMarino = const Color(0xFF1A4661);
  final Color _azulClaro = const Color(0xFF5D9BBD);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 2 : 4;
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Service>>(
        stream: _firebaseService.getServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          _services = snapshot.data ?? [];

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildServicesGrid(crossAxisCount),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              if (_isDeletingMode && _selectedForDelete.isNotEmpty)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    onPressed: _confirmDeletion,
                    icon: const Icon(Icons.delete_forever),
                    label: Text(
                      "Eliminar Seleccionados (${_selectedForDelete.length})",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFabMenu(),
    );
  }

  void _toggleEditingMode() {
    setState(() {
      _isEditingMode = !_isEditingMode;
      _isDeletingMode = false;
      _selectedForDelete.clear();
    });
    _showSnackBar(
      _isEditingMode ? "Modo edición activado" : "Modo edición desactivado",
    );
  }

  void _toggleDeletingMode() {
    setState(() {
      _isDeletingMode = !_isDeletingMode;
      _isEditingMode = false;
      _selectedForDelete.clear();
    });
    _showSnackBar(
      _isDeletingMode
          ? "Selecciona servicios para eliminar"
          : "Modo eliminación desactivado",
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
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

  Widget _buildImagePreview(String imagePath) {
    // Si es una ruta local válida, mostrar como archivo
    if (File(imagePath).existsSync()) {
      return Image.file(File(imagePath), fit: BoxFit.cover);
    }
    // Si no existe como archivo, asumir que es base64
    try {
      final bytes = base64Decode(imagePath);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (e) {
      return const Icon(Icons.image_not_supported, color: Colors.grey);
    }
  }

  Widget _buildGridImagePreview(String imagePath) {
    // Si es una ruta local válida, mostrar como archivo
    if (File(imagePath).existsSync()) {
      return Image.file(File(imagePath), fit: BoxFit.cover);
    }
    // Si no existe como archivo, asumir que es base64
    try {
      final bytes = base64Decode(imagePath);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (e) {
      return Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey.shade500,
      );
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
              Text(
                label,
                style: TextStyle(
                  color: hasError ? Colors.red : _azulMarino,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (isRequired)
                const Text(" *", style: TextStyle(color: Colors.red)),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasError ? Colors.red : _azulClaro,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(color: _azulMarino),
              decoration: InputDecoration(
                prefixText: prefixText,
                prefixStyle: TextStyle(
                  color: _azulMarino,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                errorText,
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  void _showServiceForm({Service? service}) {
    final isEditing = service != null;
    final nameController = TextEditingController(text: service?.name ?? '');
    final priceController = TextEditingController(
      text: service?.price.toString() ?? '',
    );
    final linkController = TextEditingController(text: service?.link ?? '');
    final descController = TextEditingController(
      text: service?.description ?? '',
    );
    String? selectedImagePath = service?.imagePath;
    Map<String, String?> errors = {};
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
                    Text(
                      isEditing ? "Editar Servicio" : "Nuevo Servicio",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _azulMarino,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
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
                              final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null)
                                setDialogState(
                                  () => selectedImagePath = image.path,
                                );
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
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(13),
                                      child: _buildImagePreview(
                                        selectedImagePath!,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.room_service,
                                          color: _azulClaro,
                                          size: 40,
                                        ),
                                        Text(
                                          "Imagen",
                                          style: TextStyle(
                                            color: _azulClaro,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildField(
                          label: "Nombre del Trámite/Servicio",
                          controller: nameController,
                          isRequired: true,
                          errorText: errors['name'],
                        ),
                        _buildField(
                          label: "Precio",
                          controller: priceController,
                          prefixText: "\$ ",
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          errorText: errors['price'],
                        ),
                        _buildField(
                          label: "Link del sitio oficial (URL)",
                          controller: linkController,
                        ),
                        _buildField(
                          label: "Descripción",
                          controller: descController,
                        ),
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
                      if (nameController.text.isEmpty) {
                        errors['name'] = "Campo obligatorio";
                        hasErrors = true;
                      }
                      if (priceController.text.isEmpty) {
                        errors['price'] = "Campo obligatorio";
                        hasErrors = true;
                      }
                      if (hasErrors) {
                        setDialogState(() {});
                        return;
                      }

                      // Upload image if selected and it's a new image
                      String? imageUrl = service?.imagePath;
                      if (selectedImagePath != null &&
                          selectedImagePath!.isNotEmpty) {
                        // Si es una ruta de archivo local, convertir a base64
                        if (File(selectedImagePath!).existsSync()) {
                          try {
                            setDialogState(() {});
                            File imageFile = File(selectedImagePath!);
                            String imageId =
                                service?.serviceId ??
                                'temp_${DateTime.now().millisecondsSinceEpoch}';
                            imageUrl = await _firebaseService
                                .uploadServiceImage(imageFile, imageId);
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error al subir imagen: $e"),
                                ),
                              );
                            }
                            return;
                          }
                        } else {
                          // Ya es base64, usar tal cual
                          imageUrl = selectedImagePath;
                        }
                      }

                      final newService = Service(
                        serviceId: service?.serviceId,
                        name: nameController.text,
                        description: descController.text,
                        price: double.tryParse(priceController.text) ?? 0.0,
                        link: linkController.text,
                        imagePath: imageUrl,
                      );

                      if (isEditing)
                        await _firebaseService.updateService(newService);
                      else
                        await _firebaseService.addService(newService);

                      Navigator.pop(context);
                      _loadServices(); // Re-load services locally if needed, but StreamBuilder handles it
                      _showSnackBar(
                        isEditing ? "Servicio actualizado" : "Servicio creado",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _azulMarino,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "GUARDAR SERVICIO",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadServices() {
    // This can be empty because we use StreamBuilder, but we call it in the form logic
  }
  void _confirmDeletion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar"),
        content: Text("¿Eliminar ${_selectedForDelete.length} servicios?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              for (var id in _selectedForDelete)
                await _firebaseService.deleteService(id);
              Navigator.pop(context);
              setState(() {
                _isDeletingMode = false;
                _selectedForDelete.clear();
              });
            },
            child: const Text("Sí", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildFabMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isEditingMode || _isDeletingMode)
          FloatingActionButton.small(
            onPressed: () => setState(() {
              _isEditingMode = false;
              _isDeletingMode = false;
              _selectedForDelete.clear();
            }),
            backgroundColor: Colors.grey,
            child: const Icon(Icons.close, color: Colors.white),
          ),
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
              const PopupMenuItem(
                value: 'add',
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text("Agregar"),
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text("Editar"),
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Borrar"),
                ),
              ),
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
          Text(
            "Trámites y Servicios",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _azulMarino,
            ),
          ),
          Text(
            _isEditingMode
                ? "Selecciona un servicio para editar"
                : _isDeletingMode
                ? "Selecciona servicios para eliminar"
                : "Gestión de trámites digitales",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.7,
      ),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        bool isSelected = _selectedForDelete.contains(service.serviceId);

        return GestureDetector(
          onTap: () {
            if (_isEditingMode)
              _showServiceForm(service: service);
            else if (_isDeletingMode) {
              setState(() {
                if (isSelected)
                  _selectedForDelete.remove(service.serviceId);
                else if (service.serviceId != null)
                  _selectedForDelete.add(service.serviceId!);
              });
            } else
              _launchURL(service.link);
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.red.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isEditingMode
                        ? Colors.blue
                        : (isSelected ? Colors.red : Colors.grey.shade200),
                    width: (_isEditingMode || isSelected) ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child:
                            service.imagePath != null &&
                                service.imagePath!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: _buildGridImagePreview(
                                  service.imagePath!,
                                ),
                              )
                            : Icon(
                                Icons.description_outlined,
                                size: 40,
                                color: Colors.grey.shade300,
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "\$${service.price}",
                                  style: TextStyle(
                                    color: _azulMarino,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (service.link != null &&
                                    service.link!.isNotEmpty)
                                  const Icon(
                                    Icons.link,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isEditingMode)
                const Positioned(
                  top: 5,
                  right: 5,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.edit, size: 12, color: Colors.white),
                  ),
                ),
              if (_isDeletingMode)
                Positioned(
                  top: 5,
                  right: 5,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: isSelected ? Colors.red : Colors.grey,
                    child: Icon(
                      isSelected ? Icons.check : Icons.delete,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
