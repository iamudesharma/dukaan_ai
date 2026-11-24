import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvitationAcceptancePanel extends ConsumerStatefulWidget {
  const InvitationAcceptancePanel({this.compact = false, super.key});

  final bool compact;

  @override
  ConsumerState<InvitationAcceptancePanel> createState() =>
      _InvitationAcceptancePanelState();
}

class _InvitationAcceptancePanelState
    extends ConsumerState<InvitationAcceptancePanel> {
  final _token = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _success;

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    final strings = context.strings;
    final token = _token.text.trim();
    if (token.length < 20 || token.length > 128) {
      setState(() => _error = strings.t('required'));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _success = null;
    });
    try {
      await ref.read(repositoryProvider).acceptInvitation(token: token);
      if (!mounted) return;
      _token.clear();
      ref
        ..invalidate(currentUserProvider)
        ..invalidate(bootstrapProvider)
        ..invalidate(locationsProvider)
        ..invalidate(dashboardProvider)
        ..invalidate(entriesProvider)
        ..invalidate(productsProvider)
        ..invalidate(partiesProvider);
      setState(() => _success = strings.t('invitationAccepted'));
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = describeDioError(
              error,
              'The invitation could not be accepted.',
            ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.compact) ...[
          Text(
            strings.t('acceptInvitation'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: DukaanTokens.space1),
          Text(
            strings.t('acceptInvitationDetail'),
            style: DukaanTokens.textCaption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: DukaanTokens.space3),
        ],
        DukaanField(
          label: strings.t('invitationToken'),
          child: TextField(
            key: const Key('invitation-accept-token'),
            controller: _token,
            enabled: !_busy,
            minLines: 1,
            maxLines: 3,
            autofillHints: const [AutofillHints.oneTimeCode],
            decoration: const InputDecoration(),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: DukaanTokens.space2),
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              style: DukaanTokens.textCaption.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
        if (_success != null) ...[
          const SizedBox(height: DukaanTokens.space2),
          Semantics(
            liveRegion: true,
            child: Text(
              _success!,
              style: DukaanTokens.textCaption.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
        const SizedBox(height: DukaanTokens.space3),
        FilledButton.icon(
          key: const Key('invitation-accept-submit'),
          onPressed: _busy ? null : _accept,
          icon: _busy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(strings.t('accept')),
        ),
      ],
    );
  }
}
