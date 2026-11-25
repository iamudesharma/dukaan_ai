import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/data/sharing_service.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:dukaan_ai_mobile/ui/pages/operation_forms_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _EntryAction { receipt, purchase, expense, payment, transfer }

class EntriesPage extends ConsumerStatefulWidget {
  const EntriesPage({super.key});

  @override
  ConsumerState<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends ConsumerState<EntriesPage> {
  EntryType? _filter;
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(entriesProvider);
    final drafts =
        ref.watch(localDraftsProvider).valueOrNull ?? const <LocalDraft>[];
    final strings = context.strings;
    final role = ref.watch(currentBusinessRoleProvider);
    final visibleTypes =
        role.canManageOperations ? EntryType.values : const [EntryType.sale];
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
              DukaanKicker('01 · ${strings.t('entries')}'),
              const SizedBox(height: DukaanTokens.space1),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.t('entries'),
                      style: DukaanTokens.textDisplay.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    key: const Key('new-sale-button'),
                    onPressed: () => context.go('/sale/new'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(strings.t('manualSale')),
                  ),
                  PopupMenuButton<_EntryAction>(
                    key: const Key('entries-more-actions'),
                    tooltip: strings.t('moreEntries'),
                    onSelected: (action) {
                      switch (action) {
                        case _EntryAction.receipt:
                          context.go('/payment/new');
                        case _EntryAction.purchase:
                          context.go('/purchase/new');
                        case _EntryAction.expense:
                          context.go('/expense/new');
                        case _EntryAction.payment:
                          context.go('/payment/new');
                        case _EntryAction.transfer:
                          context.go('/transfer/new');
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        key: const Key('entry-action-receipt'),
                        value: _EntryAction.receipt,
                        child: Text(strings.t('receipt')),
                      ),
                      if (role.canManageOperations) ...[
                        PopupMenuItem(
                          key: const Key('entry-action-purchase'),
                          value: _EntryAction.purchase,
                          child: Text(strings.t('purchase')),
                        ),
                        PopupMenuItem(
                          key: const Key('entry-action-expense'),
                          value: _EntryAction.expense,
                          child: Text(strings.t('expense')),
                        ),
                        PopupMenuItem(
                          key: const Key('entry-action-payment'),
                          value: _EntryAction.payment,
                          child: Text(strings.t('supplierPayment')),
                        ),
                        PopupMenuItem(
                          key: const Key('entry-action-transfer'),
                          value: _EntryAction.transfer,
                          child: Text(strings.t('stockTransfer')),
                        ),
                      ],
                    ],
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ],
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
            padding:
                const EdgeInsets.symmetric(horizontal: DukaanTokens.space4),
            scrollDirection: Axis.horizontal,
            children: [
              _chip(strings.t('all'), null),
              _chip(strings.t('sales'), EntryType.sale),
              if (role.canManageOperations) ...[
                _chip(strings.t('purchases'), EntryType.purchase),
                _chip(strings.t('expenses'), EntryType.expense),
                _chip(strings.t('payments'), EntryType.payment),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DukaanTokens.space4,
            DukaanTokens.space2,
            DukaanTokens.space4,
            DukaanTokens.space1,
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              hintText: strings.t('searchEntries'),
              suffixIcon: _search.isEmpty
                  ? null
                  : IconButton(
                      tooltip: strings.t('cancel'),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _search = '');
                      },
                      icon: const Icon(Icons.clear_rounded, size: 20),
                    ),
            ),
            onChanged: (value) => setState(() => _search = value),
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
              final query = _search.trim().toLowerCase();
              final byType = items
                  .where((item) =>
                      visibleTypes.contains(item.type) &&
                      (_filter == null || item.type == _filter))
                  .toList();
              final visible = query.isEmpty
                  ? byType
                  : byType
                      .where((item) => '${item.partyName} ${item.reference}'
                          .toLowerCase()
                          .contains(query))
                      .toList();
              final matchingDrafts = drafts.where((draft) {
                if (!_canSeeDraft(draft, role)) return false;
                final draftType = _entryTypeForDraft(draft);
                if (_filter != null && draftType != _filter) return false;
                return query.isEmpty ||
                    draft.label.toLowerCase().contains(query);
              }).toList();
              if (visible.isEmpty && matchingDrafts.isEmpty) {
                return DukaanEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: strings.t('noEntries'),
                  detail: strings.t('noEntriesDetail'),
                );
              }
              // One lazily-built list: drafts first, then entries. A Column
              // with hundreds of rows janks and balloons memory on low-end
              // phones; the builder only inflates what is on screen.
              final draftItemCount =
                  matchingDrafts.isEmpty ? 0 : matchingDrafts.length + 1;
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(entriesProvider);
                  ref.invalidate(localDraftsProvider);
                  await ref.read(entriesProvider.future);
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    DukaanTokens.space4,
                    DukaanTokens.space2,
                    DukaanTokens.space4,
                    DukaanTokens.space6,
                  ),
                  itemCount: draftItemCount + visible.length,
                  itemBuilder: (context, index) {
                    if (index < draftItemCount) {
                      if (index == 0) {
                        return _DraftsHeader(count: matchingDrafts.length);
                      }
                      return _DraftCard(draft: matchingDrafts[index - 1]);
                    }
                    return _EntryCard(entry: visible[index - draftItemCount]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, EntryType? value) => Padding(
        padding: const EdgeInsets.only(right: DukaanTokens.space2),
        child: DukaanFilterChip(
          label: label,
          selected: _filter == value,
          onSelected: () => setState(() => _filter = value),
        ),
      );
}

