import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _AuthMode { password, otp, reset }

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _phone = TextEditingController(text: '+91');
  final _password = TextEditingController();
  final _otp = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  _AuthMode _mode = _AuthMode.password;
  bool _otpSent = false;
  bool _submitting = false;
  String? _error;
  String? _notice;
  String? _devOtp;
  String? _phoneError;
  String? _otpError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    _otp.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String get _normalizedPhone => _phone.text.replaceAll(RegExp(r'[\s()-]'), '');

  bool _validatePhone() {
    final valid = RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(_normalizedPhone);
    setState(
        () => _phoneError = valid ? null : context.strings.t('invalidPhone'));
    return valid;
  }

  bool _validateOtp() {
    final valid = RegExp(r'^\d{4,8}$').hasMatch(_otp.text.trim());
    setState(() => _otpError = valid ? null : context.strings.t('invalidOtp'));
    return valid;
  }

  void _changeMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _otpSent = false;
      _otp.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      _devOtp = null;
      _error = null;
      _notice = null;
      _phoneError = null;
      _otpError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });
  }

  void _changePhone() {
    setState(() {
      _otpSent = false;
      _otp.clear();
      _devOtp = null;
      _error = null;
      _notice = null;
      _otpError = null;
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await action();
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitPassword() async {
    await _run(() => ref.read(authControllerProvider.notifier).signIn(
          phone: _phone.text,
          password: _password.text,
        ));
  }

  Future<void> _sendCode({required bool reset}) async {
    if (!_validatePhone()) return;
    final strings = context.strings;
    final controller = ref.read(authControllerProvider.notifier);
    await _run(() async {
      final devOtp = reset
          ? await controller.requestPasswordReset(phone: _phone.text)
          : await controller.sendOtp(phone: _phone.text);
      if (!mounted) return;
      final capabilities = ref.read(authCapabilitiesProvider).valueOrNull;
      setState(() {
        _otpSent = true;
        _devOtp = capabilities?.devOtp == true ? devOtp : null;
        _notice = '${strings.t('otpSentTo')} $_normalizedPhone';
        if (_devOtp != null) _otp.text = _devOtp!;
      });
    });
  }

  Future<void> _verifyOtp() async {
    if (!_validateOtp()) return;
    await _run(() => ref.read(authControllerProvider.notifier).signInWithOtp(
          phone: _phone.text,
          otp: _otp.text.trim(),
        ));
  }

  Future<void> _showInvitationHelp() async {
    final strings = context.strings;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.t('acceptInvitation')),
        content: Text(strings.t('invitationSignInFirst')),
        actions: [
          TextButton(
            key: const Key('invitation-sign-in-dismiss'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.t('close')),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset() async {
    final strings = context.strings;
    final otpValid = _validateOtp();
    final passwordValid = _newPassword.text.length >= 8;
    final confirmationValid = _confirmPassword.text == _newPassword.text;
    setState(() {
      _newPasswordError = passwordValid ? null : strings.t('passwordHint');
      _confirmPasswordError =
          confirmationValid ? null : strings.t('passwordsDoNotMatch');
    });
    if (!otpValid || !passwordValid || !confirmationValid) return;
    await _run(() async {
      await ref.read(authControllerProvider.notifier).confirmPasswordReset(
            phone: _phone.text,
            otp: _otp.text.trim(),
            newPassword: _newPassword.text,
          );
      if (!mounted) return;
      setState(() {
        _mode = _AuthMode.password;
        _otpSent = false;
        _otp.clear();
        _newPassword.clear();
        _confirmPassword.clear();
        _devOtp = null;
        _notice = strings.t('passwordResetDone');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final capabilities = ref.watch(authCapabilitiesProvider);
    final available = capabilities.valueOrNull;
    final otpEnabled = available?.otp == true;
    // Keep password sign-in usable while capabilities load or if an older
    // server does not expose the endpoint. OTP controls remain fail-closed.
    final passwordEnabled = available?.password ?? true;
    final mode = !passwordEnabled && _mode != _AuthMode.reset
        ? _AuthMode.otp
        : !otpEnabled && _mode != _AuthMode.password
            ? _AuthMode.password
            : _mode;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DukaanTokens.space4),
          children: [
            const SizedBox(height: DukaanTokens.space6),
            DukaanHeroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DukaanHeroEyebrow('DukaanAI · Sign in'),
                  const SizedBox(height: DukaanTokens.space2),
                  DukaanHeroText(
                    strings.t(switch (mode) {
                      _AuthMode.password => 'signIn',
                      _AuthMode.otp => 'signInWithOtp',
                      _AuthMode.reset => 'resetPassword',
                    }),
                    style: DukaanTokens.textDisplay,
                  ),
                  const SizedBox(height: DukaanTokens.space2),
                  DukaanHeroText(strings.t(switch (mode) {
                    _AuthMode.password => 'signInDetail',
                    _AuthMode.otp => 'otpSignInDetail',
                    _AuthMode.reset => 'resetPasswordDetail',
                  })),
                ],
              ),
            ),
            const SizedBox(height: DukaanTokens.space4),
            DukaanCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (capabilities.isLoading) ...[
                    const LinearProgressIndicator(
                        key: Key('auth-capabilities-loading')),
                    const SizedBox(height: DukaanTokens.space3),
                  ],
                  if (mode != _AuthMode.reset &&
                      passwordEnabled &&
                      otpEnabled) ...[
                    SegmentedButton<_AuthMode>(
                      key: const Key('auth-mode-selector'),
                      segments: [
                        ButtonSegment(
                          value: _AuthMode.password,
                          label: Text(strings.t('password')),
                        ),
                        ButtonSegment(
                          value: _AuthMode.otp,
                          label: Text(strings.t('verificationCode')),
                        ),
                      ],
                      selected: {mode},
                      showSelectedIcon: false,
                      onSelectionChanged: _submitting
                          ? null
                          : (selection) => _changeMode(selection.single),
                    ),
                    const SizedBox(height: DukaanTokens.space4),
                  ],
                  DukaanField(
                    label: strings.t('phone'),
                    child: TextField(
                      key: const Key('auth-phone'),
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      enabled: !_submitting && !_otpSent,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: InputDecoration(
                        hintText: '+91 98765 43210',
                        errorText: _phoneError,
                      ),
                      onChanged: (_) {
                        if (_phoneError != null) {
                          setState(() => _phoneError = null);
                        }
                      },
                    ),
                  ),
                  if (mode == _AuthMode.password) ...[
                    const SizedBox(height: DukaanTokens.space3),
                    DukaanField(
                      label: strings.t('password'),
                      child: TextField(
                        key: const Key('auth-password'),
                        controller: _password,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submitPassword(),
                        decoration: const InputDecoration(),
                      ),
                    ),
                    if (otpEnabled)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          key: const Key('auth-forgot-password'),
                          onPressed: _submitting
                              ? null
                              : () => _changeMode(_AuthMode.reset),
                          child: Text(strings.t('forgotPassword')),
                        ),
                      ),
                    const SizedBox(height: DukaanTokens.space2),
                    FilledButton(
                      key: const Key('auth-password-submit'),
                      onPressed: _submitting ? null : _submitPassword,
                      child:
                          _submitting ? _spinner() : Text(strings.t('signIn')),
                    ),
                  ] else if (!_otpSent) ...[
                    const SizedBox(height: DukaanTokens.space4),
                    FilledButton(
                      key: Key(mode == _AuthMode.reset
                          ? 'auth-send-reset-otp'
                          : 'auth-send-otp'),
                      onPressed: _submitting
                          ? null
                          : () => _sendCode(reset: mode == _AuthMode.reset),
                      child: _submitting
                          ? _spinner()
                          : Text(strings.t(mode == _AuthMode.reset
                              ? 'sendResetCode'
                              : 'sendCode')),
                    ),
                  ] else ...[
                    const SizedBox(height: DukaanTokens.space3),
                    _Notice(
                        text: _notice ?? '', devOtp: _devOtp, strings: strings),
                    const SizedBox(height: DukaanTokens.space3),
                    DukaanField(
                      label: strings.t('verificationCode'),
                      child: TextField(
                        key: const Key('auth-otp'),
                        controller: _otp,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        maxLength: 8,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onSubmitted: (_) => mode == _AuthMode.reset
                            ? _confirmReset()
                            : _verifyOtp(),
                        decoration: InputDecoration(
                          counterText: '',
                          errorText: _otpError,
                        ),
                        onChanged: (_) {
                          if (_otpError != null) {
                            setState(() => _otpError = null);
                          }
                        },
                      ),
                    ),
                    if (mode == _AuthMode.reset) ...[
                      const SizedBox(height: DukaanTokens.space3),
                      DukaanField(
                        label: strings.t('newPassword'),
                        hint: strings.t('passwordHint'),
                        child: TextField(
                          key: const Key('auth-new-password'),
                          controller: _newPassword,
                          obscureText: true,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration:
                              InputDecoration(errorText: _newPasswordError),
                        ),
                      ),
                      const SizedBox(height: DukaanTokens.space3),
                      DukaanField(
                        label: strings.t('confirmPassword'),
                        child: TextField(
                          key: const Key('auth-confirm-password'),
                          controller: _confirmPassword,
                          obscureText: true,
                          autofillHints: const [AutofillHints.newPassword],
                          onSubmitted: (_) => _confirmReset(),
                          decoration:
                              InputDecoration(errorText: _confirmPasswordError),
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: DukaanTokens.space3),
                      _ErrorText(_error!),
                    ],
                    const SizedBox(height: DukaanTokens.space4),
                    FilledButton(
                      key: Key(mode == _AuthMode.reset
                          ? 'auth-confirm-reset'
                          : 'auth-verify-otp'),
                      onPressed: _submitting
                          ? null
                          : mode == _AuthMode.reset
                              ? _confirmReset
                              : _verifyOtp,
                      child: _submitting
                          ? _spinner()
                          : Text(strings.t(mode == _AuthMode.reset
                              ? 'resetPassword'
                              : 'verifyAndSignIn')),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        TextButton(
                          key: const Key('auth-resend-otp'),
                          onPressed: _submitting
                              ? null
                              : () => _sendCode(reset: mode == _AuthMode.reset),
                          child: Text(strings.t('resendCode')),
                        ),
                        TextButton(
                          key: const Key('auth-change-phone'),
                          onPressed: _submitting ? null : _changePhone,
                          child: Text(strings.t('changePhone')),
                        ),
                      ],
                    ),
                  ],
                  if (mode == _AuthMode.password && _error != null) ...[
                    const SizedBox(height: DukaanTokens.space3),
                    _ErrorText(_error!),
                  ],
                  if (_notice != null && mode == _AuthMode.password) ...[
                    const SizedBox(height: DukaanTokens.space3),
                    _Notice(text: _notice!, strings: strings),
                  ],
                  if (!passwordEnabled && !otpEnabled) ...[
                    const SizedBox(height: DukaanTokens.space3),
                    Text(strings.t('signInUnavailable')),
                  ],
                  if (mode == _AuthMode.reset) ...[
                    TextButton(
                      key: const Key('auth-back-to-sign-in'),
                      onPressed: _submitting
                          ? null
                          : () => _changeMode(_AuthMode.password),
                      child: Text(strings.t('backToSignIn')),
                    ),
                  ] else ...[
                    const SizedBox(height: DukaanTokens.space2),
                    TextButton(
                      onPressed:
                          _submitting ? null : () => context.go('/sign-up'),
                      child: Text(strings.t('noAccount')),
                    ),
                    TextButton(
                      key: const Key('invitation-help-from-sign-in'),
                      onPressed: _submitting ? null : _showInvitationHelp,
                      child: Text(strings.t('acceptInvitation')),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spinner() => const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, required this.strings, this.devOtp});

  final String text;
  final String? devOtp;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.all(DukaanTokens.space3),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(DukaanTokens.radiusControl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: DukaanTokens.textLabel),
              if (devOtp != null) ...[
                const SizedBox(height: DukaanTokens.space1),
                Text(
                  '${strings.t('developmentCode')}: $devOtp',
                  style: DukaanTokens.textLabel.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Text(
          text,
          style: DukaanTokens.textLabel
              .copyWith(color: Theme.of(context).colorScheme.error),
        ),
      );
}
