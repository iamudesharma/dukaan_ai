import 'dart:io';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

@immutable
class RecordedVoice {
  const RecordedVoice({required this.bytes, this.mimeType = voiceMimeType});

  final Uint8List bytes;
  final String mimeType;

  int get sizeBytes => bytes.length;
}

enum VoiceRecordingFailure { permissionDenied, tooLarge, empty, failed }

class VoiceRecordingException implements Exception {
  const VoiceRecordingException(this.failure);

  final VoiceRecordingFailure failure;

  @override
  String toString() => failure.name;
}

abstract interface class VoiceRecorder {
  Future<void> start();
  Future<RecordedVoice?> stop();
  Future<void> cancel();
  Future<void> dispose();
}

abstract interface class AudioCapture {
  Future<bool> hasPermission();
  Future<void> start(RecordConfig config, {required String path});
  Future<String?> stop();
  Future<void> cancel();
  Future<void> dispose();
}

class DeviceAudioCapture implements AudioCapture {
  DeviceAudioCapture(AudioRecorder recorder) : _recorder = recorder;

  final AudioRecorder _recorder;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<void> start(RecordConfig config, {required String path}) =>
      _recorder.start(config, path: path);

  @override
  Future<String?> stop() => _recorder.stop();

  @override
  Future<void> cancel() => _recorder.cancel();

  @override
  Future<void> dispose() => _recorder.dispose();
}

/// Records AAC-LC in an M4A container. The temporary file is read only after
/// capture stops and is always deleted before the bytes leave this class.
class RecordVoiceRecorder implements VoiceRecorder {
  RecordVoiceRecorder({
    AudioCapture? capture,
    Future<Directory> Function()? temporaryDirectory,
  })  : _capture = capture ?? DeviceAudioCapture(AudioRecorder()),
        _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final AudioCapture _capture;
  final Future<Directory> Function() _temporaryDirectory;
  String? _activePath;

  @override
  Future<void> start() async {
    if (_activePath != null) {
      throw const VoiceRecordingException(VoiceRecordingFailure.failed);
    }
    if (!await _capture.hasPermission()) {
      throw const VoiceRecordingException(
          VoiceRecordingFailure.permissionDenied);
    }
    final directory = await _temporaryDirectory();
    final path =
        '${directory.path}/dukaan-voice-${DateTime.now().microsecondsSinceEpoch}.m4a';
    try {
      await _capture.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: path,
      );
      _activePath = path;
    } on Object {
      await _delete(path);
      rethrow;
    }
  }

  @override
  Future<RecordedVoice?> stop() async {
    final path = _activePath;
    _activePath = null;
    String? outputPath;
    try {
      outputPath = await _capture.stop() ?? path;
      if (outputPath == null) return null;
      final file = File(outputPath);
      if (!await file.exists()) {
        throw const VoiceRecordingException(VoiceRecordingFailure.failed);
      }
      final size = await file.length();
      if (size == 0) {
        throw const VoiceRecordingException(VoiceRecordingFailure.empty);
      }
      if (size > maxAttachmentBytes) {
        throw const VoiceRecordingException(VoiceRecordingFailure.tooLarge);
      }
      return RecordedVoice(bytes: await file.readAsBytes());
    } finally {
      final cleanupPath = outputPath ?? path;
      if (cleanupPath != null) await _delete(cleanupPath);
    }
  }

  @override
  Future<void> cancel() async {
    final path = _activePath;
    _activePath = null;
    try {
      await _capture.cancel();
    } finally {
      if (path != null) await _delete(path);
    }
  }

  @override
  Future<void> dispose() async {
    await cancel();
    await _capture.dispose();
  }

  Future<void> _delete(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on Object {
      // Cache cleanup must never hide the recording/upload result.
    }
  }
}
