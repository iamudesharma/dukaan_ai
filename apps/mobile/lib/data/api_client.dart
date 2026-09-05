import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/core/config.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';

Dio createDio(SessionStore sessionStore) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.normalizeBaseUrl(AppConfig.apiBaseUrl),
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await sessionStore.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        } else if (AppConfig.devUserId.isNotEmpty) {
          options.headers['X-Dev-User-ID'] = AppConfig.devUserId;
        }
        options.headers['Accept-Language'] = options.extra['locale'] ?? 'en';
        handler.next(options);
      },
    ),
  );
  return dio;
}

