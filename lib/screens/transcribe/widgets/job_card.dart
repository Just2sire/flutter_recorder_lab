import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whisper_cpp_flutter_plus/whisper_cpp_flutter_plus.dart';

import '../../../models/transcription_job.dart';

class JobCard extends StatelessWidget {
  const JobCard({super.key, required this.job});
  final TranscriptionJob job;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _iconColor(cs).withValues(alpha: 0.15),
                  child: Icon(_icon, color: _iconColor(cs), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        job.status == JobStatus.converting ? 'Conversion audio...' : job.sizeLabel,
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (job.result != null)
                  Text(
                    '${job.result!.processingTime.inMilliseconds} ms',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
              ],
            ),
            if (job.status == JobStatus.converting) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            if (job.status == JobStatus.running) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: job.progress > 0 ? job.progress : null),
            ],
            if (job.status == JobStatus.error) ...[
              const SizedBox(height: 10),
              Text(
                job.errorMsg ?? 'Erreur inconnue',
                style: TextStyle(color: cs.error, fontSize: 13),
              ),
            ],
            if (job.result != null && job.result!.text.trim().isNotEmpty) ...[
              const Divider(),
              SelectableText(
                job.result!.text.trim(),
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: job.result!.toPlainText()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copie !'), duration: Duration(seconds: 1)),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copier'),
                ),
              ),
            ],
            if (job.result != null && job.result!.text.trim().isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Aucune parole detectee',
                  style: TextStyle(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (job.status) {
        JobStatus.done => Icons.check_circle,
        JobStatus.error => Icons.error,
        JobStatus.converting => Icons.sync,
        JobStatus.running => Icons.hourglass_top,
        JobStatus.pending => job.pcm != null ? Icons.mic : Icons.audiotrack,
      };

  Color _iconColor(ColorScheme cs) => switch (job.status) {
        JobStatus.done => Colors.green,
        JobStatus.error => cs.error,
        _ => cs.primary,
      };
}
