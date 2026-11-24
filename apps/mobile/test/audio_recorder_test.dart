import 'dart:io';
import 'dart:typed_data';

import 'package:dukaan_ai_mobile/data/audio_recorder.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';

void main() {
  late Directory directory;
  late _FakeCapture capture;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('dukaan-voice-test');
    capture = _FakeCapture();
  });

  tearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  RecordVoiceRecorder recorder() => RecordVoiceRecorder(
        capture: capture,
        temporaryDirectory: () async => directory,
      );

  test('records AAC M4A and deletes the temporary file after reading bytes',
      () async {
    final voiceRecorder = recorder();
    await voiceRecorder.start();

    expect(capture.config?.encoder, AudioEncoder.aacLc);
    expect(capture.config?.numChannels, 1);
    expect(capture.path, endsWith('.m4a'));
    final path = capture.path!;

    final recording = await voiceRecorder.stop();

    expect(recording?.bytes, [1, 2, 3, 4]);
    expect(recording?.mimeType, 'audio/m4a');
    expect(File(path).existsSync(), isFalse);
  });

  test('rejects empty and oversized files and removes them', () async {
    capture.bytes = Uint8List(0);
    final emptyRecorder = recorder();
    await emptyRecorder.start();
    await expectLater(
      emptyRecorder.stop(),
      throwsA(isA<VoiceRecordingException>().having(
        (error) => error.failure,
        'failure',
        VoiceRecordingFailure.empty,
      )),
    );
    expect(capture.path == null || !File(capture.path!).existsSync(), isTrue);

    capture.bytes = Uint8List(maxAttachmentBytes + 1);
    final largeRecorder = recorder();
    await largeRecorder.start();
    await expectLater(
      largeRecorder.stop(),
      throwsA(isA<VoiceRecordingException>().having(
        (error) => error.failure,
        'failure',
        VoiceRecordingFailure.tooLarge,
      )),
    );
    expect(capture.path == null || !File(capture.path!).existsSync(), isTrue);
  });

  test('missing microphone permission prevents recording', () async {
    capture.permission = false;

    await expectLater(
      recorder().start(),
      throwsA(isA<VoiceRecordingException>().having(
        (error) => error.failure,
        'failure',
        VoiceRecordingFailure.permissionDenied,
      )),
    );
    expect(capture.path, isNull);
  });

  test('cancel removes the active temporary file', () async {
    final voiceRecorder = recorder();
    await voiceRecorder.start();
    final path = capture.path!;

    await voiceRecorder.cancel();

    expect(capture.cancelCalls, 1);
    expect(File(path).existsSync(), isFalse);
  });
}

class _FakeCapture implements AudioCapture {
  bool permission = true;
  Uint8List bytes = Uint8List.fromList([1, 2, 3, 4]);
  RecordConfig? config;
  String? path;
  int cancelCalls = 0;

  @override
  Future<bool> hasPermission() async => permission;

  @override
  Future<void> start(RecordConfig config, {required String path}) async {
    this.config = config;
    this.path = path;
    File(path).writeAsBytesSync(bytes);
  }

  @override
  Future<String?> stop() async => path;

  @override
  Future<void> cancel() async {
    cancelCalls++;
    final activePath = path;
    path = null;
    if (activePath != null) {
      final file = File(activePath);
      if (file.existsSync()) file.deleteSync();
    }
  }

  @override
  Future<void> dispose() async {}
}
