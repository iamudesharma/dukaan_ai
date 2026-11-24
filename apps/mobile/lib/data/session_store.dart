import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SessionStore {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> writeSession({required String access, required String refresh});

  /// A minimal identity cache lets the signed-in user review their own drafts
  /// during a cold start without connectivity. It is cleared with the session.
  Future<String?> readCachedUserId();
  Future<void> writeCachedUserId(String userId);
  Future<Map<String, dynamic>?> readCachedBootstrap();
  Future<void> writeCachedBootstrap(Map<String, dynamic> bootstrap);

  Future<void> clear();
}

class SecureSessionStore implements SessionStore {
  SecureSessionStore([FlutterSecureStorage? storage])
      : _storage =
            storage ?? const FlutterSecureStorage(mOptions: macOsOptions);

  static const _accessKey = 'dukaan_access_token';
  static const _refreshKey = 'dukaan_refresh_token';
  static const _userIdKey = 'dukaan_cached_user_id';
  static const _bootstrapKey = 'dukaan_cached_bootstrap';
  final FlutterSecureStorage _storage;

  /// macOS defaults to the data-protection keychain, which requires an
  /// `application-identifier` entitlement that only a provisioning profile
  /// provides. A locally signed macOS build has no profile, so every write
  /// fails and sign-in silently aborts after a successful login: the browser
  /// window shows a generic error while the API has already answered 200. The
  /// older file-based keychain works for both signed and profile-less builds,
  /// so select it explicitly. Other platforms ignore these options.
  static const macOsOptions = MacOsOptions(useDataProtectionKeyChain: false);

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<void> writeSession(
      {required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  @override
  Future<String?> readCachedUserId() => _storage.read(key: _userIdKey);

  @override
  Future<void> writeCachedUserId(String userId) =>
      _storage.write(key: _userIdKey, value: userId);

  @override
  Future<Map<String, dynamic>?> readCachedBootstrap() async {
    final value = await _storage.read(key: _bootstrapKey);
    if (value == null || value.isEmpty) return null;
    final decoded = jsonDecode(value);
    return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
  }

  @override
  Future<void> writeCachedBootstrap(Map<String, dynamic> bootstrap) =>
      _storage.write(key: _bootstrapKey, value: jsonEncode(bootstrap));

  @override
  Future<void> clear() => _storage.deleteAll();
}

class MemorySessionStore implements SessionStore {
  MemorySessionStore({String? access, String? refresh})
      : _access = access,
        _refresh = refresh;

  String? _access;
  String? _refresh;
  String? _cachedUserId;
  Map<String, dynamic>? _cachedBootstrap;

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
    _cachedUserId = null;
    _cachedBootstrap = null;
  }

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> writeSession(
      {required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
  }

  @override
  Future<String?> readCachedUserId() async => _cachedUserId;

  @override
  Future<void> writeCachedUserId(String userId) async {
    _cachedUserId = userId;
  }

  @override
  Future<Map<String, dynamic>?> readCachedBootstrap() async {
    final value = _cachedBootstrap;
    return value == null ? null : Map<String, dynamic>.from(value);
  }

  @override
  Future<void> writeCachedBootstrap(Map<String, dynamic> bootstrap) async {
    _cachedBootstrap = Map<String, dynamic>.from(bootstrap);
  }
}
