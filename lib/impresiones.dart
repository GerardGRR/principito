import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database/firebase_service.dart';
import 'models/printing_document.dart';
import 'models/user.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ImpresionesPage extends StatefulWidget {
  const ImpresionesPage({super.key});
  @override
  State<ImpresionesPage> createState() => _ImpresionesPageState();
}

class _ImpresionesPageState extends State<ImpresionesPage> {
  final FirebaseService _fs = FirebaseService();
  bool _loading = false;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _fs.getCurrentUserData().then(
      (u) => mounted ? setState(() => _user = u) : null,
    );
  }

  bool get _isAdmin => _user?.role == 'administrador';
  bool get _isWorker => _user?.role == 'empleado';
  bool get _canDownload => _isAdmin || _isWorker;
  bool get _canDelete => _isAdmin || _isWorker;

  Future<void> _uploadDoc() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'txt',
        'jpg',
        'png',
      ],
    );
    if (result?.files.single.path case final path?) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => _FormDialog(
          file: File(path),
          fileName: result!.files.single.name,
          onUpload: (pages, range, color, notes) => _handleUpload(
            File(path),
            result.files.single.name,
            pages,
            range,
            color,
            notes,
          ),
        ),
      );
    }
  }

  Future<void> _handleUpload(
    File f,
    String name,
    int? pages,
    String? range,
    String color,
    String? notes,
  ) async {
    try {
      setState(() => _loading = true);
      await _fs.uploadPrintingDocument(
        f,
        name,
        numPages: pages,
        pageRange: range,
        printColor: color,
        notes: notes,
      );
      _showMsg('✓ Documento subido');
    } catch (e) {
      _showMsg('✗ Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<bool> _reqPermission() async {
    if (!Platform.isAndroid) return true;
    final info = await DeviceInfoPlugin().androidInfo;
    final status = info.version.sdkInt >= 30
        ? await Permission.manageExternalStorage.status
        : await Permission.storage.status;
    return status.isGranted ||
        (info.version.sdkInt >= 30
            ? (await Permission.manageExternalStorage.request()).isGranted
            : (await Permission.storage.request()).isGranted);
  }

  Future<void> _download(PrintingDocument doc) async {
    try {
      if (!await _reqPermission()) throw Exception('Permisos requeridos');
      setState(() => _loading = true);
      final bytes = await _fs.getPrintingDocumentBytes(doc.fileData);
      final path =
          '${(await getApplicationDocumentsDirectory()).path}/${doc.fileName}';
      await File(path).writeAsBytes(bytes);
      await _fs.addWorkerDownload(doc.documentId, _user!.uid);
      await _fs.markAsPrinted(doc.documentId, _user!.name);
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Descargado'),
            action: SnackBarAction(
              label: 'ABRIR',
              onPressed: () => OpenFilex.open(path),
            ),
          ),
        );
      }
    } catch (e) {
      _showMsg('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(PrintingDocument doc) async {
    try {
      if (!await _reqPermission()) throw Exception('Permisos requeridos');
      setState(() => _loading = true);
      final bytes = await _fs.getPrintingDocumentBytes(doc.fileData);
      final path = '${(await getTemporaryDirectory()).path}/${doc.fileName}';
      await File(path).writeAsBytes(bytes);
      await OpenFilex.open(path);
      await _fs.addWorkerDownload(doc.documentId, _user!.uid);
      await _fs.markAsPrinted(doc.documentId, _user!.name);
    } catch (e) {
      _showMsg('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMsg(String msg, {bool error = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: error ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Impresiones'),
        backgroundColor: const Color(0xFF2A6B91),
        foregroundColor: Colors.white,
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                StreamBuilder<List<PrintingDocument>>(
                  stream: _fs.getPrintingDocuments(),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Sin documentos',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (_, i) => _buildCard(docs[i]),
                    );
                  },
                ),
                if (_loading) const Center(child: CircularProgressIndicator()),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _uploadDoc,
        backgroundColor: const Color(0xFF2A6B91),
        label: const Text('Subir Documento'),
        icon: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildCard(PrintingDocument doc) {
    final pending = doc.status == 'pendiente';
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: pending ? const Color(0xFFF1C40F) : Colors.grey.shade300,
          width: pending ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENCABEZADO: Icono, Nombre y Estado
            Row(
              children: [
                Text(
                  _icon(doc.fileExtension),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.fileName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A6B91),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Subido por: ${doc.uploaderName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: pending ? const Color(0xFFF1C40F) : Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pending ? '⏳ Pendiente' : '✓ Impreso',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: pending ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // FECHA E INFORMACIÓN DE IMPRESIÓN
            Text(
              'Fecha: ${doc.uploadedAt.day}/${doc.uploadedAt.month}/${doc.uploadedAt.year} ${doc.uploadedAt.hour.toString().padLeft(2, '0')}:${doc.uploadedAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (doc.markedAsPrintedAt != null)
              Text(
                'Impreso por: ${doc.markedAsPrintedBy}',
                style: TextStyle(fontSize: 12, color: Colors.green.shade600),
              ),

            // SECCIÓN DESPLEGABLE DE DETALLES
            if (doc.numPages != null ||
                doc.pageRange != null ||
                doc.printColor != null ||
                doc.notes != null) ...[
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text(
                    'Detalles de Impresión',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A6B91),
                    ),
                  ),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  expandedAlignment: Alignment.topLeft,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (doc.numPages != null)
                            Text(
                              '• Páginas: ${doc.numPages}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          if (doc.pageRange != null)
                            Text(
                              '• Rango: ${doc.pageRange}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          if (doc.printColor != null)
                            Text(
                              '• Tipo: ${doc.printColor == 'color' ? 'Color' : 'Blanco y Negro'}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          if (doc.notes != null)
                            Text(
                              '• Notas: ${doc.notes}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // BOTONES DE ACCIÓN
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_canDownload)
                  OutlinedButton.icon(
                    onPressed: () => _download(doc),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Descargar'),
                  ),
                if (_canDelete)
                  OutlinedButton.icon(
                    onPressed: () => _confirmDelete(doc),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
              ],
            ),

            // FOOTER: Contador de descargas
            if (doc.downloadedByWorkers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Descargado por ${doc.downloadedByWorkers.length} trabajador(es)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(PrintingDocument doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _fs.deletePrintingDocument(doc.documentId);
                if (mounted) {
                  Navigator.pop(context);
                  _showMsg('✓ Eliminado');
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
                _showMsg('Error: $e', error: true);
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _icon(String ext) {
    const map = {
      'pdf': '📄',
      'doc': '📝',
      'docx': '📝',
      'xls': '📊',
      'xlsx': '📊',
      'ppt': '🎬',
      'pptx': '🎬',
      'jpg': '🖼️',
      'png': '🖼️',
      'jpeg': '🖼️',
      'txt': '📃',
    };
    return map[ext.toLowerCase()] ?? '📦';
  }
}

class _FormDialog extends StatefulWidget {
  final File file;
  final String fileName;
  final Function(int?, String?, String, String?) onUpload;
  const _FormDialog({
    required this.file,
    required this.fileName,
    required this.onUpload,
  });
  @override
  State<_FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<_FormDialog> {
  late TextEditingController _pages, _range, _notes;
  String _color = 'color';
  String? _error;
  @override
  void initState() {
    super.initState();
    _pages = TextEditingController();
    _range = TextEditingController();
    _notes = TextEditingController();
  }

  @override
  void dispose() {
    _pages.dispose();
    _range.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_pages.text.isNotEmpty && int.tryParse(_pages.text.trim()) == null) {
      setState(() => _error = '❌ Solo números para páginas');
      return false;
    }
    if (_range.text.isNotEmpty &&
        !RegExp(r'^(\d+(-\d+)?)(,\d+(-\d+)?)*$').hasMatch(_range.text.trim())) {
      setState(() => _error = '❌ Formato: 1-10, 1,3,5 o 1-5,10');
      return false;
    }
    setState(() => _error = null);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalles de Impresión'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Archivo: ${widget.fileName}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            _field('¿Cuántas páginas?', _pages, 'Ej: 10'),
            const SizedBox(height: 12),
            _field('¿Qué páginas? (opt.)', _range, 'Ej: 1-10 o 1,3,5'),
            const SizedBox(height: 12),
            const Text(
              'Tipo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Row(
              children: ['color', 'blanco_negro']
                  .map(
                    (v) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _color = v),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _color == v,
                              onChanged: (_) => setState(() => _color = v),
                            ),
                            Text(
                              v == 'color' ? 'Color' : 'B/N',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Text(
              'Notas (opt.)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Info...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 11),
                ),
              ),
            const SizedBox(height: 12),
            if (_pages.text.isNotEmpty ||
                _range.text.isNotEmpty ||
                _notes.text.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    dense: true,
                    title: const Text(
                      '📋 Resumen',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_pages.text.isNotEmpty)
                              Text(
                                '✓ Páginas: ${_pages.text}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            if (_range.text.isNotEmpty)
                              Text(
                                '✓ Rango: ${_range.text}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            Text(
                              '✓ Tipo: ${_color == 'color' ? 'Color' : 'B/N'}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            if (_notes.text.isNotEmpty)
                              Text(
                                '✓ Notas: ${_notes.text}',
                                style: const TextStyle(fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_validate()) return;
            Navigator.pop(context);
            widget.onUpload(
              _pages.text.isEmpty ? null : int.parse(_pages.text),
              _range.text.isEmpty ? null : _range.text,
              _color,
              _notes.text.isEmpty ? null : _notes.text,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Subir'),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          onChanged: (_) => _validate(),
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}
