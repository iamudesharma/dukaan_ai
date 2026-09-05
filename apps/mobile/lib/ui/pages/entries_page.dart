import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EntriesPage extends ConsumerStatefulWidget {
  const EntriesPage({super.key});

  @override
  ConsumerState<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends ConsumerState<EntriesPage> {
  EntryType? _filter;

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(entriesProvider);
    final drafts = ref.watch(localDraftsProvider).valueOrNull ?? const <LocalDraft>[];
    final strings = context.strings;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  strings.t('entries'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              FilledButton.icon(
                key: const Key('new-sale-button'),
                onPressed: () => context.go('/sale/new'),
                icon: const Icon(Icons.add_rounded),
                label: Text(strings.t('manualSale')),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: strings.t('all'),
                selected: _filter == null,
                onSelected: () => setState(() => _filter = null),
              ),
              _FilterChip(
                label: strings.t('sales'),
                selected: _filter == EntryType.sale,
                onSelected: () => setState(() => _filter = EntryType.sale),
              ),
              _FilterChip(
                label: strings.t('purchases'),
                selected: _filter == EntryType.purchase,
                onSelected: () => setState(() => _filter = EntryType.purchase),
              ),
              _FilterChip(
                label: strings.t('expenses'),
                selected: _filter == EntryType.expense,
                onSelected: () => setState(() => _filter = EntryType.expense),
              ),
              _FilterChip(
                label: strings.t('payments'),
                selected: _filter == EntryType.payment,
                onSelected: () => setState(() => _filter = EntryType.payment),
              ),
            ],
          ),
        ),
        Expanded(
          child: entries.when(
            loading: () => const LoadingContent(),
            error: (error, _) => ErrorContent(
              message: error.toString(),
              onRetry: () => ref.invalidate(entriesProvider),
            ),
            data: (items) {
              final filtered =
                  _filter == null ? items : items.where((item) => item.type == _filter).toList();
              if (filtered.isEmpty && drafts.isEmpty) {
                return _EmptyEntries(onAdd: () => context.go('/ask'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(entriesProvider);
                  ref.invalidate(localDraftsProvider);
                  await ref.read(entriesProvider.future);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    if (drafts.isNotEmpty && _filter == null) ...[
                      Text(
                        '${drafts.length} ${strings.t('draftsWaiting')}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...drafts.map((draft) => _DraftCard(draft: draft)),
                      const SizedBox(height: 10),
                    ],
                    ...filtered.map((entry) => _EntryCard(entry: entry)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _DraftCard extends ConsumerWidget {
  const _DraftCard({required this.draft});

  final LocalDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: ListTile(
          minTileHeight: 72,
          leading: const Icon(Icons.edit_note_rounded),
          title: Text(
            draft.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${context.strings.t('offline')} · ${formatDateTime(draft.createdAt, locale)}',
          ),
          trailing: IconButton(
            tooltip: context.strings.t('cancel'),
            onPressed: () async {
              await ref.read(draftStoreProvider).deleteDraft(draft.id);
              ref.invalidate(localDraftsProvider);
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ),
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final BusinessEntry entry;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final (label, icon) = switch (entry.type) {
      EntryType.sale => (context.strings.t('sales'), Icons.arrow_outward_rounded),
      EntryType.purchase => (context.strings.t('purchases'), Icons.shopping_bag_outlined),
      EntryType.expense => (context.strings.t('expenses'), Icons.receipt_outlined),
      EntryType.payment => (context.strings.t('payments'), Icons.payments_outlined),
    };
    final amount = formatMoney(entry.totalMinor, locale);
    return Semantics(
      label: '$label, ${entry.partyName}, $amount, ${entry.reference}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: ListTile(
            minTileHeight: 78,
            leading: CircleAvatar(child: Icon(icon)),
            title: Text(
              entry.partyName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '$label · ${entry.reference}\n${formatDateTime(entry.occurredAt, locale)}',
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount, style: const TextStyle(fontWeight: FontWeight.w800)),
                if (entry.pendingMinor > 0)
                  Text(
                    '${context.strings.t('pending')} ${formatMoney(entry.pendingMinor, locale)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyEntries extends StatelessWidget {
  const _EmptyEntries({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 52),
            const SizedBox(height: 12),
            Text(
              context.strings.t('noEntries'),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              context.strings.t('noEntriesDetail'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(context.strings.t('ask')),
            ),
          ],
        ),
      ),
    );
  }
}

