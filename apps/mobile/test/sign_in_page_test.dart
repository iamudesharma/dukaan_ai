import 'package:dukaan_ai_mobile/app.dart';
import 'package:dukaan_ai_mobile/data/auth_api.dart';
import 'package:dukaan_ai_mobile/data/draft_store.dart';
import 'package:dukaan_ai_mobile/data/session_store.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    required AuthCapabilities capabilities,
    required _FakeAuthApi api,
    Locale locale = const Locale('en'),
    Size size = const Size(430, 1000),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionStoreProvider.overrideWithValue(api.session),
          repositoryProvider.overrideWithValue(FakeDukaanRepository()),
          draftStoreProvider.overrideWithValue(MemoryDraftStore()),
          networkStatusProvider.overrideWith((ref) => Stream.value(true)),
          authApiProvider.overrideWithValue(api),
          authCapabilitiesProvider.overrideWith((ref) async => capabilities),
          localeProvider.overrideWith((ref) => _TestLocaleController(locale)),
        ],
        child: const DukaanApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('OTP options stay hidden when capabilities disable OTP',
      (tester) async {
    await pumpPage(
      tester,
      capabilities:
          const AuthCapabilities(password: true, otp: false, devOtp: true),
      api: _FakeAuthApi(MemorySessionStore()),
    );

    expect(find.byKey(const Key('auth-password')), findsOneWidget);
    expect(find.text('Verification code'), findsNothing);
    expect(find.byKey(const Key('auth-forgot-password')), findsNothing);
    expect(find.byKey(const Key('auth-send-otp')), findsNothing);
  });

  testWidgets('phone sign-in sends and verifies an OTP', (tester) async {
    final api = _FakeAuthApi(MemorySessionStore());
    await pumpPage(
      tester,
      capabilities:
          const AuthCapabilities(password: true, otp: true, devOtp: true),
      api: api,
    );

    await tester.tap(find.text('Verification code'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('auth-phone')), '+91 98765 43210');
    await tester.tap(find.byKey(const Key('auth-send-otp')));
    await tester.pumpAndSettle();

    expect(api.sendOtpCalls, 1);
    expect(api.lastSendPhone, '+91 98765 43210');
    expect(find.text('Code sent to +919876543210'), findsOneWidget);
    expect(find.text('Development code: 654321'), findsOneWidget);
    expect(find.text('654321'), findsWidgets);

    await tester.tap(find.byKey(const Key('auth-verify-otp')));
    await tester.pumpAndSettle();

    expect(api.verifyOtpCalls, 1);
    expect(api.lastVerifyPhone, '+91 98765 43210');
    expect(api.lastVerifyOtp, '654321');
    expect(await api.session.readAccessToken(), 'test-access');
    expect(find.text('Test Shop'), findsWidgets);
  });

  testWidgets('password reset verifies an OTP before setting a new password',
      (tester) async {
    final api = _FakeAuthApi(MemorySessionStore());
    await pumpPage(
      tester,
      capabilities:
          const AuthCapabilities(password: true, otp: true, devOtp: true),
      api: api,
    );

    await tester.tap(find.byKey(const Key('auth-forgot-password')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('auth-phone')), '+919876543210');
    await tester.tap(find.byKey(const Key('auth-send-reset-otp')));
    await tester.pumpAndSettle();

    expect(api.resetRequestCalls, 1);
    expect(api.lastResetRequestPhone, '+919876543210');
    await tester.enterText(
        find.byKey(const Key('auth-new-password')), 'new-password');
    await tester.enterText(
        find.byKey(const Key('auth-confirm-password')), 'new-password');
    await tester.tap(find.byKey(const Key('auth-confirm-reset')));
    await tester.pumpAndSettle();

    expect(api.resetConfirmCalls, 1);
    expect(api.lastResetPhone, '+919876543210');
    expect(api.lastResetOtp, '112233');
    expect(api.lastResetPassword, 'new-password');
    expect(find.byKey(const Key('auth-password')), findsOneWidget);
    await tester.ensureVisible(
        find.text('Password reset. Sign in with your new password.'));
    expect(find.text('Password reset. Sign in with your new password.'),
        findsOneWidget);
  });

  testWidgets('OTP-only deployments open directly to code sign-in',
      (tester) async {
    await pumpPage(
      tester,
      capabilities:
          const AuthCapabilities(password: false, otp: true, devOtp: false),
      api: _FakeAuthApi(MemorySessionStore()),
    );

    expect(find.text('Sign in with a code'), findsOneWidget);
    expect(find.byKey(const Key('auth-password')), findsNothing);
    expect(find.byKey(const Key('auth-send-otp')), findsOneWidget);
  });

  testWidgets('Hindi OTP controls fit a small phone with larger text',
      (tester) async {
    await pumpPage(
      tester,
      capabilities:
          const AuthCapabilities(password: true, otp: true, devOtp: false),
      api: _FakeAuthApi(MemorySessionStore()),
      locale: const Locale('hi'),
      size: const Size(375, 812),
      textScale: 1.6,
    );

    expect(find.text('साइन इन'), findsWidgets);
    expect(find.text('वेरिफ़िकेशन कोड'), findsOneWidget);
    expect(find.text('पासवर्ड भूल गए?'), findsOneWidget);
    await tester.tap(find.text('वेरिफ़िकेशन कोड'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth-send-otp')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestLocaleController extends AppLocaleController {
  _TestLocaleController(this.initialLocale) {
    state = initialLocale;
  }

  final Locale initialLocale;
}

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi(this.session) : super(session);

  final SessionStore session;
  int sendOtpCalls = 0;
  int verifyOtpCalls = 0;
  int resetRequestCalls = 0;
  int resetConfirmCalls = 0;
  String? lastSendPhone;
  String? lastVerifyPhone;
  String? lastVerifyOtp;
  String? lastResetRequestPhone;
  String? lastResetPhone;
  String? lastResetOtp;
  String? lastResetPassword;

  @override
  Future<String?> sendOtp({required String phone}) async {
    sendOtpCalls++;
    lastSendPhone = phone;
    return '654321';
  }

  @override
  Future<AuthTokens> verifyOtp(
      {required String phone, required String otp}) async {
    verifyOtpCalls++;
    lastVerifyPhone = phone;
    lastVerifyOtp = otp;
    await session.writeSession(access: 'test-access', refresh: 'test-refresh');
    return AuthTokens(
        access: 'test-access',
        refresh: 'test-refresh',
        onboardingRequired: false);
  }

  @override
  Future<String?> requestPasswordReset({required String phone}) async {
    resetRequestCalls++;
    lastResetRequestPhone = phone;
    return '112233';
  }

  @override
  Future<void> confirmPasswordReset({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    resetConfirmCalls++;
    lastResetPhone = phone;
    lastResetOtp = otp;
    lastResetPassword = newPassword;
  }
}
