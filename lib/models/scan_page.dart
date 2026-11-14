enum OcrStatus { pending, running, done, error }

/// One page scanned via [DocumentScannerService] and processed through
/// [OcrService].
class ScanPage {
  ScanPage({required this.imagePath});

  final String imagePath;

  OcrStatus status = OcrStatus.pending;
  String? text;
  String? errorMsg;
}
