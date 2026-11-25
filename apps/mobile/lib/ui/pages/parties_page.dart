import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class PartiesPage extends ConsumerStatefulWidget {
  const PartiesPage({super.key});

  @override
  ConsumerState<PartiesPage> createState() => _PartiesPageState();
}

class _PartiesPageState extends ConsumerState<PartiesPage> {
  PartyKind? _filter;

  @override
  Widget build(BuildContext context) {
    final parties = ref.watch(partiesProvider);
    final canViewSuppliers =
        ref.watch(currentBusinessRoleProvider).canViewSuppliers;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DukaanTokens.space4,
            DukaanTokens.space4,
            DukaanTokens.space4,
            DukaanTokens.space3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DukaanKicker('01 · ${context.strings.t('parties')}'),
              const SizedBox(height: DukaanTokens.space1),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.strings.t('parties'),
                  style: DukaanTokens.textDisplay.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: DukaanTokens.space2),
              const Divider(
                height: 1,
                thickness: 2,
                color: DukaanTokens.colorInk,
              ),
            ],
          ),
        ),
        SizedBox(
          height: DukaanTokens.space10,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: DukaanTokens.space4),
            children: [
              _filterChip(context.strings.t('all'), null),
              _filterChip(context.strings.t('customers'), PartyKind.customer),
              if (canViewSuppliers)
                _filterChip(context.strings.t('suppliers'), PartyKind.supplier),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DukaanTokens.space4,
            vertical: DukaanTokens.space3,
          ),
          child: Semantics(
            container: true,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: DukaanTokens.space2),
                Expanded(
                  child: Text(
                    context.strings.t('noMoneyMovement'),
                    style: DukaanTokens.textCaption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: parties.when(
            loading: () => const LoadingContent(),
            error: (error, _) => ErrorContent(
              message: error.toString(),
              onRetry: () => ref.invalidate(partiesProvider),
            ),
            data: (items) {
              final filtered = items.where((party) {
                if (!canViewSuppliers && party.kind == PartyKind.supplier) {
                  return false;
                }
                if (_filter == null || party.kind == PartyKind.both) {
                  return true;
                }
                return party.kind == _filter;
              }).toList();
              if (filtered.isEmpty) {
                return DukaanEmptyState(
                  icon: Icons.people_outline_rounded,
                  title: context.strings.t('noParties'),
                  detail: context.strings.t('noPartiesDetail'),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(partiesProvider);
                  await ref.read(partiesProvider.future);
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    DukaanTokens.space4,
                    0,
                    DukaanTokens.space4,
                    DukaanTokens.space6,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _PartyCard(
                    party: filtered[index],
                    showDivider: index > 0,
                    showPayable: canViewSuppliers,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, PartyKind? value) => Padding(
        padding: const EdgeInsets.only(right: DukaanTokens.space2),
        child: DukaanFilterChip(
          label: label,
          selected: _filter == value,
          onSelected: () => setState(() => _filter = value),
        ),
      );
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({
    required this.party,
    this.showDivider = true,
    this.showPayable = true,
  });

  final Party party;
  final bool showDivider;
  final bool showPayable;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final hasReceivable = party.toReceiveMinor > 0;
    final showBalanceDue = showPayable && !hasReceivable;
    // Owing a supplier is an outstanding balance, not a failure, so it reads
    // as attention rather than error red. Cashiers only see customer receivables.
    final balanceLabel = showBalanceDue
        ? context.strings.t('toPay')
        : context.strings.t('toReceive');
    final balance = showBalanceDue ? party.toPayMinor : party.toReceiveMinor;
    final balanceText = formatMoney(balance, locale);
    final tone = showBalanceDue ? DukaanTone.attention : DukaanTone.positive;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DukaanListRow(
          showDivider: showDivider,
          leading: Container(
            width: DukaanTokens.sizeTile,
            height: DukaanTokens.sizeTile,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(DukaanTokens.radiusControl),
            ),
            child: Text(
              party.name.isEmpty
                  ? '?'
                  : party.name.characters.first.toUpperCase(),
              style: DukaanTokens.textLabel.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          title: party.name,
          subtitle: party.phone.isEmpty ? null : party.phone,
          trailing: Semantics(
            label: '$balanceLabel, $balanceText',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: DukaanMoney(balanceText, tone: tone),
                ),
                ExcludeSemantics(
                  child: Text(
                    balanceLabel.toUpperCase(),
                    style: DukaanTokens.textCaption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasReceivable)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: DukaanTokens.space3,
                left: DukaanTokens.space4,
              ),
              child: OutlinedButton.icon(
                onPressed: () => _shareReminder(context),
                icon: const Icon(Icons.share_outlined, size: 18),
                label: Text(context.strings.t('shareReminder')),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _shareReminder(BuildContext context) async {
    final locale = Localizations.localeOf(context).languageCode;
    final message = locale == 'hi'
        ? 'नमस्ते ${party.name}, आपकी ${formatMoney(party.toReceiveMinor, locale)} की राशि बाकी है। कृपया सुविधा अनुसार भुगतान करें। — DukaanAI से साझा किया गया'
        : 'Hello ${party.name}, this is a reminder that ${formatMoney(party.toReceiveMinor, locale)} is pending. Please pay when convenient. — Shared from DukaanAI';
    await SharePlus.instance.share(ShareParams(text: message));
  }
}
