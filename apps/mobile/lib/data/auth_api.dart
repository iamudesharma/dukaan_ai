import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/core/config.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';

class AuthApi {
  AuthApi(this._sessionStore);

  final SessionStore _sessionStore;
  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.normalizeBaseUrl(AppConfig.apiBaseUrl),
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );

  String _normalize(String phone) => phone.replaceAll(RegExp(r'[\s()-]'), '');

  Future<AuthTokens> signup({
    required String phone,
    required String password,
    String? displayName,
  }) async {
    final response = await _dio.post<Object>(
      'auth/signup/',
      data: {
        'phone': _normalize(phone),
        'password': password,
        if (displayName != null && displayName.isNotEmpty) 'display_name': displayName,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final tokens = AuthTokens.fromJson(data);
    await _sessionStore.writeAccessToken(tokens.access);
    return tokens;
  }

  Future<AuthTokens> login({
    required String phone,
    required String password,
  }) async {
    final response = await _dio.post<Object>(
      'auth/login/',
      data: {'phone': _normalize(phone), 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    final tokens = AuthTokens.fromJson(data);
    await _sessionStore.writeAccessToken(tokens.access);
    return tokens;
  }

  Future<String?> sendOtp({required String phone}) async {
    final response = await _dio.post<Object>(
      'auth/otp/send/',
      data: {'phone': _normalize(phone)},
    );
    final data = response.data as Map<String, dynamic>;
    return data['dev_otp'] as String?;
  }

  Future<AuthTokens> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _dio.post<Object>(
      'auth/otp/verify/',
      data: {'phone': _normalize(phone), 'otp': otp},
    );
    final data = response.data as Map<String, dynamic>;
    final tokens = AuthTokens.fromJson(data);
    await _sessionStore.writeAccessToken(tokens.access);
    return tokens;
  }

  Future<String?> refreshToken(String refresh) async {
    final response = await _dio.post<Object>(
      'auth/refresh/',
      data: {'refresh': refresh},
    );
    final data = response.data as Map<String, dynamic>;
    final access = data['access'] as String?;
    if (access != null) {
      await _sessionStore.writeAccessToken(access);
    }
    return access;
  }

  Future<void> logout({String? refresh}) async {
    final token = await _sessionStore.readAccessToken();
    await _dio.post<Object>(
      'auth/logout/',
      data: {if (refresh != null) 'refresh': refresh},
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
    await _sessionStore.clear();
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final token = await _sessionStore.readAccessToken();
    await _dio.post<Object>(
      'auth/password/change/',
      data: {'old_password': oldPassword, 'new_password': newPassword},
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
  }
}

class AuthTokens {
  AuthTokens({required this.access, required this.refresh});

  final String access;
  final String refresh;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        access: json['access'] as String,
        refresh: json['refresh'] as String,
      );
}
