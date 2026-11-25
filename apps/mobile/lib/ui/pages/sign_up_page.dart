import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _phone = TextEditingController(text: '+91');
  final _displayName = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _displayName.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_password.text.length < 8) {
      setState(() => _error = context.strings.t('passwordHint'));
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).signUp(
            phone: _phone.text,
            password: _password.text,
            displayName: _displayName.text,
          );
    } on AuthFailure catch (failure) {
      setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;

    return Scaffold(
      appBar:
          AppBar(leading: BackButton(onPressed: () => context.go('/sign-in'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DukaanTokens.space4),
          children: [
            DukaanHeroCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DukaanHeroEyebrow('DukaanAI · New account'),
                  const SizedBox(height: DukaanTokens.space2),
                  DukaanHeroText(
                    strings.t('signUp'),
                    style: DukaanTokens.textDisplay,
                  ),
                  const SizedBox(height: DukaanTokens.space2),
                  DukaanHeroText(strings.t('signUpDetail')),
                ],
              ),
            ),
            const SizedBox(height: DukaanTokens.space4),
            DukaanCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DukaanSectionHeader(
                    kicker: '01 · ${strings.t('signUp')}',
                    title: strings.t('displayName'),
                    ruled: true,
                  ),
                  const SizedBox(height: DukaanTokens.space3),
                  DukaanField(
                    label: strings.t('phone'),
                    child: TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration:
                          const InputDecoration(hintText: '+91 98765 43210'),
                    ),
                  ),
                  const SizedBox(height: DukaanTokens.space3),
                  DukaanField(
                    label: strings.t('displayName'),
                    child: TextField(
                      controller: _displayName,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(),
                    ),
                  ),
                  const SizedBox(height: DukaanTokens.space3),
                  DukaanField(
                    label: strings.t('password'),
                    hint: strings.t('passwordHint'),
                    child: TextField(
                      controller: _password,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      onSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: DukaanTokens.space3),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: DukaanTokens.space4),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(strings.t('signUp')),
                  ),
                  const SizedBox(height: DukaanTokens.space2),
                  TextButton(
                    onPressed:
                        _submitting ? null : () => context.go('/sign-in'),
                    child: Text(strings.t('signIn')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
