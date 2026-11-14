import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/scan_page.dart';

class ScannedPageCard extends StatelessWidget {
  const ScannedPageCard({super.key, required this.page, required this.index});

  final ScanPage page;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(page.imagePath),
                width: 64,
                height: 84,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_icon, size: 16, color: _iconColor(cs)),
                      const SizedBox(width: 6),
                      Text('Page ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (page.status == OcrStatus.running) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 4),
                    Text(
                      'Reconnaissance du texte...',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                  if (page.status == OcrStatus.error)
                    Text(
                      page.errorMsg ?? 'Erreur OCR',
                      style: TextStyle(color: cs.error, fontSize: 13),
                    ),
                  if (page.status == OcrStatus.done)
                    (page.text == null || page.text!.isEmpty)
                        ? Text(
                            'Aucun texte detecte',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        : SelectableText(
                            page.text!,
                            style: const TextStyle(fontSize: 13.5, height: 1.4),
                          ),
                  if (page.status == OcrStatus.done && (page.text?.isNotEmpty ?? false))
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: page.text!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copie !'), duration: Duration(seconds: 1)),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copier'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (page.status) {
        OcrStatus.done => Icons.check_circle,
        OcrStatus.error => Icons.error,
        OcrStatus.running => Icons.hourglass_top,
        OcrStatus.pending => Icons.description_outlined,
      };

  Color _iconColor(ColorScheme cs) => switch (page.status) {
        OcrStatus.done => Colors.green,
        OcrStatus.error => cs.error,
        _ => cs.primary,
      };
}