EntryType? _entryTypeForDraft(LocalDraft draft) => switch (draft.kind) {
      DraftKind.assistant => null,
      DraftKind.sale => EntryType.sale,
      DraftKind.purchase => EntryType.purchase,
      DraftKind.expense => EntryType.expense,
      DraftKind.payment => EntryType.payment,
      DraftKind.transfer => null,
    };

bool _canSeeDraft(LocalDraft draft, BusinessRole role) {
  if (role.canManageOperations) return true;
  if (draft.kind == DraftKind.sale || draft.kind == DraftKind.assistant) {
    return true;
  }
  if (draft.kind != DraftKind.payment) return false;
  final payload = draft.payload['payload'];
  return payload is Map && payload['direction'] == 'RECEIPT';
}

String _draftLabelKey(LocalDraft draft) => switch (draft.kind) {
      DraftKind.assistant => 'assistantDraft',
      DraftKind.sale => 'saleDraft',
      DraftKind.purchase => 'purchaseDraft',
      DraftKind.expense => 'expenseDraft',
      DraftKind.payment =>
        _isReceiptDraft(draft) ? 'receiptDraft' : 'paymentDraft',
      DraftKind.transfer => 'transferDraft',
    };

bool _isReceiptDraft(LocalDraft draft) {
  final payload = draft.payload['payload'];
  return payload is Map && payload['direction'] == 'RECEIPT';
}

