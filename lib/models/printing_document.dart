import 'package:cloud_firestore/cloud_firestore.dart';

class PrintingDocument {
  final String documentId;
  final String fileName;
  final String fileExtension;
  final String fileData; // String en Base64
  final String uploaderId;
  final String uploaderName;
  final DateTime uploadedAt;
  final String status;
  final DateTime? markedAsPrintedAt;
  final String? markedAsPrintedBy;
  final List<String> downloadedByWorkers;

  PrintingDocument({
    required this.documentId,
    required this.fileName,
    required this.fileExtension,
    required this.fileData,
    required this.uploaderId,
    required this.uploaderName,
    required this.uploadedAt,
    this.status = 'pendiente',
    this.markedAsPrintedAt,
    this.markedAsPrintedBy,
    this.downloadedByWorkers = const [],
  });

  factory PrintingDocument.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PrintingDocument(
      documentId: doc.id,
      fileName: data['fileName'] ?? '',
      fileExtension: data['fileExtension'] ?? '',
      fileData: data['fileData'] ?? '',
      uploaderId: data['uploaderId'] ?? '',
      uploaderName: data['uploaderName'] ?? 'Sin nombre',
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pendiente',
      markedAsPrintedAt: data['markedAsPrintedAt'] != null
          ? (data['markedAsPrintedAt'] as Timestamp).toDate()
          : null,
      markedAsPrintedBy: data['markedAsPrintedBy'],
      downloadedByWorkers: List<String>.from(data['downloadedByWorkers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileExtension': fileExtension,
      'fileData': fileData,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'status': status,
      'markedAsPrintedAt': markedAsPrintedAt != null
          ? Timestamp.fromDate(markedAsPrintedAt!)
          : null,
      'markedAsPrintedBy': markedAsPrintedBy,
      'downloadedByWorkers': downloadedByWorkers,
    };
  }
}
