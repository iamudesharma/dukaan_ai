import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/data/dukaan_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('voice upload sends raw M4A bytes through the multipart endpoint',
      () async {
    final bytes = Uint8List.fromList([0, 255, 1, 2, 3, 4]);
    final adapter = _RecordingAdapter((options) {
      return _json({
        'id': 'attachment-1',
        'kind': 'VOICE',
        'mime': 'audio/m4a',
        'size_bytes': bytes.length,
        'status': 'READY',
        'proposal': null,
      });
    });
    final repository = ApiDukaanRepository(_dio(adapter));

    final id = await repository.uploadVoiceRecording(
      businessId: 'business-1',
      bytes: bytes,
    );

    expect(id, 'attachment-1');
    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.uri.path, '/api/v1/assistant/attachments/upload/');
    final form = request.data as FormData;
    expect({
      for (final field in form.fields) field.key: field.value
    }, {
      'business_id': 'business-1',
      'kind': 'VOICE',
      'mime': 'audio/m4a',
      'size_bytes': '${bytes.length}',
    });
    final file = form.files.single.value;
    expect(file.filename, endsWith('.m4a'));
    expect(file.contentType?.mimeType, 'audio/m4a');
    final uploaded = await file
        .clone()
        .finalize()
        .fold<List<int>>([], (all, chunk) => all..addAll(chunk));
    expect(uploaded, bytes);
  });

  test('from-audio posts the attachment and polling stops at READY', () async {
    var getCalls = 0;
    final adapter = _RecordingAdapter((options) {
      if (options.method == 'POST') {
        expect(options.uri.path, '/api/v1/assistant/proposals/from-audio/');
        expect(options.data, {
          'attachment_id': 'attachment-1',
          'business_id': 'business-1',
          'location_id': 'location-1',
          'locale': 'hi-IN',
        });
        return _json(_proposal(
          status: 'DRAFT',
          content: '',
          questions: ['Your voice note is being transcribed.'],
        ));
      }
      getCalls++;
      return _json(getCalls == 1
          ? _proposal(
              status: 'DRAFT',
              content: '',
              questions: ['Your voice note is being transcribed.'],
            )
          : _proposal(status: 'READY', content: 'रमेश ने तीन शर्ट लिए'));
    });
    final repository = ApiDukaanRepository(_dio(adapter));

    final created = await repository.createProposalFromAudio(
      attachmentId: 'attachment-1',
      businessId: 'business-1',
      locationId: 'location-1',
      locale: 'hi-IN',
    );
    final completed = await repository.pollProposal(
      created.id,
      timeout: const Duration(seconds: 1),
      pollInterval: const Duration(milliseconds: 1),
    );

    expect(created.status, 'DRAFT');
    expect(getCalls, 2);
    expect(completed.status, 'READY');
    expect(completed.transcript, 'रमेश ने तीन शर्ट लिए');
  });

  test('polling stops on a terminal transcription blocker', () async {
    final adapter = _RecordingAdapter((_) => _json(_proposal(
          status: 'DRAFT',
          content: '',
          questions: [
            'Voice transcription failed. Please try sending it again.'
          ],
        )));
    final repository = ApiDukaanRepository(_dio(adapter));

    final proposal = await repository.pollProposal(
      'proposal-1',
      timeout: const Duration(seconds: 1),
      pollInterval: const Duration(milliseconds: 1),
    );

    expect(adapter.requests, hasLength(1));
    expect(proposal.blockingQuestions,
        ['Voice transcription failed. Please try sending it again.']);
  });

  test('polling has a bounded timeout and stops making requests', () async {
    final adapter = _RecordingAdapter((_) => _json(_proposal(
          status: 'DRAFT',
          content: '',
          questions: ['Your voice note is being transcribed.'],
        )));
    final repository = ApiDukaanRepository(_dio(adapter));

    await expectLater(
      repository.pollProposal(
        'proposal-1',
        timeout: const Duration(milliseconds: 20),
        pollInterval: const Duration(milliseconds: 5),
      ),
      throwsA(isA<VoiceTranscriptionException>()),
    );
    final callsAtTimeout = adapter.requests.length;
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(adapter.requests.length, callsAtTimeout);
  });

  test('empty and oversized voice uploads are rejected before HTTP', () async {
    final adapter = _RecordingAdapter((_) => _json(const {}));
    final repository = ApiDukaanRepository(_dio(adapter));

    await expectLater(
      repository
          .uploadVoiceRecording(businessId: 'business-1', bytes: const []),
      throwsArgumentError,
    );
    await expectLater(
      repository.uploadVoiceRecording(
        businessId: 'business-1',
        bytes: Uint8List(8 * 1024 * 1024 + 1),
      ),
      throwsArgumentError,
    );
    expect(adapter.requests, isEmpty);
  });
}

Dio _dio(HttpClientAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'http://example.test/api/v1/'))
      ..httpClientAdapter = adapter;

ResponseBody _json(Map<String, Object?> body) => ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

Map<String, Object?> _proposal({
  required String status,
  required String content,
  List<String> questions = const [],
}) =>
    {
      'id': 'proposal-1',
      'version': 1,
      'status': status,
      'command_type': status == 'READY' ? 'SALE' : 'UNSUPPORTED',
      'content': content,
      'preview': status == 'READY' ? 'Sale to Ramesh' : '',
      'warnings': [],
      'blocking_questions': questions,
      'payload': <String, Object?>{},
    };

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
