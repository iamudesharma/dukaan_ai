import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/common/settings_page_layout.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({super.key});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _revokePassword = TextEditingController();
  bool _changing = false;
  bool _revoking = false;
  String? _changeError;
  String? _revokeError;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    _revokePassword.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final strings = context.strings;
    final valid = _newPassword.text.length >= 8 &&
        _newPassword.text == _confirmPassword.text;
    setState(() {
      _changeError = _oldPassword.text.isEmpty
          ? strings.t('currentPasswordRequired')
          : !valid
              ? strings.t('passwordHint')
              : null;
    });
    if (_oldPassword.text.isEmpty || !valid) return;
    setState(() => _changing = true);
    try {
      await ref.read(authControllerProvider.notifier).changePassword(
            oldPassword: _oldPassword.text,
            newPassword: _newPassword.text,
          );
      // AuthController clears secure tokens and changes the auth stage only
      // after the backend confirms the password change.
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _changeError = failure.message);
    } finally {
      if (mounted) setState(() => _changing = false);
    }
  }

  Future<void> _revoke() async {
    final strings = context.strings;
    if (_revokePassword.text.isEmpty) {
      setState(() => _revokeError = strings.t('currentPasswordRequired'));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.t('revokeConfirmTitle')),
        content: Text(strings.t('revokeConfirmDetail')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.t('revokeAllDevices')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _revoking = true;
      _revokeError = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).revokeAllSessions(
            currentPassword: _revokePassword.text,
          );
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => _revokeError = failure.message);
    } finally {
      if (mounted) setState(() => _revoking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final online = ref.watch(networkStatusProvider).valueOrNull ?? false;
    return SettingsPageLayout(
      title: strings.t('security'),
      subtitle: strings.t('securityDetail'),
      child: ListView(
        children: [
          DukaanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(strings.t('changePassword'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: DukaanTokens.space1),
                Text(
                  strings.t('passwordChangeDetail'),
                  style: DukaanTokens.textCaption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: DukaanTokens.space3),
                DukaanField(
                  label: strings.t('currentPassword'),
                  child: TextField(
                    key: const Key('security-old-password'),
                    controller: _oldPassword,
                    obscureText: true,
                    enabled: !_changing,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(),
                  ),
                ),
                const SizedBox(height: DukaanTokens.space3),
                DukaanField(
                  label: strings.t('newPassword'),
                  hint: strings.t('passwordHint'),
                  child: TextField(
                    key: const Key('security-new-password'),
                    controller: _newPassword,
                    obscureText: true,
                    enabled: !_changing,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: const InputDecoration(),
                  ),
                ),
                const SizedBox(height: DukaanTokens.space3),
                DukaanField(
                  label: strings.t('confirmPassword'),
                  child: TextField(
                    key: const Key('security-confirm-password'),
                    controller: _confirmPassword,
                    obscureText: true,
                    enabled: !_changing,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: const InputDecoration(),
                  ),
                ),
                if (_changeError != null) ...[
                  const SizedBox(height: DukaanTokens.space2),
                  _ErrorText(_changeError!),
                ],
                if (!online) ...[
                  const SizedBox(height: DukaanTokens.space2),
                  _ErrorText(strings.t('offlineAction')),
                ],
                const SizedBox(height: DukaanTokens.space3),
                FilledButton.icon(
                  key: const Key('security-change-password'),
                  onPressed: online && !_changing && !_revoking
                      ? _changePassword
                      : null,
                  icon: _changing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.key_rounded, size: 18),
                  label: Text(strings.t('changePassword')),
                ),
              ],
            ),
          ),
          const SizedBox(height: DukaanTokens.space4),
          DukaanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(strings.t('revokeAllDevices'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: DukaanTokens.space1),
                Text(
                  strings.t('revokeAllDevicesDetail'),
                  style: DukaanTokens.textCaption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: DukaanTokens.space3),
                DukaanField(
                  label: strings.t('currentPassword'),
                  child: TextField(
                    key: const Key('security-revoke-password'),
                    controller: _revokePassword,
                    obscureText: true,
                    enabled: !_revoking,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(),
                  ),
                ),
                if (_revokeError != null) ...[
                  const SizedBox(height: DukaanTokens.space2),
                  _ErrorText(_revokeError!),
                ],
                if (!online) ...[
                  const SizedBox(height: DukaanTokens.space2),
                  _ErrorText(strings.t('offlineAction')),
                ],
                const SizedBox(height: DukaanTokens.space3),
                OutlinedButton.icon(
                  key: const Key('security-revoke-all'),
                  onPressed:
                      online && !_revoking && !_changing ? _revoke : null,
                  icon: _revoking
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout_rounded, size: 18),
                  label: Text(strings.t('revokeAllDevices')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Text(
          text,
          style: DukaanTokens.textCaption.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
}
