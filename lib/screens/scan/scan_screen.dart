import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/scan_page.dart';
import '../../services/document_scanner_service.dart';
import '../../services/ocr_service.dart';
import 'widgets/scanned_page_card.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _scanner = DocumentScannerService();
  final _ocr = OcrService();

  final List<ScanPage> _pages = [];
  bool _scanning = false;
  String? _modelError;

  @override
  void initState() {
    super.initState();
    _ocr.ensureModelLoaded().catchError((Object e) {
      if (!mounted) return;
      setState(() => _modelError = e.toString());
    });
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _scanDocument() async {
    setState(() => _scanning = true);
    try {
      final imagePaths = await _scanner.scan();
      final newPages = imagePaths.map((p) => ScanPage(imagePath: p)).toList();
      setState(() => _pages.insertAll(0, newPages));
      for (final page in newPages) {
        unawaited(_runOcr(page));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan annule ou echoue: $e')),
      );
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _runOcr(ScanPage page) async {
    setState(() => page.status = OcrStatus.running);
    try {
      final text = await _ocr.recognizeText(page.imagePath);
      if (!mounted) return;
      setState(() {
        page.text = text;
        page.status = OcrStatus.done;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        page.errorMsg = e.toString();
        page.status = OcrStatus.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Scanner & OCR')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            if (_modelError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Modele OCR indisponible: $_modelError',
                  style: TextStyle(color: cs.error, fontSize: 12),
                ),
              ),
            FilledButton.icon(
              onPressed: _scanning ? null : _scanDocument,
              icon: _scanning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.document_scanner_outlined),
              label:
                  Text(_scanning ? 'Scan en cours...' : 'Scanner un document'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _pages.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun document scanne',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _pages.length,
                      separatorBuilder: (_, value) => const SizedBox(height: 8),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (_, i) =>
                          ScannedPageCard(page: _pages[i], index: i),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
