import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/product.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Product> _products = [];
  bool _isEditingMode = false;
  bool _isDeletingMode = false;
  final Set<int> _selectedForDelete = {};

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

  // --- FORMULARIO DE PRODUCTO ---
  void _showProductForm({Product? product}) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final qtyController = TextEditingController(text: product?.quantity.toString() ?? '');
    final branchController = TextEditingController(text: product?.branch ?? '');
    final tagsController = TextEditingController(text: product?.tags.join(',') ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Editar Producto" : "Nuevo Producto"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Descripción")),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: "Precio"), keyboardType: TextInputType.number),
              TextField(controller: qtyController, decoration: const InputDecoration(labelText: "Cantidad"), keyboardType: TextInputType.number),
              TextField(controller: branchController, decoration: const InputDecoration(labelText: "Sucursal")),
              TextField(controller: tagsController, decoration: const InputDecoration(labelText: "Etiquetas (coma-separadas)")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final newProduct = Product(
                productId: product?.productId,
                name: nameController.text,
                description: descController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                quantity: int.tryParse(qtyController.text) ?? 0,
                branch: branchController.text,
                tags: tagsController.text.split(','),
              );

              if (isEditing) {
                await _dbHelper.updateProduct(newProduct);
                _showSnackBar("Producto actualizado");
              } else {
                await _dbHelper.insertProduct(newProduct);
                _showSnackBar("Producto creado");
              }
              Navigator.pop(context);
              _loadProducts();
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // --- ELIMINACIÓN ---
  void _confirmDeletion() {
    if (_selectedForDelete.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar eliminación"),
        content: Text("¿Estás seguro que deseas eliminar ${_selectedForDelete.length} productos? Los registros históricos no se verán afectados."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              for (var id in _selectedForDelete) {
                await _dbHelper.softDeleteProduct(id);
              }
              Navigator.pop(context);
              _toggleDeletingMode();
              _loadProducts();
              _showSnackBar("Productos eliminados (desactivados)");
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
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
          // Botón de confirmación para borrar (flotante inferior)
          if (_isDeletingMode && _selectedForDelete.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton.icon(
                onPressed: _confirmDeletion,
                icon: const Icon(Icons.delete_forever),
                label: Text("Eliminar Seleccionados (${_selectedForDelete.length})"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
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
          FloatingActionButton.small(
            onPressed: () => setState(() { _isEditingMode = false; _isDeletingMode = false; }),
            backgroundColor: Colors.grey,
            child: const Icon(Icons.close, color: Colors.white),
          ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () {}, // El menú se despliega al mantener o con un PopupMenu
          backgroundColor: const Color(0xFF1A4661),
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
          const Text(
            "Gestión de Inventario",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A4661)),
          ),
          Text(
            _isEditingMode ? "Selecciona un producto para editar" : 
            _isDeletingMode ? "Selecciona productos para eliminar" : "Catálogo disponible",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        bool isSelected = _selectedForDelete.contains(product.productId);

        return GestureDetector(
          onTap: () {
            if (_isEditingMode) {
              _showProductForm(product: product);
            } else if (_isDeletingMode) {
              setState(() {
                if (isSelected) _selectedForDelete.remove(product.productId);
                else _selectedForDelete.add(product.productId!);
              });
            }
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isEditingMode ? Colors.blue : (isSelected ? Colors.red : Colors.grey.shade200),
                    width: (_isEditingMode || isSelected) ? 2 : 1,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                ),
                child: Column(
                  children: [
                    Expanded(child: Icon(Icons.inventory_2, size: 40, color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text("\$${product.price}", style: const TextStyle(color: Color(0xFF1A4661), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isEditingMode)
                const Positioned(
                  top: 5, right: 5,
                  child: CircleAvatar(radius: 12, backgroundColor: Colors.blue, child: Icon(Icons.edit, size: 12, color: Colors.white)),
                ),
              if (_isDeletingMode)
                Positioned(
                  top: 5, right: 5,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: isSelected ? Colors.red : Colors.grey,
                    child: Icon(isSelected ? Icons.check : Icons.delete, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
