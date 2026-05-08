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
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  AppUser? _currentUser;
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _firebaseService.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  bool get _isAdmin => _currentUser?.role == 'administrador';

  Future<void> _uploadDocument() async {
    try {
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
      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        setState(() => _isLoading = true);
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        await _firebaseService.uploadPrintingDocument(file, fileName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Documento subido exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error: $e'),

            backgroundColor: Colors.red,

            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Importante: Importa 'package:device_info_plus/device_info_plus.dart'
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Si es Android 11 (SDK 30) o superior
      if (androidInfo.version.sdkInt >= 30) {
        // Intentamos pedir el permiso de "Administrar todos los archivos"
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }
        return status.isGranted;
      } else {
        // Para Android 10 o inferior usamos el normal
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
    }
    return true;
  }

  Future<void> _downloadDocument(PrintingDocument doc) async {
    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        // ... mensaje de error de permisos ...
        return;
      }
      setState(() => _isLoading = true);
      final bytes = await _firebaseService.getPrintingDocumentBytes(
        doc.fileData,
      );
      // Usamos getApplicationDocumentsDirectory para evitar problemas de permisos
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${doc.fileName}';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Registrar descarga en Firebase
      await _firebaseService.addWorkerDownload(
        doc.documentId,
        _currentUser!.uid,
      );

      if (mounted) {
        setState(
          () => _isLoading = false,
        ); // Quitamos el loading antes del SnackBar

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Documento guardado'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'ABRIR',
              textColor: Colors.white,
              onPressed: () {
                OpenFilex.open(
                  filePath,
                ); // <--- Esto abre el archivo al tocar el botón
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error descargando: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openDocument(PrintingDocument doc) async {
    try {
      // Solicitar permisos de almacenamiento
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✗ Se necesitan permisos de almacenamiento'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      setState(() => _isLoading = true);
      // Convertir Base64 a bytes
      final bytes = await _firebaseService.getPrintingDocumentBytes(
        doc.fileData,
      );
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${doc.fileName}');
      await tempFile.writeAsBytes(bytes);
      // Abrir archivo
      await OpenFilex.open(tempFile.path);
      // Registrar descarga
      await _firebaseService.addWorkerDownload(
        doc.documentId,
        _currentUser!.uid,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error abriendo: $e'),

            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAsPrinted(PrintingDocument doc) async {
    try {
      await _firebaseService.markAsPrinted(doc.documentId, _currentUser!.name);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Marcado como impresado'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✗ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteDocument(PrintingDocument doc) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar documento'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este documento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firebaseService.deletePrintingDocument(doc.documentId);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Documento eliminado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✗ Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'ppt':
      case 'pptx':
        return '🎬';
      case 'jpg':
      case 'png':
      case 'jpeg':
        return '🖼️';
      case 'txt':
        return '📃';
      default:
        return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Centro de Impresiones'),
        backgroundColor: const Color(0xFF2A6B91),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                StreamBuilder<List<PrintingDocument>>(
                  stream: _firebaseService.getPrintingDocuments(),

                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final documents = snapshot.data ?? [];
                    if (documents.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
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
                      itemCount: documents.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        final isPending = doc.status == 'pendiente';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isPending
                                  ? const Color(0xFFF1C40F)
                                  : Colors.grey.shade300,
                              width: isPending ? 2 : 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _getFileIcon(doc.fileExtension),
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          const SizedBox(height: 4),
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
                                        color: isPending
                                            ? const Color(0xFFF1C40F)
                                            : Colors.green,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isPending
                                            ? '⏳ Pendiente'
                                            : '✓ Impresado',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isPending
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Fecha: ${doc.uploadedAt.day}/${doc.uploadedAt.month}/${doc.uploadedAt.year} ${doc.uploadedAt.hour.toString().padLeft(2, '0')}:${doc.uploadedAt.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          if (doc.markedAsPrintedAt !=
                                              null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Impresado por: ${doc.markedAsPrintedBy}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green.shade600,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (isPending && !_isAdmin)
                                      OutlinedButton.icon(
                                        onPressed: () => _downloadDocument(doc),
                                        icon: const Icon(
                                          Icons.download,
                                          size: 18,
                                        ),
                                        label: const Text('Descargar'),
                                      ),
                                    if (!_isAdmin)
                                      OutlinedButton.icon(
                                        onPressed: () => _openDocument(doc),
                                        icon: const Icon(
                                          Icons.open_in_new,
                                          size: 18,
                                        ),
                                        label: const Text('Abrir'),
                                      ),
                                    if (isPending && !_isAdmin)
                                      ElevatedButton.icon(
                                        onPressed: () => _markAsPrinted(doc),
                                        icon: const Icon(Icons.done, size: 18),
                                        label: const Text('✓ Impresado'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    if (_isAdmin)
                                      OutlinedButton.icon(
                                        onPressed: () => _downloadDocument(doc),
                                        icon: const Icon(
                                          Icons.download,
                                          size: 18,
                                        ),
                                        label: const Text('Descargar'),
                                      ),
                                    if (_isAdmin)
                                      OutlinedButton.icon(
                                        onPressed: () => _deleteDocument(doc),
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 18,
                                        ),
                                        label: const Text('Eliminar'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
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
                      },
                    );
                  },
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _uploadDocument,
              backgroundColor: const Color(0xFF2A6B91),
              label: const Text('Subir Documento'),
              icon: const Icon(Icons.upload_file),
            )
          : null,
    );
  }
}
