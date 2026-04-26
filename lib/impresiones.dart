import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'main.dart';

class ImpresionesPage extends StatefulWidget {
  const ImpresionesPage({super.key});
  @override
  State<ImpresionesPage> createState() => _ImpresionesPageState();
}

class _ImpresionesPageState extends State<ImpresionesPage> {
  final ScrollController _scrollController = ScrollController();

  // --- VARIABLES PARA EL MANEJO DE PÁGINAS ---
  final TextEditingController _paginasController = TextEditingController(
    text: "Todas",
  );
  String? _errorPaginas; // Para mostrar el mensaje en rojo si hay error

  List<Uint8List> _paginasImagenes = [];
  String _nombreArchivo = "Ningún archivo seleccionado";
  String _rutaArchivo = "";
  bool _estaCargando = false;

  String _tamanoPapel = "Carta";
  bool _aColor = true;
  int _copias = 1;

  Future<void> _procesarArchivoDesdeRuta(String ruta, String nombre) async {
    setState(() {
      _estaCargando = true;
      _nombreArchivo = nombre;
      _rutaArchivo = ruta;
      _paginasController.text = "Todas";
    });

    try {
      final document = await PdfDocument.openFile(ruta);
      List<Uint8List> imagenesTemp = [];

      int maxPages = document.pagesCount > 20 ? 20 : document.pagesCount;

      for (int i = 1; i <= maxPages; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width * 1.5,
          height: page.height * 1.5,
          format: PdfPageImageFormat.jpeg,
        );
        if (pageImage != null) imagenesTemp.add(pageImage.bytes);
        await page.close();
      }

      setState(() {
        _paginasImagenes = imagenesTemp;
        _estaCargando = false;
      });
    } catch (e) {
      setState(() => _estaCargando = false);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      archivoSeleccionado.addListener(_escucharArchivo);

      // EXTRA: por si ya había archivo antes
      _escucharArchivo();
    });
  }

  void _escucharArchivo() {
    final ruta = archivoSeleccionado.value;

    if (ruta != null && ruta.isNotEmpty) {
      final nombre = ruta.split('/').last;

      _procesarArchivoDesdeRuta(ruta, nombre);
      // esperar antes de limpiar (clave)
      Future.delayed(const Duration(milliseconds: 300), () {
        archivoSeleccionado.value = null;
      });
    }
  }

  @override
  void dispose() {
    archivoSeleccionado.removeListener(_escucharArchivo);
    super.dispose();
  }
  //---------------------------

  // --- LÓGICA DE VALIDACIÓN DEL RANGO ---
  void _validarRango(String valor, int totalPDF) {
    if (valor.toLowerCase().trim() == "todas" || valor.isEmpty) {
      setState(() => _errorPaginas = null);
      return;
    }

    try {
      List<String> partes = valor.split(',');
      for (var parte in partes) {
        parte = parte.trim();
        if (parte.contains('-')) {
          List<String> rango = parte.split('-');
          int inicio = int.parse(rango[0].trim());
          int fin = int.parse(rango[1].trim());
          if (inicio > totalPDF ||
              fin > totalPDF ||
              inicio > fin ||
              inicio <= 0)
            throw Exception();
        } else {
          int p = int.parse(parte);
          if (p > totalPDF || p <= 0) throw Exception();
        }
      }
      setState(() => _errorPaginas = null);
    } catch (e) {
      setState(() => _errorPaginas = "Rango inválido (Ej: 1-5 o 1,3)");
    }
  }

  Future<void> _seleccionarYProcesarArchivo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _estaCargando = true;
        _nombreArchivo = result.files.single.name;
        _rutaArchivo = result.files.single.path!;
        _paginasController.text = "Todas"; // Reiniciar al subir nuevo
      });

      try {
        final document = await PdfDocument.openFile(_rutaArchivo);
        List<Uint8List> imagenesTemp = [];

        for (int i = 1; i <= document.pagesCount; i++) {
          final page = await document.getPage(i);
          final pageImage = await page.render(
            width: page.width * 1.5,
            height: page.height * 1.5,
            format: PdfPageImageFormat.jpeg,
          );
          if (pageImage != null) imagenesTemp.add(pageImage.bytes);
          await page.close();
        }

        setState(() {
          _paginasImagenes = imagenesTemp;
          _estaCargando = false;
        });
      } catch (e) {
        setState(() => _estaCargando = false);
      }
    }
  }

  void _mostrarOpciones() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Importante para que el teclado no tape el diseño
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
                left: 25,
                right: 25,
                top: 25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Opciones de Impresión",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A6B91),
                    ),
                  ),
                  Divider(),

                  // --- CAMPO DE TEXTO PARA PÁGINAS ---
                  Text(
                    "Páginas a imprimir:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _paginasController,
                    decoration: InputDecoration(
                      hintText: "Ej: 1, 3, 5-10 o Todas",
                      errorText: _errorPaginas,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pages_outlined),
                    ),
                    onChanged: (val) {
                      _validarRango(val, _paginasImagenes.length);
                      setModalState(() {}); // Actualiza el modal en tiempo real
                    },
                  ),

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Número de copias:", style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _copias > 1
                                ? () {
                                    setModalState(() => _copias--);
                                    setState(() {});
                                  }
                                : null,
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                            ),
                          ),
                          Text(
                            "$_copias",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setModalState(() => _copias++);
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  DropdownButtonFormField<String>(
                    value: _tamanoPapel,
                    decoration: InputDecoration(labelText: "Tamaño de papel"),
                    items: ["Carta", "Oficio", "A4"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _tamanoPapel = val!),
                  ),
                  SwitchListTile(
                    title: Text("Impresión a Color"),
                    value: _aColor,
                    activeColor: Color(0xFFF1C40F),
                    onChanged: (val) {
                      setState(() => _aColor = val);
                      setModalState(() {});
                    },
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2A6B91),
                        foregroundColor: Colors.white,
                      ),
                      // Deshabilita el botón si hay error en las páginas
                      onPressed: _errorPaginas == null
                          ? () => Navigator.pop(context)
                          : null,
                      child: Text("Guardar Configuración"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            child: RawScrollbar(
              controller: _scrollController,
              thumbColor: Color(0xFFF1C40F),
              thickness: 12,
              radius: Radius.circular(10),
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 25),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "Páginas detectadas: ${_paginasImagenes.length}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A6B91),
                        ),
                      ),
                    ),
                    _buildPagesGrid(),
                    SizedBox(height: 40),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 5, color: Color(0xFFD6EAF8).withOpacity(0.2)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5D9BBD), Color(0xFF8EBFD4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Wrap(
        spacing: 30,
        runSpacing: 25,
        children: [
          Container(
            width: 150,
            height: 210,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: _paginasImagenes.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(_paginasImagenes[0], fit: BoxFit.cover),
                  )
                : Center(
                    child: Icon(
                      Icons.description,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
          ),

          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gestor de Impresión",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _nombreArchivo,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 15),
                Text(
                  "Configuración: $_tamanoPapel | ${_aColor ? 'Color' : 'B/N'} | Copias: $_copias",
                  style: TextStyle(color: Colors.white70),
                ),
                // Muestra el rango de páginas elegido
                Text(
                  "Páginas seleccionadas: ${_paginasController.text}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          height: 48,
          child: ElevatedButton(
            // Deshabilitado si no hay archivo o si el rango de páginas está mal
            onPressed: (_paginasImagenes.isEmpty || _errorPaginas != null)
                ? null
                : () {
                    /* Lógica de impresión */
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF1C40F),
              foregroundColor: Color(0xFF1A4661),
              disabledBackgroundColor: Colors.grey[400],
            ),
            child: Text(
              "Imprimir Todo",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 15),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: _seleccionarYProcesarArchivo,
              icon: Icon(Icons.upload, size: 18),
              label: Text("Subir PDF"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: _mostrarOpciones,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2A6B91),
                foregroundColor: Colors.white,
              ),
              child: Text("Opciones"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPagesGrid() {
    if (_estaCargando) {
      return Padding(
        padding: EdgeInsets.all(50),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF2A6B91)),
        ),
      );
    }

    if (_paginasImagenes.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(50),
        child: Center(
          child: Text(
            "Sube un archivo para visualizar las hojas",
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(30),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 25,
        childAspectRatio: 0.70,
      ),
      itemCount: _paginasImagenes.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _paginasImagenes[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Página ${index + 1}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A6B91),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      color: Color(0xFF1A4661),
      child: Text(
        "© 2026 Papelería El Principito - Conexión con Sucursal Activa",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
