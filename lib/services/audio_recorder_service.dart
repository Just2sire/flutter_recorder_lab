import 'dart:async';
import 'dart:typed_data';

import 'package:whisper_cpp_flutter_plus/whisper_cpp_flutter_plus.dart';

/// Wraps [WhisperRecorder] to accumulate microphone chunks into a single
/// PCM buffer per recording session.
class AudioRecorderService {
  final WhisperRecorder _recorder = WhisperRecorder();
  StreamSubscription<RecordingChunk>? _sub;
  final List<Float32List> _chunks = [];

  bool get isRecording => _sub != null;

  Future<bool> requestPermission() => _recorder.requestPermission();

  Future<void> start() async {
    _chunks.clear();
    final stream = await _recorder.start();
    _sub = stream.listen((chunk) => _chunks.add(chunk.samples));
  }

  /// Stops recording and returns the accumulated PCM samples, or null if
  /// nothing was captured.
  Future<Float32List?> stop() async {
    await _recorder.stop();
    await _sub?.cancel();
    _sub = null;

    final totalLength = _chunks.fold<int>(0, (sum, c) => sum + c.length);
    if (totalLength == 0) {
      _chunks.clear();
      return null;
    }

    final pcm = Float32List(totalLength);
    var offset = 0;
    for (final chunk in _chunks) {
      pcm.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    _chunks.clear();
    return pcm;
  }

  Future<void> dispose() async {
    if (isRecording) await _recorder.stop();
    await _sub?.cancel();
    _sub = null;
  }
}
