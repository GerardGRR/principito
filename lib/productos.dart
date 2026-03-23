import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database/database_helper.dart';
import 'models/product.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker();
  List<Product> _products = [];
  bool _isEditingMode = false;
  bool _isDeletingMode = false;
  final Set<int> _selectedForDelete = {};

  final Color _azulMarino = const Color(0xFF1A4661);
  final Color _azulClaro = const Color(0xFF5D9BBD);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _dbHelper.getProducts();
    setState(() {
      _products = products;
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
    _showSnackBar(_isDeletingMode ? "Selecciona productos para eliminar" : "Modo eliminación desactivado");
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- WIDGET DE CAMPO PERSONALIZADO CON VALIDACIÓN VISUAL ---
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

  void _showProductForm({Product? product}) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final qtyController = TextEditingController(text: product?.quantity.toString() ?? '');
    final brandController = TextEditingController(text: product?.brand ?? '');
    final tagsController = TextEditingController(text: product?.tags.join(',') ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    
    // Estados internos del formulario
    String? selectedImagePath = product?.imagePath;
    bool isQuantifiable = product?.isQuantifiable == 1;
    bool isAvailable = product?.isAvailable == 1;
    
    // Errores de validación
    Map<String, String?> errors = {};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isEditing ? "Editar Producto" : "Nuevo Producto",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _azulMarino)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Selector de Imagen
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image != null) setDialogState(() => selectedImagePath = image.path);
                      },
                      child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: _azulClaro, width: 2),
                        ),
                        child: selectedImagePath != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(13), child: Image.file(File(selectedImagePath!), fit: BoxFit.cover))
                            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_outlined, color: _azulClaro, size: 40), Text("Imagen", style: TextStyle(color: _azulClaro, fontSize: 12))]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  _buildField(label: "Nombre", controller: nameController, isRequired: true, errorText: errors['name']),
                  
                  // Selector de Tipo de Producto (Cuantificable vs Booleano)
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _azulClaro.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.inventory, color: _azulMarino, size: 20),
                            const SizedBox(width: 10),
                            const Text("Modo de Inventario", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Text("Contar unidades"),
                                selected: isQuantifiable,
                                onSelected: (val) => setDialogState(() => isQuantifiable = true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ChoiceChip(
                                label: const Text("Solo disponibilidad"),
                                selected: !isQuantifiable,
                                onSelected: (val) => setDialogState(() => isQuantifiable = false),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildField(label: "Precio", controller: priceController, prefixText: "\$ ", keyboardType: TextInputType.number, isRequired: true, errorText: errors['price'])),
                      const SizedBox(width: 15),
                      Expanded(
                        child: isQuantifiable 
                          ? _buildField(label: "Cantidad", controller: qtyController, keyboardType: TextInputType.number, isRequired: true, errorText: errors['qty'])
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Estado", style: TextStyle(color: _azulMarino, fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 5),
                                SwitchListTile(
                                  title: Text(isAvailable ? "Disponible" : "Agotado", style: TextStyle(fontSize: 13, color: isAvailable ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                                  value: isAvailable,
                                  onChanged: (val) => setDialogState(() => isAvailable = val),
                                  contentPadding: EdgeInsets.zero,
                                )
                              ],
                            ),
                      ),
                    ],
                  ),

                  _buildField(label: "Marca", controller: brandController),
                  _buildField(label: "Etiquetas", controller: tagsController),
                  _buildField(label: "Descripción", controller: descController),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        setDialogState(() => errors.clear());
                        bool hasValidationErrors = false;
                        
                        if (nameController.text.isEmpty) { errors['name'] = "El nombre es obligatorio"; hasValidationErrors = true; }
                        if (priceController.text.isEmpty) { errors['price'] = "El precio es obligatorio"; hasValidationErrors = true; }
                        if (isQuantifiable && qtyController.text.isEmpty) { errors['qty'] = "La cantidad es obligatoria"; hasValidationErrors = true; }

                        if (hasValidationErrors) {
                          setDialogState(() {}); // Refrescar para mostrar errores
                          return;
                        }

                        final newProduct = Product(
                          productId: product?.productId,
                          name: nameController.text,
                          description: descController.text,
                          price: double.tryParse(priceController.text) ?? 0.0,
                          quantity: isQuantifiable ? (int.tryParse(qtyController.text) ?? 0) : 0,
                          brand: brandController.text,
                          tags: tagsController.text.split(','),
                          imagePath: selectedImagePath,
                          isQuantifiable: isQuantifiable ? 1 : 0,
                          isAvailable: isAvailable ? 1 : 0,
                        );

                        if (isEditing) await _dbHelper.updateProduct(newProduct);
                        else await _dbHelper.insertProduct(newProduct);
                        
                        Navigator.pop(context);
                        _loadProducts();
                        _showSnackBar(isEditing ? "Producto actualizado" : "Producto creado");
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: _azulMarino, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text("GUARDAR PRODUCTO", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
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
        content: Text("¿Estás seguro que deseas eliminar ${_selectedForDelete.length} productos?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () async {
              for (var id in _selectedForDelete) await _dbHelper.softDeleteProduct(id);
              Navigator.pop(context);
              _toggleDeletingMode();
              _loadProducts();
              _showSnackBar("Productos eliminados");
            }, child: const Text("Eliminar", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 2 : 4;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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
            Positioned(bottom: 20, left: 20, right: 20,
              child: ElevatedButton.icon(onPressed: _confirmDeletion, icon: const Icon(Icons.delete_forever), label: Text("Eliminar Seleccionados (${_selectedForDelete.length})"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
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
            icon: const Icon(Icons.add_business, color: Colors.white),
            onSelected: (value) {
              if (value == 'add') _showProductForm();
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

  Widget _buildHeader(double width) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Gestión de Inventario", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _azulMarino)),
          Text(_isEditingMode ? "Modo edición activado" : _isDeletingMode ? "Modo eliminación activado" : "Catálogo disponible", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductGrid(int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        bool isSelected = _selectedForDelete.contains(product.productId);
        bool outOfStock = (product.isQuantifiable == 1 && product.quantity <= 0) || (product.isQuantifiable == 0 && product.isAvailable == 0);

        return GestureDetector(
          onTap: () {
            if (_isEditingMode) _showProductForm(product: product);
            else if (_isDeletingMode) setState(() { if (isSelected) _selectedForDelete.remove(product.productId); else _selectedForDelete.add(product.productId!); });
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(color: isSelected ? Colors.red.withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _isEditingMode ? Colors.blue : (isSelected ? Colors.red : (outOfStock ? Colors.orange : Colors.grey.shade200)), width: (_isEditingMode || isSelected) ? 2 : 1), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
                child: Column(
                  children: [
                    Expanded(child: product.imagePath != null ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: Image.file(File(product.imagePath!), width: double.infinity, fit: BoxFit.cover)) : Icon(Icons.inventory_2, size: 40, color: Colors.grey.shade300)),
                    Padding(padding: const EdgeInsets.all(8.0), child: Column(children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                      Text("\$${product.price}", style: TextStyle(color: _azulMarino, fontSize: 12)),
                      if (outOfStock) const Text("AGOTADO", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                      if (!outOfStock && product.isQuantifiable == 1) Text("Stock: ${product.quantity}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
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
