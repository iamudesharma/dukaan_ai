import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SessionStore {
  Future<String?> readAccessToken();
  Future<void> writeAccessToken(String token);
  Future<String?> readRefreshToken();
  Future<void> writeRefreshToken(String token);
  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'dukaan_access_token';
  static const _refreshKey = 'dukaan_refresh_token';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _accessKey, value: token);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _refreshKey, value: token);

  @override
  Future<void> clear() => _storage.deleteAll();
}

class MemorySessionStore implements SessionStore {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
  }

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<void> writeAccessToken(String token) async => _accessToken = token;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<void> writeRefreshToken(String token) async => _refreshToken = token;
}
