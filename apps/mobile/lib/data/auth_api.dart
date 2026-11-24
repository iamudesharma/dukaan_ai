import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/core/config.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';

class AuthApi {
  AuthApi(this._sessionStore, {Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.normalizeBaseUrl(AppConfig.apiBaseUrl),
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 20),
                contentType: Headers.jsonContentType,
                responseType: ResponseType.json,
              ),
            );

  final SessionStore _sessionStore;
  final Dio _dio;

  String _normalize(String phone) => phone.replaceAll(RegExp(r'[\s()-]'), '');

  Future<AuthCapabilities> fetchCapabilities() async {
    final response = await _dio.get<Object>('auth/capabilities/');
    final data = response.data;
    if (data is! Map) {
      throw StateError('Invalid authentication capabilities response.');
    }
    return AuthCapabilities.fromJson(Map<String, dynamic>.from(data));
  }

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
        if (displayName != null && displayName.isNotEmpty)
          'display_name': displayName,
      },
    );
    return _storeTokens(response.data as Map<String, dynamic>);
  }

  Future<AuthTokens> login({
    required String phone,
    required String password,
  }) async {
    final response = await _dio.post<Object>(
      'auth/login/',
      data: {'phone': _normalize(phone), 'password': password},
    );
    return _storeTokens(response.data as Map<String, dynamic>);
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
    return _storeTokens(response.data as Map<String, dynamic>);
  }

  Future<String?> refreshToken(String refresh) async {
    final response = await _dio.post<Object>(
      'auth/refresh/',
      data: {'refresh': refresh},
    );
    final data = response.data as Map<String, dynamic>;
    final access = data['access'] as String?;
    if (access != null) {
      await _sessionStore.writeSession(access: access, refresh: refresh);
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
    // PasswordChangeView revokes the account's token version. Keep no stale
    // credentials on this device after the server confirms success.
    await _sessionStore.clear();
  }

  Future<String?> requestPasswordReset({required String phone}) async {
    final response = await _dio.post<Object>(
      'auth/password/reset/',
      data: {'phone': _normalize(phone)},
    );
    final data = response.data as Map<String, dynamic>;
    return data['dev_otp'] as String?;
  }

  Future<void> confirmPasswordReset({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    await _dio.post<Object>(
      'auth/password/reset/confirm/',
      data: {
        'phone': _normalize(phone),
        'otp': otp,
        'new_password': newPassword,
      },
    );
    // PasswordResetConfirmView also revokes every existing token.
    await _sessionStore.clear();
  }

  Future<AuthTokens> _storeTokens(Map<String, dynamic> data) async {
    final tokens = AuthTokens.fromJson(data);
    await _sessionStore.writeSession(
        access: tokens.access, refresh: tokens.refresh);
    return tokens;
  }
}

class AuthCapabilities {
  const AuthCapabilities({
    required this.password,
    required this.otp,
    required this.devOtp,
  });

  final bool password;
  final bool otp;
  final bool devOtp;

  factory AuthCapabilities.fromJson(Map<String, dynamic> json) =>
      AuthCapabilities(
        password: json['password'] == true,
        otp: json['otp'] == true,
        devOtp: json['dev_otp'] == true,
      );
}

class AuthTokens {
  AuthTokens(
      {required this.access,
      required this.refresh,
      required this.onboardingRequired});

  final String access;
  final String refresh;
  final bool onboardingRequired;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        access: json['access'] as String,
        refresh: json['refresh'] as String,
        onboardingRequired: json['onboarding_required'] as bool? ?? false,
      );
}
