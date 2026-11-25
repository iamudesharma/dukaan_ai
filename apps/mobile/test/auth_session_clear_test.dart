import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/data/auth_api.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('successful password change clears secure tokens after the response',
      () async {
    final store = MemorySessionStore(access: 'access', refresh: 'refresh');
    final adapter = _StatusAdapter(200, {'detail': 'Password updated.'});
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1/'))
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);

    await AuthApi(store, dio: dio).changePassword(
      oldPassword: 'old-password',
      newPassword: 'new-password',
    );

    expect(await store.readAccessToken(), isNull);
    expect(await store.readRefreshToken(), isNull);
    expect(adapter.request?.path, 'auth/password/change/');
  });

  test('failed password change keeps the local session', () async {
    final store = MemorySessionStore(access: 'access', refresh: 'refresh');
    final adapter = _StatusAdapter(400, {
      'detail': 'Current password is incorrect.',
    });
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1/'))
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);

    await expectLater(
      AuthApi(store, dio: dio).changePassword(
        oldPassword: 'wrong-password',
        newPassword: 'new-password',
      ),
      throwsA(isA<DioException>()),
    );

    expect(await store.readAccessToken(), 'access');
    expect(await store.readRefreshToken(), 'refresh');
  });

  test('successful password reset also clears any local session', () async {
    final store = MemorySessionStore(access: 'access', refresh: 'refresh');
    final adapter = _StatusAdapter(200, {'detail': 'Password has been reset.'});
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/api/v1/'))
      ..httpClientAdapter = adapter;
    addTearDown(dio.close);

    await AuthApi(store, dio: dio).confirmPasswordReset(
      phone: '+919876543210',
      otp: '123456',
      newPassword: 'new-password',
    );

    expect(await store.readAccessToken(), isNull);
    expect(await store.readRefreshToken(), isNull);
    expect(adapter.request?.path, 'auth/password/reset/confirm/');
  });
}

class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.statusCode, this.body);

  final int statusCode;
  final Map<String, dynamic> body;
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
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
