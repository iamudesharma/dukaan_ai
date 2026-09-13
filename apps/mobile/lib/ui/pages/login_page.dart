import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Step { phone, otp, password, signup, reset, resetConfirm }

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController(text: '+91');
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _newPassword = TextEditingController();
  _Step _step = _Step.phone;
  bool _saving = false;
  String? _error;
  String? _devOtp;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    _password.dispose();
    _name.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  String get _normalized => _phone.text.replaceAll(RegExp(r'[\s()-]'), '');

  String _message(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final detail = (data['error'] is Map ? data['error']['detail'] : data['detail']);
        if (detail is Map && detail['message'] is String) {
          return (detail['message'] as String).toString();
        }
        if (detail is String && detail.isNotEmpty) return detail;
      }
    }
    return context.strings.t('signInFailed');
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _saving = true;
      _error = null;
      _devOtp = null;
    });
    try {
      await action();
      bumpSession(ref);
    } on Object catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final api = ref.read(authApiProvider);
    String? devOtp;
    await _run(() async {
      devOtp = await api.sendOtp(phone: _normalized);
    });
    if (mounted && _error == null) {
      setState(() {
        _step = _Step.otp;
        _devOtp = devOtp;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final api = ref.read(authApiProvider);
    await _run(() => api.verifyOtp(phone: _normalized, otp: _otp.text.trim()));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final api = ref.read(authApiProvider);
    await _run(() => api.login(phone: _normalized, password: _password.text));
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    final api = ref.read(authApiProvider);
    await _run(
      () => api.signup(
        phone: _normalized,
        password: _password.text,
        displayName: _name.text.trim().isEmpty ? null : _name.text.trim(),
      ),
    );
  }

  Future<void> _requestReset() async {
    if (!_formKey.currentState!.validate()) return;
    final api = ref.read(authApiProvider);
    String? devOtp;
    await _run(() async {
      devOtp = await api.requestPasswordReset(phone: _normalized);
    });
    if (mounted && _error == null) {
      setState(() {
        _step = _Step.resetConfirm;
        _devOtp = devOtp;
      });
    }
  }

  Future<void> _confirmReset() async {
    if (!_formKey.currentState!.validate()) return;
    final api = ref.read(authApiProvider);
    String? done;
    await _run(() async {
      await api.confirmPasswordReset(
        phone: _normalized,
        otp: _otp.text.trim(),
        newPassword: _newPassword.text,
      );
      done = 'done';
    });
    if (mounted && done != null && _error == null) {
      setState(() {
        _step = _Step.password;
        _error = context.strings.t('resetDone');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.storefront_rounded, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      strings.t('signInTitle'),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.t('signInSubtitle'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ..._fields(strings),
                    const SizedBox(height: 16),
                    ..._actions(strings),
                    if (_devOtp != null) ...[
                      const SizedBox(height: 12),
                      Text('${strings.t('devOtp')}: $_devOtp', textAlign: TextAlign.center),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _fields(AppStrings strings) {
    final phoneField = TextFormField(
      controller: _phone,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(labelText: strings.t('phoneNumber')),
      validator: (value) =>
          (value ?? '').replaceAll(RegExp(r'[\s()-]'), '').length < 8 ? strings.t('required') : null,
    );
    switch (_step) {
      case _Step.phone:
        return [
          phoneField,
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: strings.t('passwordOptional')),
          ),
        ];
      case _Step.otp:
      case _Step.resetConfirm:
        return [
          TextFormField(
            controller: _otp,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(labelText: strings.t('enterOtp')),
            validator: (value) =>
                (value ?? '').trim().length < 4 ? strings.t('required') : null,
          ),
          if (_step == _Step.resetConfirm) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPassword,
              obscureText: true,
              decoration: InputDecoration(labelText: strings.t('newPassword')),
              validator: (value) =>
                  (value ?? '').length < 8 ? strings.t('required') : null,
            ),
          ],
        ];
      case _Step.password:
        return [
          phoneField,
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: strings.t('password')),
            validator: (value) => (value ?? '').isEmpty ? strings.t('required') : null,
          ),
        ];
      case _Step.signup:
        return [
          phoneField,
          const SizedBox(height: 12),
          TextFormField(
            controller: _name,
            decoration: InputDecoration(labelText: strings.t('displayName')),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: strings.t('choosePassword')),
            validator: (value) => (value ?? '').length < 8 ? strings.t('required') : null,
          ),
        ];
      case _Step.reset:
        return [phoneField];
    }
  }

  List<Widget> _actions(AppStrings strings) {
    Widget primary(String label, VoidCallback? onPressed) => FilledButton(
          onPressed: _saving ? null : onPressed,
          child: Text(label),
        );
    Widget link(String label, VoidCallback onPressed) => TextButton(
          onPressed: _saving ? null : onPressed,
          child: Text(label),
        );
    switch (_step) {
      case _Step.phone:
        final withPassword = _password.text.isNotEmpty;
        return [
          primary(
            withPassword ? strings.t('signInWithPassword') : strings.t('sendOtp'),
            withPassword ? _login : _sendOtp,
          ),
          link(
            withPassword ? strings.t('useOtp') : strings.t('usePassword'),
            () => setState(() {
              _password.clear();
              _step = withPassword ? _Step.phone : _Step.password;
            }),
          ),
          link(strings.t('createAccount'), () => setState(() => _step = _Step.signup)),
          link(strings.t('forgotPassword'), () => setState(() => _step = _Step.reset)),
        ];
      case _Step.otp:
        return [
          primary(strings.t('verifyAndContinue'), _verifyOtp),
          link(strings.t('backToSignIn'), () => setState(() => _step = _Step.phone)),
        ];
      case _Step.password:
        return [
          primary(strings.t('signIn'), _login),
          link(strings.t('useOtp'), () => setState(() => _step = _Step.phone)),
        ];
      case _Step.signup:
        return [
          primary(strings.t('createAccountTitle'), _signup),
          link(strings.t('backToSignIn'), () => setState(() => _step = _Step.phone)),
        ];
      case _Step.reset:
        return [
          primary(strings.t('sendResetCode'), _requestReset),
          link(strings.t('backToSignIn'), () => setState(() => _step = _Step.phone)),
        ];
      case _Step.resetConfirm:
        return [
          primary(strings.t('resetPassword'), _confirmReset),
          link(strings.t('backToSignIn'), () => setState(() => _step = _Step.phone)),
        ];
    }
  }
}
