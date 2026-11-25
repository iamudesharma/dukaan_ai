import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/data/auth_api.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetches auth capabilities from the versioned endpoint', () async {
    final adapter = _RecordingAdapter({
      'password': true,
      'otp': true,
      'dev_otp': false,
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test/api/v1/'))
      ..httpClientAdapter = adapter;
    final api = AuthApi(MemorySessionStore(), dio: dio);

    final capabilities = await api.fetchCapabilities();

    expect(adapter.request?.method, 'GET');
    expect(adapter.request?.uri.path, '/api/v1/auth/capabilities/');
    expect(capabilities.password, isTrue);
    expect(capabilities.otp, isTrue);
    expect(capabilities.devOtp, isFalse);
  });

  test('capability flags fail closed unless they are boolean true', () async {
    final adapter = _RecordingAdapter({
      'password': true,
      'otp': 'true',
      'dev_otp': 1,
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://example.test/api/v1/'))
      ..httpClientAdapter = adapter;

    final capabilities =
        await AuthApi(MemorySessionStore(), dio: dio).fetchCapabilities();

    expect(capabilities.password, isTrue);
    expect(capabilities.otp, isFalse);
    expect(capabilities.devOtp, isFalse);
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.body);

  final Map<String, Object> body;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
