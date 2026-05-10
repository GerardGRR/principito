import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database/firebase_service.dart';
import 'models/product.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  List<Product> _products = [];
  bool _isEditingMode = false;
  bool _isDeletingMode = false;
  final Set<String> _selectedForDelete = {};
  static const Color _azulMarino = Color(0xFF1A4661);
  static const Color _azulClaro = Color(0xFF5D9BBD);
  static const double _borderRadius = 12;
  static const double _imageBorderRadius = 8;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 2 : 4;
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Product>>(
        stream: _firebaseService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          _products = snapshot.data ?? [];
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(screenWidth),
                    _buildProductGrid(crossAxisCount),
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

  void _toggleMode(String mode) {
    setState(() {
      if (mode == 'edit') {
        _isEditingMode = !_isEditingMode;
        _isDeletingMode = false;
      } else if (mode == 'delete') {
        _isDeletingMode = !_isDeletingMode;
        _isEditingMode = false;
      }
      if (!_isEditingMode && !_isDeletingMode) _selectedForDelete.clear();
    });
    final msg = mode == 'edit'
        ? (_isEditingMode ? "Edición activada" : "Edición desactivada")
        : (_isDeletingMode
              ? "Selecciona para eliminar"
              : "Eliminación desactivada");
    _showSnackBar(msg);
  }

  void _showSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        ),
      );
  Widget _buildModeSwitch(
    String label,
    bool value,
    Function(bool) onChanged, [
    Color? color,
  ]) => SwitchListTile(
    title: Text(label, style: const TextStyle(fontSize: 14)),
    value: value,
    onChanged: onChanged,
    contentPadding: EdgeInsets.zero,
    activeColor: color ?? _azulMarino,
  );
  Widget _buildImagePreview(String imagePath) {
    if (File(imagePath).existsSync())
      return Image.file(File(imagePath), fit: BoxFit.cover);
    try {
      final bytes = base64Decode(imagePath);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (e) {
      return Icon(Icons.image_not_supported, color: Colors.grey.shade500);
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    String? errorText,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: errorText != null ? Colors.red : _azulMarino,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (isRequired)
              const Text(" *", style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: _azulMarino),
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixStyle: TextStyle(
              color: _azulMarino,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_imageBorderRadius),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : _azulClaro,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        if (errorText != null)
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
  void _showProductForm({Product? product}) {
    final isEditing = product != null;
    final nc = TextEditingController(text: product?.name ?? '');
    final pc = TextEditingController(text: product?.price.toString() ?? '');
    final qc = TextEditingController(text: product?.quantity.toString() ?? '');
    final bc = TextEditingController(text: product?.brand ?? '');
    final tc = TextEditingController(text: product?.tags.join(',') ?? '');
    final dc = TextEditingController(text: product?.description ?? '');
    String? selectedImagePath = product?.imagePath;
    bool isQuantifiable = product?.isQuantifiable == 1;
    bool isAvailable = product?.isAvailable == 1;
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
                      isEditing ? "Editar Producto" : "Nuevo Producto",
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
                                          Icons.camera_alt_outlined,
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
                          label: "Nombre",
                          controller: nc,
                          isRequired: true,
                          errorText: errors['name'],
                        ),
                        Column(
                          children: [
                            Text(
                              "Modo de Inventario",
                              style: TextStyle(
                                color: _azulMarino,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            _buildModeSwitch(
                              isQuantifiable
                                  ? "Contar unidades"
                                  : "Solo disponibilidad",
                              isQuantifiable,
                              (val) =>
                                  setDialogState(() => isQuantifiable = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildField(
                          label: "Precio",
                          controller: pc,
                          prefixText: "\$ ",
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          errorText: errors['price'],
                        ),
                        if (isQuantifiable)
                          _buildField(
                            label: "Cantidad",
                            controller: qc,
                            keyboardType: TextInputType.number,
                            isRequired: true,
                            errorText: errors['qty'],
                          )
                        else
                          Column(
                            children: [
                              Text(
                                "Estado",
                                style: TextStyle(
                                  color: _azulMarino,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              _buildModeSwitch(
                                isAvailable ? "Disponible" : "Agotado",
                                isAvailable,
                                (val) =>
                                    setDialogState(() => isAvailable = val),
                                Colors.green,
                              ),
                              const SizedBox(height: 15),
                            ],
                          ),
                        _buildField(label: "Marca", controller: bc),
                        _buildField(label: "Etiquetas", controller: tc),
                        _buildField(label: "Descripción", controller: dc),
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
                      errors.clear();
                      if (nc.text.isEmpty) errors['name'] = "Campo obligatorio";
                      if (pc.text.isEmpty)
                        errors['price'] = "Campo obligatorio";
                      if (isQuantifiable && qc.text.isEmpty)
                        errors['qty'] = "Campo obligatorio";

                      // Upload image if selected and it's a new image
                      String? imageUrl = product?.imagePath;
                      if (selectedImagePath != null &&
                          selectedImagePath!.isNotEmpty) {
                        // Si es una ruta de archivo local, convertir a base64
                        if (File(selectedImagePath!).existsSync()) {
                          try {
                            setDialogState(() {});
                            File imageFile = File(selectedImagePath!);
                            String imageId =
                                product?.productId ??
                                'temp_${DateTime.now().millisecondsSinceEpoch}';
                            imageUrl = await _firebaseService
                                .uploadProductImage(imageFile, imageId);
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
                      final newProduct = Product(
                        productId: product?.productId,
                        createdAt: product?.createdAt ?? DateTime.now(),
                        name: nc.text,
                        description: dc.text,
                        price: double.tryParse(pc.text) ?? 0.0,
                        quantity: isQuantifiable
                            ? (int.tryParse(qc.text) ?? 0)
                            : 0,
                        brand: bc.text,
                        tags: tc.text.split(','),
                        imagePath: imageUrl,
                        isQuantifiable: isQuantifiable ? 1 : 0,
                        isAvailable: isAvailable ? 1 : 0,
                      );

                      if (isEditing)
                        await _firebaseService.updateProduct(newProduct);
                      else
                        await _firebaseService.addProduct(newProduct);

                      Navigator.pop(context);
                      _showSnackBar(
                        isEditing ? "Producto actualizado" : "Producto creado",
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
                      "GUARDAR PRODUCTO",
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

  void _confirmDeletion() {
    if (_selectedForDelete.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text(
          "¿Estás seguro que deseas eliminar ${_selectedForDelete.length} productos?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              for (var id in _selectedForDelete)
                await _firebaseService.deleteProduct(id);
              Navigator.pop(context);
              setState(() {
                _isDeletingMode = false;
                _selectedForDelete.clear();
              });
              _showSnackBar("Productos eliminados");
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabMenu() => Column(
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
          icon: const Icon(Icons.add_business, color: Colors.white),
          onSelected: (value) {
            if (value == 'add') _showProductForm();
            if (value == 'edit') _toggleMode('edit');
            if (value == 'delete') _toggleMode('delete');
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'add',
              child: ListTile(leading: Icon(Icons.add), title: Text("Agregar")),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(leading: Icon(Icons.edit), title: Text("Editar")),
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
  Widget _buildHeader(double width) => Container(
    padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gestión de Inventario",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _azulMarino,
          ),
        ),
        Text(
          _isEditingMode
              ? "Modo edición"
              : _isDeletingMode
              ? "Modo eliminación"
              : "Catálogo disponible",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
  Color _getProductBorderColor(bool isSelected, bool outOfStock) {
    if (_isEditingMode) return Colors.blue;
    if (isSelected) return Colors.red;
    if (outOfStock) return Colors.orange;
    return Colors.grey.shade200;
  }

  Widget _buildProductCard(Product product, bool isSelected) {
    final outOfStock =
        (product.isQuantifiable == 1 && product.quantity <= 0) ||
        (product.isQuantifiable == 0 && product.isAvailable == 0);
    return GestureDetector(
      onTap: () {
        if (_isEditingMode) {
          _showProductForm(product: product);
        } else if (_isDeletingMode) {
          setState(() {
            if (isSelected) {
              _selectedForDelete.remove(product.productId);
            } else if (product.productId != null) {
              _selectedForDelete.add(product.productId!);
            }
          });
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.red.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(_borderRadius),
              border: Border.all(
                color: _getProductBorderColor(isSelected, outOfStock),
                width: (_isEditingMode || isSelected) ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _buildProductImage(product)),
                Expanded(
                  flex: 4,
                  child: _buildProductInfo(product, outOfStock),
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
  }

  Widget _buildProductImage(Product product) => Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.vertical(top: Radius.circular(_borderRadius)),
    ),
    child: product.imagePath != null && product.imagePath!.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(_borderRadius - 1),
            ),
            child: _buildImagePreview(product.imagePath!),
          )
        : Icon(Icons.inventory_2, size: 40, color: Colors.grey.shade300),
  );
  Widget _buildProductInfo(Product product, bool outOfStock) => Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "\$${product.price.toStringAsFixed(2)}",
              style: TextStyle(
                color: _azulMarino,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (outOfStock)
              const Text(
                "AGOTADO",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!outOfStock && product.isQuantifiable == 1)
              Text(
                "Stock: ${product.quantity}",
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
          ],
        ),
      ],
    ),
  );
  Widget _buildProductGrid(int columns) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 0.7,
    ),
    itemCount: _products.length,
    itemBuilder: (context, index) {
      final product = _products[index];
      bool isSelected = _selectedForDelete.contains(product.productId);
      return _buildProductCard(product, isSelected);
    },
  );
}
