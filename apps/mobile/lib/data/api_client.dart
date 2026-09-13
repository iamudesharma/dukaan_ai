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

  // A bare client for the refresh call so a failed refresh cannot recurse
  // through the interceptor below.
  final refreshClient = Dio(
    BaseOptions(
      baseUrl: AppConfig.normalizeBaseUrl(AppConfig.apiBaseUrl),
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
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
      onError: (error, handler) async {
        final request = error.requestOptions;
        final canRetry = error.response?.statusCode == 401 &&
            request.extra['auth_retried'] != true;
        final refresh = await sessionStore.readRefreshToken();
        if (!canRetry || refresh == null || refresh.isEmpty) {
          handler.next(error);
          return;
        }
        try {
          final response = await refreshClient.post<Map<String, dynamic>>(
            'auth/refresh/',
            data: {'refresh': refresh},
          );
          final access = response.data?['access'] as String?;
          if (access == null || access.isEmpty) {
            throw const FormatException('The refresh response did not include a token.');
          }
          await sessionStore.writeAccessToken(access);
          request.headers['Authorization'] = 'Bearer $access';
          request.extra['auth_retried'] = true;
          final retried = await dio.fetch<dynamic>(request);
          handler.resolve(retried);
        } catch (_) {
          // The refresh token is no longer usable; force a clean sign-in.
          await sessionStore.clear();
          handler.next(error);
        }
      },
    ),
  );
  return dio;
}
