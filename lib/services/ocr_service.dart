import 'dart:io';

import 'package:fast_paddle_ocr/ocr.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

/// Bundled PP-OCRv5 (mobile, NCNN) model files shipped as Flutter assets.
const _modelAssets = [
  'assets/ocr_models/PP_OCRv5_mobile_det.ncnn.param',
  'assets/ocr_models/PP_OCRv5_mobile_det.ncnn.bin',
  'assets/ocr_models/PP_OCRv5_mobile_rec.ncnn.param',
  'assets/ocr_models/PP_OCRv5_mobile_rec.ncnn.bin',
];

/// Wraps the offline `fast_paddle_ocr` (PaddleOCR + NCNN) plugin: copies the
/// bundled models to local storage on first use, loads them, and runs OCR
/// on already-captured images.
class OcrService {
  final Ocr _ocr = Ocr();
  bool _loaded = false;

  Future<void> ensureModelLoaded() async {
    if (_loaded) return;

    final modelsDir = Directory('${(await getApplicationSupportDirectory()).path}/ocr_models');
    await modelsDir.create(recursive: true);

    final paths = <String>[];
    for (final asset in _modelAssets) {
      final file = File('${modelsDir.path}/${asset.split('/').last}');
      if (!await file.exists()) {
        final bytes = await rootBundle.load(asset);
        await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      }
      paths.add(file.path);
    }

    final ok = await _ocr.loadModel(
      detParam: paths[0],
      detModel: paths[1],
      recParam: paths[2],
      recModel: paths[3],
    );
    if (!ok) throw StateError('Echec du chargement du modele OCR');
    _loaded = true;
  }

  /// Runs OCR on a still image and returns the recognized text (may be
  /// empty if nothing was detected).
  Future<String> recognizeText(String imagePath) async {
    await ensureModelLoaded();
    final text = await _ocr.ocrFromImage(imagePath);
    return text?.trim() ?? '';
  }
}
