import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.strings.t('parties'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _PartyFilter(
                label: context.strings.t('all'),
                selected: _filter == null,
                onTap: () => setState(() => _filter = null),
              ),
              _PartyFilter(
                label: context.strings.t('customers'),
                selected: _filter == PartyKind.customer,
                onTap: () => setState(() => _filter = PartyKind.customer),
              ),
              _PartyFilter(
                label: context.strings.t('suppliers'),
                selected: _filter == PartyKind.supplier,
                onTap: () => setState(() => _filter = PartyKind.supplier),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Semantics(
            container: true,
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.strings.t('noMoneyMovement'),
                    style: Theme.of(context).textTheme.bodySmall,
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
                if (_filter == null || party.kind == PartyKind.both) return true;
                return party.kind == _filter;
              }).toList();
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(partiesProvider);
                  await ref.read(partiesProvider.future);
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _PartyCard(party: filtered[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PartyFilter extends StatelessWidget {
  const _PartyFilter({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );
}

class _PartyCard extends StatelessWidget {
  const _PartyCard({required this.party});

  final Party party;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final hasReceivable = party.toReceiveMinor > 0;
    final balanceLabel = hasReceivable
        ? context.strings.t('toReceive')
        : context.strings.t('toPay');
    final balance = hasReceivable ? party.toReceiveMinor : party.toPayMinor;
    final balanceText = formatMoney(balance, locale);
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      party.name.isEmpty ? '?' : party.name.characters.first.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(party.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        if (party.phone.isNotEmpty) Text(party.phone),
                      ],
                    ),
                  ),
                  Semantics(
                    label: '$balanceLabel, $balanceText',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ExcludeSemantics(
                          child: Text(
                            balanceText,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: hasReceivable
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        ExcludeSemantics(
                          child: Text(balanceLabel, style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasReceivable) ...[
                const Divider(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _shareReminder(context),
                    icon: const Icon(Icons.share_outlined),
                    label: Text(context.strings.t('shareReminder')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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

