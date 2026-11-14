import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whisper_cpp_flutter_plus/whisper_cpp_flutter_plus.dart';

import '../models/whisper_options.dart';

/// Extensions that whisper.cpp can decode without an ffmpeg pass first.
const nativeAudioExtensions = {'wav'};

/// Extensions offered in the file picker; anything outside
/// [nativeAudioExtensions] is transcoded to WAV via ffmpeg before
/// transcription.
const pickableAudioExtensions = [
  'wav',
  'mp3',
  'm4a',
  'aac',
  'ogg',
  'opus',
  'flac',
  'wma',
  'webm',
  'mp4',
];

/// Wraps whisper.cpp model management, engine lifecycle and ffmpeg-based
/// audio conversion for the transcription feature.
class TranscriptionService {
  WhisperEngine? _engine;
  bool get isReady => _engine != null;

  /// Loads (downloading if needed) [model] and swaps it in as the active
  /// engine. [onDownloadProgress] reports 0..1 while the model is fetched.
  Future<void> loadModel(
    WhisperModel model, {
    void Function(double fraction)? onDownloadProgress,
  }) async {
    final mgr = WhisperModelManager();
    try {
      var cached = await mgr.findCatalogModel(model.descriptor);

      if (cached == null) {
        await for (final p in mgr.downloadCatalogModel(model.descriptor)) {
          onDownloadProgress?.call(p.fraction ?? 0);
        }
        cached = await mgr.findCatalogModel(model.descriptor);
      }

      if (cached == null) throw StateError('Model not installed');

      final engine = await WhisperEngine.load(cached.path);
      _engine?.dispose();
      _engine = engine;
    } finally {
      mgr.close();
    }
  }

  /// Converts [inputPath] to mono 16 kHz PCM WAV via ffmpeg, in the temp dir.
  Future<String> convertToWav(String inputPath) async {
    final tempDir = await getTemporaryDirectory();
    final outputPath =
        '${tempDir.path}/convert_${DateTime.now().microsecondsSinceEpoch}.wav';

    final session = await FFmpegKit.execute(
      '-y -i "$inputPath" -ar 16000 -ac 1 -c:a pcm_s16le "$outputPath"',
    );
    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getFailStackTrace() ?? await session.getOutput();
      throw Exception('Conversion audio (ffmpeg) echouee: ${logs ?? "erreur inconnue"}');
    }
    return outputPath;
  }

  /// Reads a WAV file already at 16 kHz mono into PCM samples.
  Future<Float32List> readWav(String path) => WhisperAudio.readWav(File(path));

  /// Runs transcription over decoded [pcm] samples, reporting 0..1 progress.
  Stream<double> transcribeStream(
    Float32List pcm, {
    required TranscribeLanguage language,
    required void Function(WhisperResult result) onDone,
  }) {
    final engine = _engine;
    if (engine == null) {
      throw StateError('No whisper engine loaded');
    }

    final controller = StreamController<double>();
    final task = engine.transcribe(
      pcm,
      options: TranscribeOptions(language: language.code, tokenTimestamps: true),
    );

    task.progress.listen((p) => controller.add(p / 100));
    task.result.then((result) {
      onDone(result);
      controller.close();
    }).catchError((Object e, StackTrace st) {
      controller.addError(e, st);
      controller.close();
    });

    return controller.stream;
  }

  void dispose() {
    _engine?.dispose();
    _engine = null;
  }
}
