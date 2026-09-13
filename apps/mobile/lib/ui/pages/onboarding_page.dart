import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// First-run screen for accounts without a business: create one or join
/// with an invitation id + token shared by the inviter.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _displayName = TextEditingController();
  final _inviteId = TextEditingController();
  final _inviteToken = TextEditingController();
  bool _joining = false;
  bool _saving = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _businessName.dispose();
    _displayName.dispose();
    _inviteId.dispose();
    _inviteToken.dispose();
    super.dispose();
  }

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
    return context.strings.t('loadFailed');
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate() || _joining) return;
    setState(() {
      _saving = true;
      _error = null;
      _notice = null;
    });
    try {
      await ref.read(repositoryProvider).createBusiness({'name': _businessName.text.trim()});
      final name = _displayName.text.trim();
      if (name.isNotEmpty) {
        try {
          await ref.read(repositoryProvider).updateProfile({'display_name': name});
        } catch (_) {
          // The business is what matters; the name is a nicety.
        }
      }
      ref
        ..invalidate(businessesProvider)
        ..invalidate(sessionTokenProvider);
    } on Object catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _join() async {
    if (!_formKey.currentState!.validate() || !_joining) return;
    if (_inviteId.text.trim().isEmpty || _inviteToken.text.trim().isEmpty) {
      setState(() => _error = context.strings.t('required'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _notice = null;
    });
    try {
      await ref.read(repositoryProvider).acceptInvitation(
            id: _inviteId.text.trim(),
            token: _inviteToken.text.trim(),
          );
      ref
        ..invalidate(businessesProvider)
        ..invalidate(sessionTokenProvider);
      if (mounted) setState(() => _notice = context.strings.t('inviteAccepted'));
    } on Object catch (error) {
      if (mounted) setState(() => _error = _message(error));
    } finally {
      if (mounted) setState(() => _saving = false);
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
                      strings.t('openBusiness'),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(strings.t('openBusinessDetail'), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(strings.t('createBusiness')),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(strings.t('joinWithInvite')),
                        ),
                      ],
                      selected: {_joining},
                      onSelectionChanged: (value) => setState(() {
                        _joining = value.single;
                        _error = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    if (!_joining) ...[
                      TextFormField(
                        controller: _businessName,
                        decoration: InputDecoration(labelText: strings.t('businessName')),
                        validator: (value) =>
                            (value ?? '').trim().isEmpty ? strings.t('required') : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _displayName,
                        decoration: InputDecoration(labelText: strings.t('yourNameOptional')),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _saving ? null : _create,
                        child: Text(strings.t('createBusiness')),
                      ),
                    ] else ...[
                      TextFormField(
                        controller: _inviteId,
                        decoration: InputDecoration(labelText: strings.t('inviteId')),
                        validator: (value) =>
                            (value ?? '').trim().isEmpty ? strings.t('required') : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _inviteToken,
                        decoration: InputDecoration(labelText: strings.t('inviteToken')),
                        validator: (value) =>
                            (value ?? '').trim().isEmpty ? strings.t('required') : null,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _saving ? null : _join,
                        child: Text(strings.t('joinBusiness')),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (_notice != null) ...[
                      const SizedBox(height: 12),
                      Text(_notice!, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () async {
                              await ref.read(authApiProvider).logout();
                              bumpSession(ref);
                            },
                      child: Text(strings.t('signOut')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
