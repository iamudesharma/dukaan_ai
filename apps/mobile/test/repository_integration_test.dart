import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/data/dukaan_repository.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cashier entry loading requests sales and receipts only', () async {
    final adapter = _RecordingAdapter();
    final dio = _dio(adapter);
    final repository = ApiDukaanRepository(dio);

    await repository.fetchEntries('location-1', role: BusinessRole.cashier);

    final paths = adapter.requests.map((request) => request.path).toSet();
    expect(paths, {'businesses/', 'sales/', 'payments/'});
    expect(paths, isNot(contains('reports/dashboard/')));
    expect(paths, isNot(contains('purchases/')));
    expect(paths, isNot(contains('expenses/')));
    expect(paths, isNot(contains('transfers/')));
  });

  test('owner and manager entry loading keep all existing collections',
      () async {
    for (final role in [BusinessRole.owner, BusinessRole.manager]) {
      final adapter = _RecordingAdapter();
      final dio = _dio(adapter);
      final repository = ApiDukaanRepository(dio);

      await repository.fetchEntries('location-1', role: role);

      final paths = adapter.requests.map((request) => request.path).toSet();
      expect(paths, {
        'businesses/',
        'sales/',
        'purchases/',
        'expenses/',
        'payments/',
      });
    }
  });

  test('image upload sends raw bytes and from-image starts OCR review',
      () async {
    final adapter = _RecordingAdapter();
    final dio = _dio(adapter);
    final repository = ApiDukaanRepository(dio);

    final attachmentId = await repository.uploadImageAttachment(
      businessId: 'business-1',
      mime: 'application/pdf',
      bytes: [1, 2, 3, 4],
    );
    expect(attachmentId, 'attachment-1');
    final upload = adapter.requests.single;
    expect(upload.path, 'assistant/attachments/upload/');
    final form = upload.data! as FormData;
    expect(
        form.fields.singleWhere((entry) => entry.key == 'kind').value, 'IMAGE');
    expect(form.fields.singleWhere((entry) => entry.key == 'mime').value,
        'application/pdf');
    expect(form.fields.singleWhere((entry) => entry.key == 'size_bytes').value,
        '4');
    final file = form.files.single.value;
    expect(file.contentType?.mimeType, 'application/pdf');
    expect(adapter.uploadedBody, containsAllInOrder([1, 2, 3, 4]));

    final proposal = await repository.createProposalFromImage(
      attachmentId: attachmentId,
      businessId: 'business-1',
      locationId: 'location-1',
      locale: 'en-IN',
    );
    expect(proposal.id, 'proposal-1');
    expect(proposal.canConfirm, isFalse);
    expect(adapter.requests.last.path, 'assistant/proposals/from-image/');
    expect(adapter.requests.last.data, {
      'attachment_id': 'attachment-1',
      'business_id': 'business-1',
      'location_id': 'location-1',
      'locale': 'en-IN',
    });
  });

  test('image upload rejects unsupported and oversized documents before I/O',
      () async {
    final adapter = _RecordingAdapter();
    final repository = ApiDukaanRepository(_dio(adapter));

    await expectLater(
      repository.uploadImageAttachment(
        businessId: 'business-1',
        mime: 'text/plain',
        bytes: [1],
      ),
      throwsArgumentError,
    );
    await expectLater(
      repository.uploadImageAttachment(
        businessId: 'business-1',
        mime: 'image/png',
        bytes: List<int>.filled(maxAttachmentBytes + 1, 1),
      ),
      throwsArgumentError,
    );
    expect(adapter.requests, isEmpty);
  });
}

Dio _dio(HttpClientAdapter adapter) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.example.test/api/v1/',
      responseType: ResponseType.json,
    ),
  )..httpClientAdapter = adapter;
  addTearDown(dio.close);
  return dio;
}

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  Uint8List? uploadedBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (requestStream != null) {
      final chunks = await requestStream.toList();
      uploadedBody =
          Uint8List.fromList(chunks.expand((chunk) => chunk).toList());
    }
    final Object data;
    if (options.path == 'businesses/') {
      data = {
        'results': [
          {'id': 'business-1'},
        ],
      };
    } else if (options.path == 'assistant/attachments/upload/') {
      data = {'id': 'attachment-1', 'status': 'READY'};
    } else if (options.path == 'assistant/proposals/from-image/') {
      data = {
        'id': 'proposal-1',
        'version': 1,
        'status': 'DRAFT',
        'command_type': 'SALE',
        'content': '',
        'blocking_questions': ['Reading document'],
        'payload': <String, dynamic>{},
      };
    } else {
      data = {'results': <dynamic>[]};
    }
    return ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
