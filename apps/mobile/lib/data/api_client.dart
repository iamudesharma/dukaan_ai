import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/core/config.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';

/// A token that was rejected even after one refresh attempt.
class SessionExpiredException implements Exception {
  const SessionExpiredException();
}

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
        }
        options.headers['Accept-Language'] = options.extra['locale'] ?? 'en';
        handler.next(options);
      },
      onError: (error, handler) async {
        final isAuthFailure = error.response?.statusCode == 401;
        final alreadyRetried = error.requestOptions.extra['retried'] == true;
        final refreshToken = await sessionStore.readRefreshToken();
        if (isAuthFailure && !alreadyRetried && refreshToken != null) {
          final access = await _refreshAccessToken(refreshToken);
          if (access == null) {
            // The refresh token is gone or rejected: the session is over.
            await sessionStore.clear();
            handler.next(DioException(
              requestOptions: error.requestOptions,
              error: const SessionExpiredException(),
              type: DioExceptionType.badResponse,
              response: error.response,
            ));
            return;
          }
          // The API keeps the same refresh token, so only the access token moves.
          await sessionStore.writeSession(
              access: access, refresh: refreshToken);
          final options = error.requestOptions;
          options.extra['retried'] = true;
          options.headers['Authorization'] = 'Bearer $access';
          try {
            handler.resolve(await dio.fetch<Object>(options));
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
          return;
        }
        // Patchy-4G retry for idempotent requests only (reads, plus proposal
        // confirmation whose key replays instead of double-posting). Interpret
        // and other writes are excluded: repeating them would create
        // duplicate proposals or documents.
        final options = error.requestOptions;
        final attempt = (options.extra['transientRetries'] as int?) ?? 0;
        if (attempt < 2 && _isIdempotent(options) && _isTransient(error)) {
          options.extra['transientRetries'] = attempt + 1;
          await Future<void>.delayed(
              Duration(milliseconds: 300 * (1 << attempt)));
          try {
            handler.resolve(await dio.fetch<Object>(options));
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
          return;
        }
        handler.next(error);
      },
    ),
  );
  return dio;
}

/// Requests safe to retry: reads, plus proposal confirmation whose
/// idempotency key is deterministic (`proposal:{id}:v{version}`), so a
/// retried confirm replays instead of double-posting.
bool _isIdempotent(RequestOptions options) {
  if (options.method.toUpperCase() == 'GET') return true;
  return options.method.toUpperCase() == 'POST' &&
      options.path.contains('/confirm/');
}

/// Failures worth retrying on flaky networks: timeouts, dropped
/// connections, rate limiting, and server errors.
bool _isTransient(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      return true;
    case DioExceptionType.badResponse:
      final status = error.response?.statusCode ?? 0;
      return status == 429 || status >= 500;
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return false;
  }
}

/// Exchanges the refresh token for a new access token, bypassing the
/// interceptor so a rejected refresh cannot loop.
Future<String?> _refreshAccessToken(String refreshToken) async {
  final bare = Dio(
    BaseOptions(
      baseUrl: AppConfig.normalizeBaseUrl(AppConfig.apiBaseUrl),
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );
  try {
    final response = await bare
        .post<Object>('auth/refresh/', data: {'refresh': refreshToken});
    final data = response.data;
    if (data is Map && data['access'] is String) {
      return data['access'] as String;
    }
    return null;
  } on DioException {
    return null;
  }
}
