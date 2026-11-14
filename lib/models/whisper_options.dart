import 'package:whisper_cpp_flutter_plus/whisper_cpp_flutter_plus.dart';

/// Revision pinned by whisper_cpp_flutter_plus's own catalog; reused here so
/// the small/medium descriptors resolve against the same immutable commit.
const _whisperRevision = '5359861c739e955e79d9a303bcbc70fb988958b1';

/// Small multilingual Whisper model. Not in the package's built-in catalog,
/// so it's declared here with the checksum verified against Hugging Face.
const _small = WhisperModelDescriptor(
  id: 'small',
  fileName: 'ggml-small.bin',
  url: 'https://huggingface.co/ggerganov/whisper.cpp/resolve/'
      '$_whisperRevision/ggml-small.bin',
  sha256: '1be3a9b2063867b937e64e2ec7483364a79917e157fa98c5d94b5c1fffea987b',
  approximateBytes: 487601967,
  languageScope: WhisperModelLanguageScope.multilingual,
  purpose: WhisperModelPurpose.transcription,
);

/// Medium multilingual Whisper model, declared the same way as [_small].
const _medium = WhisperModelDescriptor(
  id: 'medium',
  fileName: 'ggml-medium.bin',
  url: 'https://huggingface.co/ggerganov/whisper.cpp/resolve/'
      '$_whisperRevision/ggml-medium.bin',
  sha256: '6c14d5adee5f86394037b4e4e8b59f1673b6cee10e3cf0b11bbdbee79c156208',
  approximateBytes: 1533763059,
  languageScope: WhisperModelLanguageScope.multilingual,
  purpose: WhisperModelPurpose.transcription,
);

enum WhisperModel {
  tiny('Tiny', '75 Mo', WhisperModelCatalog.tiny),
  tinyEnglish('Tiny EN', '75 Mo', WhisperModelCatalog.tinyEnglish),
  base('Base', '142 Mo', WhisperModelCatalog.base),
  baseEnglish('Base EN', '142 Mo', WhisperModelCatalog.baseEnglish),
  small('Small', '465 Mo', _small),
  medium('Medium', '1.4 Go', _medium);

  const WhisperModel(this.label, this.size, this.descriptor);
  final String label;
  final String size;
  final WhisperModelDescriptor descriptor;
}

enum TranscribeLanguage {
  auto('Auto-detect', 'auto'),
  french('Francais', 'fr'),
  english('English', 'en');

  const TranscribeLanguage(this.label, this.code);
  final String label;
  final String code;
}
