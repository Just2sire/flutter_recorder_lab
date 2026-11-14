import 'dart:typed_data';

import 'package:whisper_cpp_flutter_plus/whisper_cpp_flutter_plus.dart';

enum JobStatus { pending, converting, running, done, error }

class TranscriptionJob {
  TranscriptionJob({
    required this.name,
    required this.sizeBytes,
    this.path,
    this.pcm,
  }) : assert(path != null || pcm != null);

  final String name;
  final int sizeBytes;

  /// Source file path, for jobs created from the file picker. Null for
  /// microphone recordings, which already carry decoded [pcm].
  final String? path;

  /// Pre-decoded mono 16 kHz PCM, for jobs recorded from the microphone.
  final Float32List? pcm;

  JobStatus status = JobStatus.pending;
  double progress = 0;
  WhisperResult? result;
  String? errorMsg;

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes o';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} Ko';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }
}
