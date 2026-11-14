import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

/// Wraps Google ML Kit's document scanner UI flow (camera capture, edge
/// detection, crop, filter) and hands back the paths of the scanned pages.
class DocumentScannerService {
  DocumentScanner? _scanner;

  DocumentScanner _scannerFor(int pageLimit) {
    _scanner?.close();
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        mode: ScannerMode.filter,
        pageLimit: pageLimit,
        isGalleryImport: true,
      ),
    );
    _scanner = scanner;
    return scanner;
  }

  /// Launches the native scanning UI and returns the image paths of the
  /// pages the user scanned, or an empty list if they cancelled.
  Future<List<String>> scan({int pageLimit = 5}) async {
    final scanner = _scannerFor(pageLimit);
    final result = await scanner.scanDocument();
    return result.images ?? const [];
  }

  void dispose() {
    _scanner?.close();
    _scanner = null;
  }
}
