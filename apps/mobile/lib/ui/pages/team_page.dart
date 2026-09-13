import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _teamProvider = FutureProvider<List<Membership>>((ref) async {
  final location = await ref.watch(activeLocationProvider.future);
  return ref.watch(repositoryProvider).listMemberships(businessId: location.businessId);
});

final _invitesProvider = FutureProvider<List<Invitation>>((ref) async {
  final location = await ref.watch(activeLocationProvider.future);
  return ref.watch(repositoryProvider).listInvitations(businessId: location.businessId);
});

class TeamPage extends ConsumerStatefulWidget {
  const TeamPage({super.key});

  @override
  ConsumerState<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends ConsumerState<TeamPage> {
  final _phone = TextEditingController();
  String _role = 'CASHIER';
  bool _saving = false;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    final phone = _phone.text.replaceAll(RegExp(r'[\s()-]'), '');
    if (phone.isEmpty) {
      setState(() => _error = context.strings.t('required'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _notice = null;
    });
    try {
      final location = await ref.read(activeLocationProvider.future);
      final created = await ref.read(repositoryProvider).createInvitation({
        'business': location.businessId,
        'phone_e164': phone,
        'role': _role,
        'locations': [location.id],
      });
      ref.invalidate(_invitesProvider);
      if (mounted) {
        setState(() {
          _notice =
              '${context.strings.t('inviteSent')} ${created['token'] ?? ''}'.trim();
          _phone.clear();
        });
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _revokeMember(Membership member) async {
    final strings = context.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.t('revokeAccess')),
        content: Text(strings.t('revokeAccessConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.t('revokeAccess')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(repositoryProvider).revokeMembership(member.id);
      ref.invalidate(_teamProvider);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final members = ref.watch(_teamProvider);
    final invites = ref.watch(_invitesProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Text(
          strings.t('team'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.t('inviteMember'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: strings.t('phoneNumber')),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: InputDecoration(labelText: strings.t('partyKind')),
                  items: [
                    DropdownMenuItem(
                      value: 'MANAGER',
                      child: Text(strings.t('roleManager')),
                    ),
                    DropdownMenuItem(
                      value: 'CASHIER',
                      child: Text(strings.t('roleCashier')),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _role = value);
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                if (_notice != null) ...[
                  const SizedBox(height: 8),
                  SelectableText(_notice!),
                ],
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _invite,
                  child: Text(strings.t('inviteMember')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.t('pendingInvites'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        invites.when(
          loading: () => const LoadingContent(),
          error: (error, _) => ErrorContent(
            message: error.toString(),
            onRetry: () => ref.invalidate(_invitesProvider),
          ),
          data: (items) => items.isEmpty
              ? Text(strings.t('noPendingInvites'))
              : Card(
                  child: Column(
                    children: [
                      for (final invite in items)
                        ListTile(
                          title: Text(invite.phone),
                          subtitle: Text(invite.role),
                          trailing: IconButton(
                            tooltip: strings.t('revokeInvite'),
                            icon: const Icon(Icons.cancel_outlined),
                            onPressed: () async {
                              await ref
                                  .read(repositoryProvider)
                                  .revokeInvitation(invite.id);
                              ref.invalidate(_invitesProvider);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        members.when(
          loading: () => const LoadingContent(),
          error: (error, _) => ErrorContent(
            message: error.toString(),
            onRetry: () => ref.invalidate(_teamProvider),
          ),
          data: (items) => items.isEmpty
              ? Text(strings.t('noTeamMembers'))
              : Card(
                  child: Column(
                    children: [
                      for (final member in items)
                        ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              (member.userName.isNotEmpty
                                      ? member.userName
                                      : member.role.isNotEmpty
                                          ? member.role
                                          : '?')
                                  .characters
                                  .first
                                  .toUpperCase(),
                            ),
                          ),
                          title: Text(
                            member.userName.isNotEmpty ? member.userName : member.userPhone,
                          ),
                          subtitle: Text(member.role),
                          trailing: member.role == 'OWNER'
                              ? null
                              : IconButton(
                                  tooltip: strings.t('revokeAccess'),
                                  icon: const Icon(Icons.person_remove_outlined),
                                  onPressed: () => _revokeMember(member),
                                ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
