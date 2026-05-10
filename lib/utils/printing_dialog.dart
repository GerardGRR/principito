import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../database/firebase_service.dart';

class PrintingUploadHelper {
  static Future<void> showUploadDialog(
    BuildContext context,
    FirebaseService fs,
    Function(String, {bool error}) showMsg,
  ) async {
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
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => PrintingFormDialog(
          file: File(path),
          fileName: result!.files.single.name,
          onUpload: (pages, range, color, notes) => handleUpload(
            File(path),
            result.files.single.name,
            pages,
            range,
            color,
            notes,
            fs,
            showMsg,
            context,
          ),
        ),
      );
    }
  }

  static Future<void> handleUpload(
    File f,
    String name,
    int? pages,
    String? range,
    String color,
    String? notes,
    FirebaseService fs,
    Function(String, {bool error}) showMsg,
    BuildContext context,
  ) async {
    try {
      await fs.uploadPrintingDocument(
        f,
        name,
        numPages: pages,
        pageRange: range,
        printColor: color,
        notes: notes,
      );
      showMsg('✓ Documento subido');
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      showMsg('✗ Error: $e', error: true);
    }
  }
}

class PrintingFormDialog extends StatefulWidget {
  final File file;
  final String fileName;
  final Function(int?, String?, String, String?) onUpload;
  const PrintingFormDialog({
    required this.file,
    required this.fileName,
    required this.onUpload,
  });
  @override
  State<PrintingFormDialog> createState() => _PrintingFormDialogState();
}

class _PrintingFormDialogState extends State<PrintingFormDialog> {
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
      setState(() => _error = 'Solo números para páginas');
      return false;
    }
    if (_range.text.isNotEmpty &&
        !RegExp(r'^(\d+(-\d+)?)(,\d+(-\d+)?)*$').hasMatch(_range.text.trim())) {
      setState(() => _error = 'Formato: 1-10, 1,3,5 o 1-5,10');
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