class _DraftsHeader extends StatelessWidget {
  const _DraftsHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Padding(
      padding: const EdgeInsets.only(bottom: DukaanTokens.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count ${strings.t('draftsWaiting')}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            strings.t('reviewDraftDetail'),
            style: DukaanTokens.textCaption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends ConsumerStatefulWidget {
  const _DraftCard({required this.draft});

  final LocalDraft draft;

  @override
  ConsumerState<_DraftCard> createState() => _DraftCardState();
}

class _DraftCardState extends ConsumerState<_DraftCard> {
  bool _reviewing = false;

  LocalDraft get draft => widget.draft;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final sync = ref.watch(draftSyncProvider);
    final syncError = sync.errors[draft.id];
    final busy = sync.busy || _reviewing;

    return Padding(
      padding: const EdgeInsets.only(bottom: DukaanTokens.space2),
      child: DukaanCard(
        color: scheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(
          horizontal: DukaanTokens.space4,
          vertical: DukaanTokens.space3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const DukaanIconPlate(
                  icon: Icons.edit_note_rounded,
                  tone: DukaanTone.neutral,
                ),
                const SizedBox(width: DukaanTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        draft.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${context.strings.t(_draftLabelKey(draft))} · '
                        '${formatDateTime(draft.createdAt, locale)}',
                        style: DukaanTokens.textCaption.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (syncError != null) ...[
              const SizedBox(height: DukaanTokens.space2),
              Text(
                syncError,
                style: DukaanTokens.textCaption.copyWith(color: scheme.error),
              ),
            ],
            const SizedBox(height: DukaanTokens.space2),
            Wrap(
              spacing: DukaanTokens.space2,
              runSpacing: DukaanTokens.space2,
              children: [
                OutlinedButton.icon(
                  key: Key('review-draft-${draft.id}'),
                  onPressed: busy ? null : _review,
                  icon: _reviewing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.fact_check_outlined, size: 18),
                  label: Text(context.strings.t('review')),
                ),
                TextButton.icon(
                  onPressed: busy ? null : _discard,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(context.strings.t('discard')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _review() async {
    if (draft.kind == DraftKind.sale) {
      SaleDraft sale;
      try {
        sale =
            SaleDraft.fromLocalJson(Map<String, dynamic>.from(draft.payload));
      } on Object catch (error) {
        _showMessage(error.toString());
        return;
      }
      final sent = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _SaleDraftReviewSheet(draft: draft, sale: sale),
      );
      if (sent == true && mounted) {
        _showMessage(context.strings.t('draftSent'));
      }
      return;
    }

    if (draft.kind != DraftKind.assistant) {
      OperationDraft operation;
      try {
        operation = OperationDraft.fromLocalJson(draft.payload);
        if (!operation.canBeRecordedBy(ref.read(currentBusinessRoleProvider))) {
          throw StateError(
              'Your current role cannot send this operation. Cashiers can send receipts only.');
        }
      } on Object catch (error) {
        _showMessage(error.toString());
        return;
      }
      final sent = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _OperationDraftReviewSheet(draft: draft),
      );
      if (sent == true && mounted) {
        _showMessage(context.strings.t('draftOperationSent'));
      }
      return;
    }

    setState(() => _reviewing = true);
    final result =
        await ref.read(draftSyncProvider.notifier).reviewAssistantDraft(draft);
    if (!mounted) return;
    setState(() => _reviewing = false);
    ref.read(assistantControllerProvider.notifier).openDraftReview(
          draft,
          proposal: result.proposal,
          error: result.error,
        );
    context.go('/ask');
  }

  Future<void> _discard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.strings.t('discardDraft')),
        content: Text(context.strings.t('discardDraftDetail')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.strings.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.strings.t('discard')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(draftSyncProvider.notifier).discardDraft(draft);
      if (mounted) _showMessage(context.strings.t('draftDiscarded'));
    } on Object catch (error) {
      if (mounted) _showMessage(error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OperationDraftReviewSheet extends ConsumerStatefulWidget {
  const _OperationDraftReviewSheet({required this.draft});

  final LocalDraft draft;

  @override
  ConsumerState<_OperationDraftReviewSheet> createState() =>
      _OperationDraftReviewSheetState();
}

class _OperationDraftReviewSheetState
    extends ConsumerState<_OperationDraftReviewSheet> {
  bool _sending = false;
  String? _error;

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await ref
        .read(draftSyncProvider.notifier)
        .sendOperationDraft(widget.draft);
    if (!mounted) return;
    if (result.synced) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _sending = false;
      _error = result.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final operation = OperationDraft.fromLocalJson(widget.draft.payload);
    final parties = operation.kind == OperationKind.purchase ||
            operation.kind == OperationKind.payment
        ? ref.watch(partiesProvider).valueOrNull ?? const <Party>[]
        : const <Party>[];
    final products = operation.kind == OperationKind.purchase ||
            operation.kind == OperationKind.transfer
        ? ref.watch(productsProvider).valueOrNull ?? const <Product>[]
        : const <Product>[];
    final locations = operation.kind == OperationKind.transfer
        ? ref.watch(locationsProvider).valueOrNull ?? const <BusinessLocation>[]
        : const <BusinessLocation>[];
    final online = ref.watch(networkStatusProvider).valueOrNull ?? false;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          DukaanTokens.space4,
          DukaanTokens.space2,
          DukaanTokens.space4,
          DukaanTokens.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.strings.t('reviewTitle'),
              style: DukaanTokens.textTitle,
            ),
            const SizedBox(height: DukaanTokens.space1),
            Text(
              context.strings.t('operationNotRecorded'),
              style: DukaanTokens.textCaption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DukaanTokens.space4),
            OperationReviewCard(
              draft: operation,
              partyNames: {for (final party in parties) party.id: party.name},
              productNames: {
                for (final product in products) product.packId: product.name,
              },
              locationNames: {
                for (final location in locations) location.id: location.name,
              },
            ),
            if (!online) ...[
              const SizedBox(height: DukaanTokens.space3),
              Text(
                context.strings.t('draftSendOfflineOperation'),
                style: DukaanTokens.textLabel.copyWith(color: scheme.error),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: DukaanTokens.space2),
              Text(
                _error!,
                style: DukaanTokens.textCaption.copyWith(color: scheme.error),
              ),
            ],
            const SizedBox(height: DukaanTokens.space4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: Key('send-operation-draft-${widget.draft.id}'),
                onPressed: online && !_sending ? _send : null,
                icon: _sending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(context.strings.t('sendDraft')),
              ),
            ),
            TextButton(
              onPressed: _sending ? null : () => Navigator.of(context).pop(),
              child: Text(context.strings.t('close')),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleDraftReviewSheet extends ConsumerStatefulWidget {
  const _SaleDraftReviewSheet({required this.draft, required this.sale});

  final LocalDraft draft;
  final SaleDraft sale;

  @override
  ConsumerState<_SaleDraftReviewSheet> createState() =>
      _SaleDraftReviewSheetState();
}

class _SaleDraftReviewSheetState extends ConsumerState<_SaleDraftReviewSheet> {
  bool _sending = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final online = ref.watch(networkStatusProvider).valueOrNull ?? false;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          DukaanTokens.space4,
          DukaanTokens.space2,
          DukaanTokens.space4,
          DukaanTokens.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.strings.t('reviewTitle'),
              style: DukaanTokens.textTitle,
            ),
            const SizedBox(height: DukaanTokens.space1),
            Text(
              context.strings.t('saleNotRecorded'),
              style: DukaanTokens.textCaption.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DukaanTokens.space4),
            DukaanCard(
              child: Column(
                children: [
                  _ReviewRow(
                    label: context.strings.t('customerOptional'),
                    value: widget.sale.customerName ?? 'Walk-in',
                  ),
                  for (final line in widget.sale.lines)
                    _ReviewRow(
                      label: line.productName,
                      value:
                          '${line.quantity} × ${formatMoney(line.unitPriceMinor, locale)}',
                    ),
                  _ReviewRow(
                    label: context.strings.t('total'),
                    value: formatMoney(widget.sale.totalMinor, locale),
                    strong: true,
                  ),
                  _ReviewRow(
                    label: context.strings.t('paidNow'),
                    value: formatMoney(widget.sale.paidAmountMinor, locale),
                  ),
                  _ReviewRow(
                    label: context.strings.t('pending'),
                    value: formatMoney(widget.sale.pendingMinor, locale),
                    warning: widget.sale.pendingMinor > 0,
                  ),
                ],
              ),
            ),
            if (!online) ...[
              const SizedBox(height: DukaanTokens.space3),
              Text(
                context.strings.t('draftSendOffline'),
                style: DukaanTokens.textLabel.copyWith(color: scheme.error),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: DukaanTokens.space2),
              Text(
                _error!,
                style: DukaanTokens.textCaption.copyWith(color: scheme.error),
              ),
            ],
            const SizedBox(height: DukaanTokens.space4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: Key('send-sale-draft-${widget.draft.id}'),
                onPressed: online && !_sending ? _send : null,
                icon: _sending
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(context.strings.t('sendSale')),
              ),
            ),
            TextButton(
              onPressed: _sending ? null : () => Navigator.of(context).pop(),
              child: Text(context.strings.t('close')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final result =
        await ref.read(draftSyncProvider.notifier).sendSaleDraft(widget.draft);
    if (!mounted) return;
    if (result.synced) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _sending = false;
      _error = result.error;
    });
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.warning = false,
  });

  final String label;
  final String value;
  final bool strong;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: DukaanTokens.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: DukaanTokens.textLabel
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: DukaanTokens.space3),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: (strong
                      ? DukaanTokens.textAmountLarge
                      : DukaanTokens.textAmount)
                  .copyWith(
                color: warning ? scheme.onTertiaryContainer : scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final BusinessEntry entry;

  @override
  Widget build(BuildContext context) {
    return _EntryRow(entry: entry);
  }
}

class _EntryRow extends ConsumerStatefulWidget {
  const _EntryRow({required this.entry});

  final BusinessEntry entry;

  @override
  ConsumerState<_EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends ConsumerState<_EntryRow> {
  bool _downloading = false;

  BusinessEntry get entry => widget.entry;

  Future<void> _downloadShareInvoice() async {
    final strings = context.strings;
    setState(() => _downloading = true);
    try {
      final invoice =
          await ref.read(repositoryProvider).fetchSaleInvoicePdf(entry.id);
      await ref.read(appShareServiceProvider).shareFile(
            filename: invoice.filename,
            bytes: invoice.bytes,
            mimeType: 'application/pdf',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.t('invoicePdfReady'))),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(describeDioError(error, strings.t('invoicePdfFailed'))),
        ));
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final scheme = Theme.of(context).colorScheme;
    final online = ref.watch(networkStatusProvider).valueOrNull ?? false;
    final (label, icon, tone) = switch (entry.type) {
      EntryType.sale => (
          context.strings.t('sales'),
          Icons.arrow_outward_rounded,
          DukaanTone.positive,
        ),
      EntryType.purchase => (
          context.strings.t('purchases'),
          Icons.shopping_bag_outlined,
          DukaanTone.attention,
        ),
      EntryType.expense => (
          context.strings.t('expenses'),
          Icons.receipt_outlined,
          DukaanTone.attention,
        ),
      EntryType.payment => (
          context.strings.t('payments'),
          Icons.payments_outlined,
          DukaanTone.primary,
        ),
    };
    final amount = formatMoney(entry.totalMinor, locale);

    return Semantics(
      label: '$label, ${entry.partyName}, $amount, ${entry.reference}',
      child: DukaanListRow(
        showDivider: false,
        leading: DukaanIconPlate(icon: icon, tone: tone),
        title: entry.partyName,
        subtitle: '$label · ${entry.reference}\n'
            '${formatDateTime(entry.occurredAt, locale)}',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DukaanMoney(amount),
                if (entry.pendingMinor > 0) ...[
                  const SizedBox(height: DukaanTokens.space1),
                  Text(
                    '${context.strings.t('pending')} '
                    '${formatMoney(entry.pendingMinor, locale)}',
                    style: DukaanTokens.textCaption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: DukaanTokens.space1),
                  const DukaanBadge('Paid', tone: DukaanTone.positive),
                ],
              ],
            ),
            if (entry.type == EntryType.sale)
              IconButton(
                key: Key('sale-invoice-${entry.id}'),
                tooltip: context.strings.t('downloadShareInvoice'),
                onPressed:
                    online && !_downloading ? _downloadShareInvoice : null,
                icon: _downloading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
