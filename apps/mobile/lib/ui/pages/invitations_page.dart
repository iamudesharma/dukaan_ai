import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/data/sharing_service.dart';
import 'package:dukaan_ai_mobile/domain/backend_models.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/common/settings_page_layout.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvitationsPage extends ConsumerWidget {
  const InvitationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed =
        ref.watch(currentBusinessRoleProvider) == BusinessRole.owner;
    return SettingsPageLayout(
      title: context.strings.t('invitationManagement'),
      subtitle: context.strings.t('invitationManagementDetail'),
      child: OwnerOnlyGate(
        allowed: allowed,
        child: const _InvitationManager(),
      ),
    );
  }
}

class _InvitationManager extends ConsumerStatefulWidget {
  const _InvitationManager();

  @override
  ConsumerState<_InvitationManager> createState() => _InvitationManagerState();
}

class _InvitationManagerState extends ConsumerState<_InvitationManager> {
  final _phone = TextEditingController();
  String _role = 'CASHIER';
  DateTime _expiresAt = DateTime.now().add(const Duration(days: 7));
  final _selectedLocations = <String>{};
  List<Invitation> _invitations = const [];
  List<BusinessLocation> _locations = const [];
  Invitation? _created;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bootstrap = await ref.read(bootstrapProvider.future);
      final repository = ref.read(repositoryProvider);
      final results = await Future.wait([
        repository.listInvitations(businessId: bootstrap.businessId),
        repository.listLocations(businessId: bootstrap.businessId),
      ]);
      if (!mounted) return;
      setState(() {
        _invitations = results[0] as List<Invitation>;
        _locations = results[1] as List<BusinessLocation>;
        _loading = false;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = describeDioError(error, 'Invitations could not be loaded.');
        });
      }
    }
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expiresAt),
    );
    if (time == null || !mounted) return;
    setState(() => _expiresAt = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ));
  }

  Future<void> _create() async {
    final strings = context.strings;
    final phone = _phone.text.replaceAll(RegExp(r'[\s()-]'), '');
    if (!RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(phone)) {
      setState(() => _error = strings.t('invalidPhone'));
      return;
    }
    if (!_expiresAt.isAfter(DateTime.now()) ||
        _expiresAt.isAfter(DateTime.now().add(const Duration(days: 30)))) {
      setState(() => _error = strings.t('expiresAt'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final bootstrap = await ref.read(bootstrapProvider.future);
      final invitation = await ref.read(repositoryProvider).createInvitation({
        'business': bootstrap.businessId,
        'invitee_phone': phone,
        'role': _role,
        'locations': _selectedLocations.toList(),
        'expires_at': _expiresAt.toUtc().toIso8601String(),
      });
      if (!mounted) return;
      setState(() {
        _created = invitation;
        _invitations = [invitation, ..._invitations];
        _phone.clear();
        _selectedLocations.clear();
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error =
            describeDioError(error, 'The invitation could not be created.'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _revoke(Invitation invitation) async {
    final strings = context.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.t('revokeInvitationTitle')),
        content: Text(strings.t('revokeInvitationDetail')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.t('revoke')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final revoked =
          await ref.read(repositoryProvider).revokeInvitation(invitation.id);
      if (!mounted) return;
      setState(() {
        _invitations = [
          for (final item in _invitations)
            if (item.id == revoked.id) revoked else item,
        ];
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.t('invitationRevoked'))));
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              describeDioError(error, 'The invitation could not be revoked.')),
        ));
      }
    }
  }

  Future<void> _copyToken(String token) async {
    await Clipboard.setData(ClipboardData(text: token));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.t('tokenCopied'))));
  }

  Future<void> _shareInvitation(Invitation invitation) async {
    final token = invitation.token;
    if (token == null) return;
    try {
      await ref.read(appShareServiceProvider).shareText(
            'DukaanAI invitation for ${invitation.inviteePhone}\n'
            'Token: $token\n'
            'Expires: ${invitation.expiresAt.toIso8601String()}\n'
            'Sign in with the invited mobile number, then accept it in Settings.',
          );
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              describeDioError(error, 'The invitation could not be shared.')),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    if (_loading) return const LoadingContent();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (_error != null) ...[
            _ErrorBanner(_error!),
            const SizedBox(height: DukaanTokens.space3),
          ],
          if (_created?.token case final token?) ...[
            DukaanCard(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(strings.t('oneTimeToken'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: DukaanTokens.space1),
                  Text(strings.t('invitationTokenWarning')),
                  const SizedBox(height: DukaanTokens.space3),
                  SelectableText(
                    token,
                    style: DukaanTokens.textAmount,
                  ),
                  const SizedBox(height: DukaanTokens.space3),
                  Wrap(
                    spacing: DukaanTokens.space2,
                    children: [
                      OutlinedButton.icon(
                        key: const Key('invitation-copy-token'),
                        onPressed: () => _copyToken(token),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: Text(strings.t('copyToken')),
                      ),
                      FilledButton.icon(
                        key: const Key('invitation-share-token'),
                        onPressed: () => _shareInvitation(_created!),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(strings.t('shareInvitation')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: DukaanTokens.space4),
          ],
          DukaanCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(strings.t('createInvitation'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: DukaanTokens.space3),
                DukaanField(
                  label: strings.t('inviteePhone'),
                  child: TextField(
                    key: const Key('invitation-phone'),
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    enabled: !_saving,
                    decoration:
                        const InputDecoration(hintText: '+91 98765 43210'),
                  ),
                ),
                const SizedBox(height: DukaanTokens.space3),
                DukaanField(
                  label: strings.t('role'),
                  child: DropdownButtonFormField<String>(
                    key: const Key('invitation-role'),
                    initialValue: _role,
                    items: const [
                      DropdownMenuItem(
                          value: 'CASHIER', child: Text('Cashier')),
                      DropdownMenuItem(
                          value: 'MANAGER', child: Text('Manager')),
                      DropdownMenuItem(value: 'OWNER', child: Text('Owner')),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _role = value ?? 'CASHIER'),
                  ),
                ),
                const SizedBox(height: DukaanTokens.space3),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    onPressed: _saving ? null : _pickExpiry,
                    icon: const Icon(Icons.event_rounded, size: 18),
                    label: Text('${strings.t('expiresAt')}: '
                        '${formatDateTime(_expiresAt, Localizations.localeOf(context).languageCode)}'),
                  ),
                ),
                if (_locations.isNotEmpty) ...[
                  const SizedBox(height: DukaanTokens.space3),
                  Text(strings.t('locationsOptional'),
                      style: DukaanTokens.textLabel),
                  for (final location in _locations)
                    Material(
                      color: Colors.transparent,
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(location.name),
                        value: _selectedLocations.contains(location.id),
                        onChanged: _saving
                            ? null
                            : (checked) => setState(() {
                                  if (checked == true) {
                                    _selectedLocations.add(location.id);
                                  } else {
                                    _selectedLocations.remove(location.id);
                                  }
                                }),
                      ),
                    ),
                ],
                const SizedBox(height: DukaanTokens.space3),
                FilledButton.icon(
                  key: const Key('invitation-create'),
                  onPressed: _saving ? null : _create,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.group_add_outlined, size: 18),
                  label: Text(strings.t('createInvitation')),
                ),
              ],
            ),
          ),
          const SizedBox(height: DukaanTokens.space6),
          Text(strings.t('invitations'),
              style: Theme.of(context).textTheme.titleMedium),
          if (_invitations.isEmpty)
            DukaanEmptyState(
              icon: Icons.group_off_outlined,
              title: strings.t('noInvitations'),
              detail: strings.t('noInvitationsDetail'),
            )
          else
            for (final invitation in _invitations)
              _InvitationCard(
                invitation: invitation,
                onRevoke: () => _revoke(invitation),
              ),
        ],
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({required this.invitation, required this.onRevoke});

  final Invitation invitation;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final statusKey = switch (invitation.status) {
      'PENDING' => 'pending',
      'ACCEPTED' => 'accepted',
      'REVOKED' => 'revokedStatus',
      'EXPIRED' => 'expired',
      _ => 'notAvailable',
    };
    return DukaanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  invitation.inviteePhone,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              DukaanBadge(strings.t(statusKey)),
            ],
          ),
          const SizedBox(height: DukaanTokens.space2),
          Text('${invitation.role} · ${strings.t('expiresAt')}: '
              '${formatDateTime(invitation.expiresAt, Localizations.localeOf(context).languageCode)}'),
          if (invitation.isPending) ...[
            const SizedBox(height: DukaanTokens.space2),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                key: Key('invitation-revoke-${invitation.id}'),
                onPressed: onRevoke,
                icon: const Icon(Icons.block_rounded, size: 18),
                label: Text(strings.t('revoke')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.text);

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
