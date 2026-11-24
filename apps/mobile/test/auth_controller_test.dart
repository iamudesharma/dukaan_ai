import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/data/auth_api.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// A repository whose bootstrap call reports that no shop exists yet.
class _NeedsBusinessRepository extends FakeDukaanRepository {
  bool businessCreated = false;

  @override
  Future<Map<String, dynamic>> fetchBootstrap({String? businessId}) async {
    if (businessCreated) return super.fetchBootstrap(businessId: businessId);
    final options = RequestOptions(path: 'bootstrap/');
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response<Object>(
        requestOptions: options,
        statusCode: 404,
        data: const {
          'error': {
            'code': 'onboarding_required',
            'detail': 'Create a business to get started'
          },
        },
      ),
    );
  }

  @override
  Future<Business> createBusiness(Map<String, dynamic> payload) async {
    businessCreated = true;
    return super.createBusiness(payload);
  }
}

ProviderContainer containerWith({
  required FakeDukaanRepository repository,
  required SessionStore session,
  AuthApi? authApi,
}) {
  final container = ProviderContainer(
    overrides: [
      repositoryProvider.overrideWithValue(repository),
      sessionStoreProvider.overrideWithValue(session),
      if (authApi != null) authApiProvider.overrideWithValue(authApi),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('no stored token means signed out', () async {
    final container = containerWith(
      repository: FakeDukaanRepository(),
      session: MemorySessionStore(),
    );

    await container.read(authControllerProvider.notifier).refreshStage();

    expect(container.read(authControllerProvider), AuthStage.signedOut);
  });

  test('a stored token with a shop is ready', () async {
    final container = containerWith(
      repository: FakeDukaanRepository(),
      session: MemorySessionStore(access: 'access', refresh: 'refresh'),
    );

    await container.read(authControllerProvider.notifier).refreshStage();

    expect(container.read(authControllerProvider), AuthStage.ready);
  });

  test('a stored token without a shop needs onboarding', () async {
    final container = containerWith(
      repository: _NeedsBusinessRepository(),
      session: MemorySessionStore(access: 'access', refresh: 'refresh'),
    );

    await container.read(authControllerProvider.notifier).refreshStage();

    expect(container.read(authControllerProvider), AuthStage.needsBusiness);
  });

  test('an expired session is cleared instead of looping', () async {
    final session = MemorySessionStore(access: 'access', refresh: 'refresh');
    final options = RequestOptions(path: 'bootstrap/');
    final container = containerWith(
      repository: _ExpiredRepository(options),
      session: session,
    );

    await container.read(authControllerProvider.notifier).refreshStage();

    expect(container.read(authControllerProvider), AuthStage.signedOut);
    expect(await session.readAccessToken(), isNull);
  });

  test('OTP sign-in stores tokens and enters the app', () async {
    final session = MemorySessionStore();
    final api = _FakeAuthApi(session);
    final container = containerWith(
      repository: FakeDukaanRepository(),
      session: session,
      authApi: api,
    );

    await container.read(authControllerProvider.notifier).signInWithOtp(
          phone: '+919876543210',
          otp: '123456',
        );

    expect(api.verifiedPhone, '+919876543210');
    expect(api.verifiedOtp, '123456');
    expect(await session.readAccessToken(), 'otp-access');
    expect(await session.readRefreshToken(), 'otp-refresh');
    expect(container.read(authControllerProvider), AuthStage.ready);
  });

  test('OTP sign-in sends a new account to onboarding', () async {
    final session = MemorySessionStore();
    final api = _FakeAuthApi(session, onboardingRequired: true);
    final container = containerWith(
      repository: FakeDukaanRepository(),
      session: session,
      authApi: api,
    );

    await container.read(authControllerProvider.notifier).signInWithOtp(
          phone: '+919876543210',
          otp: '123456',
        );

    expect(container.read(authControllerProvider), AuthStage.needsBusiness);
  });

  test('OTP send and password reset use the existing auth API methods',
      () async {
    final session = MemorySessionStore();
    final api = _FakeAuthApi(session);
    final container = containerWith(
      repository: FakeDukaanRepository(),
      session: session,
      authApi: api,
    );
    final controller = container.read(authControllerProvider.notifier);

    expect(await controller.sendOtp(phone: '+919876543210'), '123456');
    expect(api.sentPhone, '+919876543210');
    expect(await controller.requestPasswordReset(phone: '+919876543210'),
        '123456');
    expect(api.resetRequestPhone, '+919876543210');
    await controller.confirmPasswordReset(
      phone: '+919876543210',
      otp: '123456',
      newPassword: 'new-password',
    );
    expect(api.resetConfirmedPhone, '+919876543210');
    expect(api.resetConfirmedOtp, '123456');
    expect(api.resetConfirmedPassword, 'new-password');
  });

  test('creating a shop moves an onboarded owner into the app', () async {
    final repository = _NeedsBusinessRepository();
    final container = containerWith(
      repository: repository,
      session: MemorySessionStore(access: 'access', refresh: 'refresh'),
    );
    await container.read(authControllerProvider.notifier).refreshStage();
    expect(container.read(authControllerProvider), AuthStage.needsBusiness);

    await container.read(authControllerProvider.notifier).createBusiness(
          name: 'Gupta Traders',
          legalName: 'Gupta Traders Pvt Ltd',
          locationName: 'Karol Bagh',
          gstin: '07aaaaa0000a1z5',
          stateCode: '07',
        );

    expect(container.read(authControllerProvider), AuthStage.ready);
    expect(repository.lastBusinessPayload, {
      'name': 'Gupta Traders',
      'legal_name': 'Gupta Traders Pvt Ltd',
      'gstin': '07aaaaa0000a1z5',
      'state_code': '07',
      'location_name': 'Karol Bagh',
    });
  });
}

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi(this.session, {this.onboardingRequired = false})
      : super(session);

  final SessionStore session;
  final bool onboardingRequired;
  String? sentPhone;
  String? verifiedPhone;
  String? verifiedOtp;
  String? resetRequestPhone;
  String? resetConfirmedPhone;
  String? resetConfirmedOtp;
  String? resetConfirmedPassword;

  @override
  Future<String?> sendOtp({required String phone}) async {
    sentPhone = phone;
    return '123456';
  }

  @override
  Future<AuthTokens> verifyOtp(
      {required String phone, required String otp}) async {
    verifiedPhone = phone;
    verifiedOtp = otp;
    await session.writeSession(access: 'otp-access', refresh: 'otp-refresh');
    return AuthTokens(
      access: 'otp-access',
      refresh: 'otp-refresh',
      onboardingRequired: onboardingRequired,
    );
  }

  @override
  Future<String?> requestPasswordReset({required String phone}) async {
    resetRequestPhone = phone;
    return '123456';
  }

  @override
  Future<void> confirmPasswordReset({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    resetConfirmedPhone = phone;
    resetConfirmedOtp = otp;
    resetConfirmedPassword = newPassword;
  }
}

class _ExpiredRepository extends FakeDukaanRepository {
  _ExpiredRepository(this.options);

  final RequestOptions options;

  @override
  Future<Map<String, dynamic>> fetchBootstrap({String? businessId}) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.badResponse,
      response: Response<Object>(requestOptions: options, statusCode: 401),
    );
  }
}
