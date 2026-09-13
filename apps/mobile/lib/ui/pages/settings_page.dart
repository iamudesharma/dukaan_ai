import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _meProvider = FutureProvider<Map<String, dynamic>>(
  (ref) => ref.watch(repositoryProvider).fetchMe(),
);

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _displayName = TextEditingController();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  bool _nameInitialized = false;
  bool _savingProfile = false;
  bool _savingPassword = false;
  String? _message;
  String? _error;

  @override
  void dispose() {
    _displayName.dispose();
    _oldPassword.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() {
      _savingProfile = true;
      _message = null;
      _error = null;
    });
    try {
      await ref.read(repositoryProvider).updateProfile(
        {'display_name': _displayName.text.trim()},
      );
      ref.invalidate(_meProvider);
      if (mounted) setState(() => _message = context.strings.t('profileSaved'));
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    if (_oldPassword.text.isEmpty || _newPassword.text.length < 8) {
      setState(() => _error = context.strings.t('required'));
      return;
    }
    setState(() {
      _savingPassword = true;
      _message = null;
      _error = null;
    });
    try {
      await ref.read(authApiProvider).changePassword(
            oldPassword: _oldPassword.text,
            newPassword: _newPassword.text,
          );
      if (mounted) {
        setState(() => _message = context.strings.t('passwordUpdated'));
        _oldPassword.clear();
        _newPassword.clear();
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  Future<void> _signOut({required bool everywhere}) async {
    final strings = context.strings;
    if (everywhere) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.t('signOutEverywhere')),
          content: Text(strings.t('signOutEverywhereConfirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.t('signOut')),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await ref.read(authApiProvider).logoutAll();
    } else {
      await ref.read(authApiProvider).logout();
    }
    bumpSession(ref);
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final me = ref.watch(_meProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text(
          strings.t('settings'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        me.when(
          loading: () => const LoadingContent(),
          error: (error, _) => ErrorContent(
            message: error.toString(),
            onRetry: () => ref.invalidate(_meProvider),
          ),
          data: (profile) {
            if (!_nameInitialized) {
              _displayName.text = (profile['display_name'] ?? '').toString();
              _nameInitialized = true;
            }
            final phone = (profile['phone'] ?? '').toString();
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.t('businessProfile'),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(phone),
                    ],
                    const SizedBox(height: 8),
                    TextField(
                      controller: _displayName,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(labelText: strings.t('displayName')),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _savingProfile ? null : _saveProfile,
                      child: Text(strings.t('save')),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.t('updatePassword'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _oldPassword,
                  obscureText: true,
                  decoration: InputDecoration(labelText: strings.t('currentPassword')),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newPassword,
                  obscureText: true,
                  decoration: InputDecoration(labelText: strings.t('newPassword')),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _savingPassword ? null : _changePassword,
                  child: Text(strings.t('updatePassword')),
                ),
              ],
            ),
          ),
        ),
        if (_message != null) ...[
          const SizedBox(height: 8),
          Text(_message!, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _signOut(everywhere: false),
          icon: const Icon(Icons.logout_rounded),
          label: Text(strings.t('signOut')),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _signOut(everywhere: true),
          icon: const Icon(Icons.logout_rounded),
          label: Text(strings.t('signOutEverywhere')),
        ),
      ],
    );
  }
}
