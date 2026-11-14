import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:whisper_cpp_flutter_plus/whisper_cpp_flutter_plus.dart';

import '../../models/transcription_job.dart';
import '../../models/whisper_options.dart';
import '../../services/audio_recorder_service.dart';
import '../../services/transcription_service.dart';
import 'widgets/job_card.dart';
import 'widgets/language_selector.dart';
import 'widgets/model_selector.dart';

class TranscribeScreen extends StatefulWidget {
  const TranscribeScreen({super.key});
  @override
  State<TranscribeScreen> createState() => _TranscribeScreenState();
}

class _TranscribeScreenState extends State<TranscribeScreen> {
  final _transcription = TranscriptionService();
  final _recorder = AudioRecorderService();

  bool _loading = true;
  bool _transcribing = false;
  double _downloadProgress = 0;
  String _statusMsg = 'Choix du modele...';

  WhisperModel _selectedModel = WhisperModel.tiny;
  TranscribeLanguage _selectedLang = TranscribeLanguage.french;

  final List<TranscriptionJob> _jobs = [];

  Timer? _recordingTimer;
  bool _isRecording = false;
  Duration _recordingElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initEngine(_selectedModel);
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recorder.dispose();
    _transcription.dispose();
    super.dispose();
  }

  // ────────── engine ──────────

  Future<void> _initEngine(WhisperModel model) async {
    setState(() {
      _loading = true;
      _statusMsg = 'Chargement du modele ${model.label}...';
      _downloadProgress = 0;
    });

    try {
      await _transcription.loadModel(
        model,
        onDownloadProgress: (fraction) {
          if (!mounted) return;
          setState(() => _downloadProgress = fraction);
        },
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _statusMsg = '${model.label} pret';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _statusMsg = 'Erreur: $e';
      });
    }
  }

  // ────────── pick files ──────────

  Future<void> _pickFiles() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: pickableAudioExtensions,
    );
    if (files.isEmpty) return;

    for (final f in files) {
      if (f.path == null) continue;
      final job = TranscriptionJob(
        name: f.name,
        path: f.path!,
        sizeBytes: f.lengthSync() ?? 0,
      );
      _jobs.add(job);
      _transcribeJob(job);
    }

    setState(() {});
  }

  Future<void> _transcribeJob(TranscriptionJob job) async {
    if (!_transcription.isReady) return;

    setState(() {
      _transcribing = true;
      job.status = JobStatus.running;
    });

    String? convertedPath;
    try {
      final Float32List pcm;
      if (job.pcm != null) {
        pcm = job.pcm!;
      } else {
        final ext = job.path!.split('.').last.toLowerCase();
        String wavPath;
        if (nativeAudioExtensions.contains(ext)) {
          wavPath = job.path!;
        } else {
          setState(() => job.status = JobStatus.converting);
          wavPath = convertedPath = await _transcription.convertToWav(job.path!);
          setState(() => job.status = JobStatus.running);
        }
        pcm = await _transcription.readWav(wavPath);
      }

      WhisperResult? result;
      await for (final p in _transcription.transcribeStream(
        pcm,
        language: _selectedLang,
        onDone: (r) => result = r,
      )) {
        if (!mounted) return;
        setState(() => job.progress = p);
      }

      if (!mounted) return;
      setState(() {
        job.result = result;
        job.status = JobStatus.done;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        job.status = JobStatus.error;
        job.errorMsg = e.toString();
      });
    } finally {
      if (convertedPath != null) {
        final f = File(convertedPath);
        if (f.existsSync()) await f.delete();
      }
      if (mounted) {
        final anyRunning = _jobs.any(
          (j) => j.status == JobStatus.running || j.status == JobStatus.converting,
        );
        setState(() => _transcribing = anyRunning);
      }
    }
  }

  // ────────── microphone ──────────

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final granted = await _recorder.requestPermission();
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acces au microphone refuse')),
      );
      return;
    }

    await _recorder.start();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recordingElapsed += const Duration(seconds: 1));
    });

    setState(() {
      _isRecording = true;
      _recordingElapsed = Duration.zero;
    });
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    final pcm = await _recorder.stop();

    if (!mounted) return;
    setState(() => _isRecording = false);

    if (pcm == null) return;

    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    final job = TranscriptionJob(
      name: 'Micro ${two(now.hour)}:${two(now.minute)}:${two(now.second)}',
      sizeBytes: pcm.lengthInBytes,
      pcm: pcm,
    );
    _jobs.add(job);
    setState(() {});
    _transcribeJob(job);
  }

  // ────────── UI ──────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ready = !_loading && _transcription.isReady;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcription'),
        actions: [
          if (ready) ...[
            IconButton(
              onPressed: (_transcribing || _isRecording) ? null : _pickFiles,
              icon: const Icon(Icons.audio_file),
              tooltip: 'Choisir des fichiers audio',
            ),
            IconButton(
              onPressed: _transcribing ? null : _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic),
              color: _isRecording ? cs.error : null,
              tooltip: _isRecording ? 'Arreter l\'enregistrement' : 'Enregistrer au micro',
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            ModelSelector(
              selected: _selectedModel,
              enabled: !_loading,
              onChanged: (m) {
                setState(() => _selectedModel = m);
                _initEngine(m);
              },
            ),
            const SizedBox(height: 8),
            LanguageSelector(
              selected: _selectedLang,
              onChanged: (l) => setState(() => _selectedLang = l),
            ),
            const SizedBox(height: 8),
            if (_loading && _downloadProgress > 0) ...[
              LinearProgressIndicator(value: _downloadProgress),
              const SizedBox(height: 4),
              Text('${(_downloadProgress * 100).toStringAsFixed(0)}%'),
            ],
            if (_loading && _downloadProgress == 0) const LinearProgressIndicator(),
            const SizedBox(height: 4),
            Text(_statusMsg, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 12),
            if (ready)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: (_transcribing || _isRecording) ? null : _pickFiles,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Choisir un fichier'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _transcribing ? null : _toggleRecording,
                      icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic),
                      label: Text(_isRecording ? _formatElapsed(_recordingElapsed) : 'Micro'),
                      style: _isRecording
                          ? FilledButton.styleFrom(
                              backgroundColor: cs.errorContainer,
                              foregroundColor: cs.onErrorContainer,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _jobs.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun fichier selectionne',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _jobs.length,
                      separatorBuilder: (_, value) => const SizedBox(height: 8),
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (_, i) => JobCard(job: _jobs[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatElapsed(Duration d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
  }
}
