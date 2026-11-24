import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/data/api_client.dart';
import 'package:dukaan_ai_mobile/data/auth_api.dart';
import 'package:dukaan_ai_mobile/data/dukaan_repository.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the app belongs right now: signed out, signed in without a shop, or
/// signed in with a working workspace.
enum AuthStage { loading, signedOut, needsBusiness, ready }

/// A human-readable failure for the sign-in and onboarding forms.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

String describeDioError(Object error, String fallback) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final detail = data['error'] is Map
          ? (data['error'] as Map)['detail']
          : data['detail'];
      if (detail is Map && detail['message'] != null) {
        return detail['message'].toString();
      }
      if (detail is String) return detail;
      if (detail is Map) {
        final first = detail.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        if (first is String) return first;
      }
    }
    if (error.error is SessionExpiredException) {
      return 'Your session expired. Please sign in again.';
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return 'The server could not be reached. Check your connection and try again.';
    }
  }
  return fallback;
}

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(sessionStoreProvider)),
);

final authCapabilitiesProvider = FutureProvider<AuthCapabilities>(
  (ref) => ref.watch(authApiProvider).fetchCapabilities(),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthStage>(
  (ref) => AuthController(ref),
);

class AuthController extends StateNotifier<AuthStage> {
  AuthController(this._ref) : super(AuthStage.loading) {
    refreshStage();
  }

  final Ref _ref;

  AuthApi get _api => _ref.read(authApiProvider);
  DukaanRepository get _repository => _ref.read(repositoryProvider);

  /// Re-derives the stage from the stored token and the API.
  Future<void> refreshStage() async {
    final store = _ref.read(sessionStoreProvider);
    final token = await store.readAccessToken();
    if (token == null || token.isEmpty) {
      state = AuthStage.signedOut;
      return;
    }
    try {
      await _repository.fetchBootstrap();
      invalidateSessionScopedProviders(_ref);
      state = AuthStage.ready;
    } on DioException catch (error) {
      final data = error.response?.data;
      final detail =
          data is Map && data['error'] is Map ? data['error']['detail'] : null;
      final code = detail is Map ? detail['code'] : null;
      if (code == 'onboarding_required' || error.response?.statusCode == 404) {
        state = AuthStage.needsBusiness;
      } else if (error.response?.statusCode == 401) {
        await store.clear();
        invalidateSessionScopedProviders(_ref);
        state = AuthStage.signedOut;
      } else {
        // Reachability problems must not throw the user out of the app.
        state = AuthStage.ready;
      }
    } on Object {
      state = AuthStage.needsBusiness;
    }
  }

  Future<void> signIn({required String phone, required String password}) async {
    await _whenUnauthenticated(
        () => _api.login(phone: phone, password: password));
  }

  Future<void> signInWithOtp(
      {required String phone, required String otp}) async {
    await _whenUnauthenticated(() => _api.verifyOtp(phone: phone, otp: otp));
  }

  Future<String?> sendOtp({required String phone}) =>
      _guarded(() => _api.sendOtp(phone: phone));

  Future<String?> requestPasswordReset({required String phone}) =>
      _guarded(() => _api.requestPasswordReset(phone: phone));

  Future<void> confirmPasswordReset({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    await _guarded(
      () => _api.confirmPasswordReset(
          phone: phone, otp: otp, newPassword: newPassword),
    );
    await _clearSessionAndReturnToSignIn();
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _guarded(
      () => _api.changePassword(
          oldPassword: oldPassword, newPassword: newPassword),
    );
    await _clearSessionAndReturnToSignIn();
  }

  Future<void> revokeAllSessions({required String currentPassword}) async {
    await _guarded(
      () => _repository.revokeAllSessions(currentPassword: currentPassword),
    );
    await _clearSessionAndReturnToSignIn();
  }

  Future<void> _clearSessionAndReturnToSignIn() async {
    final store = _ref.read(sessionStoreProvider);
    await store.clear();
    invalidateSessionScopedProviders(_ref);
    state = AuthStage.signedOut;
  }

  Future<void> signUp({
    required String phone,
    required String password,
    String? displayName,
  }) async {
    await _whenUnauthenticated(
      () => _api.signup(
          phone: phone, password: password, displayName: displayName),
    );
  }

  Future<void> signOut() async {
    final store = _ref.read(sessionStoreProvider);
    final refresh = await store.readRefreshToken();
    try {
      await _api.logout(refresh: refresh);
    } on Object {
      // Clearing the local session below is what actually signs the user out.
    }
    await store.clear();
    invalidateSessionScopedProviders(_ref);
    state = AuthStage.signedOut;
  }

  /// Creates the workspace and returns to the signed-in stage.
  Future<void> createBusiness({
    required String name,
    String? legalName,
    String? gstin,
    String? stateCode,
    String? locationName,
  }) async {
    await _repository.createBusiness({
      'name': name,
      if (legalName != null && legalName.isNotEmpty) 'legal_name': legalName,
      if (gstin != null && gstin.isNotEmpty) 'gstin': gstin,
      if (stateCode != null && stateCode.isNotEmpty) 'state_code': stateCode,
      if (locationName != null && locationName.isNotEmpty)
        'location_name': locationName,
    });
    invalidateSessionScopedProviders(_ref);
    await refreshStage();
  }

  Future<T> _guarded<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on AuthFailure {
      rethrow;
    } on Object catch (error) {
      throw AuthFailure(
          describeDioError(error, 'The request could not be completed.'));
    }
  }

  Future<void> _whenUnauthenticated(Future<AuthTokens> Function() call) async {
    try {
      final tokens = await call();
      invalidateSessionScopedProviders(_ref);
      state =
          tokens.onboardingRequired ? AuthStage.needsBusiness : AuthStage.ready;
      if (state == AuthStage.ready) await refreshStage();
    } on AuthFailure {
      rethrow;
    } on PlatformException catch (error) {
      // Credentials arrived but could not be stored. Saying so beats the
      // generic fallback: the account and password are fine, the device is the
      // problem (for example a missing keychain entitlement).
      throw AuthFailure(
        'Signed in, but this device could not store the session securely '
        '(${error.code}).',
      );
    } on Object catch (error) {
      throw AuthFailure(
          describeDioError(error, 'The request could not be completed.'));
    }
  }
}
