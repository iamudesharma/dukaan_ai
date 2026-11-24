import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:dukaan_ai_mobile/ui/pages/invitation_acceptance_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.strings;
    final role = ref.watch(currentBusinessRoleProvider);
    final user = ref.watch(currentUserProvider);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        DukaanTokens.space4,
        DukaanTokens.space4,
        DukaanTokens.space4,
        DukaanTokens.space6,
      ),
      children: [
        DukaanKicker(strings.t('accountSettings')),
        const SizedBox(height: DukaanTokens.space1),
        Text(
          strings.t('settings'),
          style: DukaanTokens.textDisplay.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: DukaanTokens.space4),
        DukaanCard(
          child: user.when(
            loading: () => const LoadingContent(),
            error: (_, __) => Text(strings.t('account')),
            data: (account) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.displayName.isEmpty
                      ? strings.t('account')
                      : account.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (account.phone.isNotEmpty) ...[
                  const SizedBox(height: DukaanTokens.space1),
                  Text(
                    account.phone,
                    style: DukaanTokens.textCaption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: DukaanTokens.space6),
        DukaanSectionHeader(
          kicker: '01 · ${strings.t('account')}',
          title: strings.t('security'),
          ruled: true,
        ),
        _SettingsRow(
          icon: Icons.security_rounded,
          title: strings.t('security'),
          subtitle: strings.t('securityDetail'),
          onTap: () => context.go('/settings/security'),
        ),
        _SettingsRow(
          icon: Icons.mark_email_read_outlined,
          title: strings.t('acceptInvitation'),
          subtitle: strings.t('acceptInvitationDetail'),
          onTap: () => context.go('/settings/invitations/accept'),
        ),
        const SizedBox(height: DukaanTokens.space6),
        if (role == BusinessRole.owner) ...[
          DukaanSectionHeader(
            kicker: '02 · ${strings.t('ownerOnly')}',
            title: strings.t('invitationManagement'),
            ruled: true,
          ),
          _SettingsRow(
            icon: Icons.group_add_outlined,
            title: strings.t('invitationManagement'),
            subtitle: strings.t('invitationManagementDetail'),
            onTap: () => context.go('/settings/invitations'),
          ),
          const SizedBox(height: DukaanTokens.space6),
        ],
        if (role.canManageOperations) ...[
          DukaanSectionHeader(
            kicker: '03 · ${strings.t('managerOnly')}',
            title: strings.t('imports'),
            ruled: true,
          ),
          _SettingsRow(
            icon: Icons.upload_file_rounded,
            title: strings.t('importCsv'),
            subtitle: strings.t('importCsvDetail'),
            onTap: () => context.go('/settings/imports'),
          ),
          _SettingsRow(
            icon: Icons.inventory_rounded,
            title: strings.t('valuation'),
            subtitle: strings.t('valuationDetail'),
            onTap: () => context.go('/settings/valuation'),
          ),
          _SettingsRow(
            icon: Icons.account_balance_wallet_outlined,
            title: strings.t('paymentAllocations'),
            subtitle: strings.t('allocationReviewDetail'),
            onTap: () => context.go('/settings/allocations'),
          ),
          const SizedBox(height: DukaanTokens.space6),
        ],
        DukaanSectionHeader(
          kicker: '04 · ${strings.t('notificationDevices')}',
          title: strings.t('reminders'),
          ruled: true,
        ),
        _SettingsRow(
          icon: Icons.notifications_none_rounded,
          title: strings.t('reminders'),
          subtitle: strings.t('reminderDetail'),
          onTap: () => context.go('/settings/reminders'),
        ),
        _SettingsRow(
          icon: Icons.devices_rounded,
          title: strings.t('notificationDevices'),
          subtitle: strings.t('notificationDevicesDetail'),
          onTap: () => context.go('/settings/devices'),
        ),
        const SizedBox(height: DukaanTokens.space6),
        DukaanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const InvitationAcceptancePanel(compact: true),
              const SizedBox(height: DukaanTokens.space4),
              OutlinedButton.icon(
                key: const Key('settings-sign-out'),
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(strings.t('signOut')),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => DukaanListRow(
        leading: DukaanIconPlate(icon: icon),
        title: title,
        subtitle: subtitle,
        trailing: const Icon(Icons.chevron_right_rounded, size: 18),
        onTap: onTap,
      );
}
