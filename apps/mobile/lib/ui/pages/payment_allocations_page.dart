import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/domain/backend_models.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/common/settings_page_layout.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class PaymentAllocationsPage extends ConsumerWidget {
  const PaymentAllocationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(currentBusinessRoleProvider).canManageOperations;
    return SettingsPageLayout(
      title: context.strings.t('allocationReview'),
      subtitle: context.strings.t('allocationReviewDetail'),
      child: ManagerOnlyGate(
        allowed: allowed,
        child: const _AllocationReview(),
      ),
    );
  }
}

class _AllocationReview extends ConsumerStatefulWidget {
  const _AllocationReview();

  @override
  ConsumerState<_AllocationReview> createState() => _AllocationReviewState();
}

class _AllocationReviewState extends ConsumerState<_AllocationReview> {
  String _direction = '';
  PaymentAllocationReview? _review;
  Map<String, String> _partyNames = const {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bootstrap = await ref.read(bootstrapProvider.future);
      final location = await ref.read(activeLocationProvider.future);
      final repository = ref.read(repositoryProvider);
      final results = await Future.wait([
        repository.fetchPaymentAllocationReview(
          businessId: bootstrap.businessId,
          locationId: location.id,
          direction: _direction.isEmpty ? null : _direction,
          status: 'POSTED',
        ),
        repository.fetchParties(location.id),
      ]);
      if (!mounted) return;
      setState(() {
        _review = results[0] as PaymentAllocationReview;
        _partyNames = {
          for (final party in results[1] as List<Party>) party.id: party.name,
        };
        _loading = false;
      });
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = describeDioError(
              error, 'Payment allocations could not be loaded.');
        });
      }
    }
  }

  Future<void> _openPayment(PaymentRecord payment) async {
    final review = _review;
    if (review == null) return;
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.9,
        child: ReallocationSheet(
          payment: payment,
          review: review,
          partyName: _partyNames[payment.partyId],
        ),
      ),
    );
    if (changed == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final locale = Localizations.localeOf(context).languageCode;
    if (_loading) return const LoadingContent();
    final review = _review;
    if (review == null) {
      return ErrorContent(message: _error, onRetry: _load);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          DukaanField(
            label: strings.t('direction'),
            child: DropdownButtonFormField<String>(
              key: const Key('allocation-direction'),
              initialValue: _direction,
              items: [
                DropdownMenuItem(value: '', child: Text(strings.t('all'))),
                DropdownMenuItem(
                    value: 'RECEIPT', child: Text(strings.t('receipts'))),
                DropdownMenuItem(
                    value: 'PAYMENT',
                    child: Text(strings.t('supplierPayments'))),
              ],
              onChanged: (value) {
                setState(() => _direction = value ?? '');
                _load();
              },
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: DukaanTokens.space3),
            _ErrorText(_error!),
          ],
          const SizedBox(height: DukaanTokens.space4),
          DukaanHeroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DukaanHeroEyebrow(strings.t('unallocated')),
                const SizedBox(height: DukaanTokens.space2),
                DukaanHeroText(
                  formatExactMoney(review.totals.unallocatedTotalMinor, locale),
                  style: DukaanTokens.textDisplay,
                ),
                const SizedBox(height: DukaanTokens.space2),
                DukaanHeroText(
                  '${review.totals.paymentCount} ${strings.t('paymentCount')} · '
                  '${formatExactMoney(review.totals.outstandingTotalMinor, locale)} ${strings.t('outstanding')}',
                  style: DukaanTokens.textCaption,
                ),
              ],
            ),
          ),
          const SizedBox(height: DukaanTokens.space4),
          DukaanCard(
            child: Column(
              children: [
                _ValueRow(
                  label: strings.t('payments'),
                  value:
                      formatExactMoney(review.totals.paymentTotalMinor, locale),
                ),
                _ValueRow(
                  label: strings.t('allocated'),
                  value: formatExactMoney(
                      review.totals.allocatedTotalMinor, locale),
                ),
                _ValueRow(
                  label: strings.t('unallocated'),
                  value: formatExactMoney(
                      review.totals.unallocatedTotalMinor, locale),
                ),
                _ValueRow(
                  label: strings.t('outstanding'),
                  value: formatExactMoney(
                      review.totals.outstandingTotalMinor, locale),
                ),
              ],
            ),
          ),
          const SizedBox(height: DukaanTokens.space6),
          Text(strings.t('payments'),
              style: Theme.of(context).textTheme.titleMedium),
          if (review.payments.isEmpty)
            DukaanEmptyState(
              icon: Icons.payments_outlined,
              title: strings.t('noPayments'),
              detail: strings.t('allocationReviewDetail'),
            )
          else
            for (final payment in review.payments)
              DukaanCard(
                key: Key('allocation-payment-${payment.id}'),
                onTap: () => _openPayment(payment),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _partyNames[payment.partyId] ??
                                (payment.reference.isNotEmpty
                                    ? payment.reference
                                    : payment.id),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        DukaanBadge(payment.direction),
                      ],
                    ),
                    const SizedBox(height: DukaanTokens.space2),
                    _ValueRow(
                      label: strings.t('payment'),
                      value: formatExactMoney(payment.amountMinor, locale),
                      strong: true,
                    ),
                    _ValueRow(
                      label: strings.t('allocated'),
                      value:
                          formatExactMoney(payment.allocatedTotalMinor, locale),
                    ),
                    _ValueRow(
                      label: strings.t('unallocated'),
                      value: formatExactMoney(
                          payment.unallocatedTotalMinor, locale),
                      warning: payment.unallocatedTotalMinor != 0,
                    ),
                    if (payment.allocations.isNotEmpty) ...[
                      const SizedBox(height: DukaanTokens.space2),
                      for (final allocation in payment.allocations)
                        Text(
                          '${allocation.documentNumber ?? allocation.documentId ?? ''} · '
                          '${formatExactMoney(allocation.amountMinor, locale)}',
                          style: DukaanTokens.textCaption,
                        ),
                    ],
                    const SizedBox(height: DukaanTokens.space2),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton.icon(
                        onPressed: () => _openPayment(payment),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: Text(strings.t('reallocate')),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: DukaanTokens.space6),
          Text(strings.t('outstanding'),
              style: Theme.of(context).textTheme.titleMedium),
          if (review.outstandingDocuments.isEmpty)
            DukaanEmptyState(
              icon: Icons.receipt_long_outlined,
              title: strings.t('noOutstandingDocuments'),
              detail: strings.t('allocationReviewDetail'),
            )
          else
            for (final document in review.outstandingDocuments.take(100))
              DukaanListRow(
                title: document.number,
                subtitle:
                    '${document.partyName ?? ''} · ${document.documentType}',
                trailing: DukaanMoney(
                  formatExactMoney(document.dueTotalMinor, locale),
                ),
              ),
        ],
      ),
    );
  }
}

@immutable
class _AllocationTarget {
  const _AllocationTarget({
    required this.documentType,
    required this.documentId,
    required this.number,
    required this.availableMinor,
  });

  final String documentType;
  final String documentId;
  final String number;
  final int availableMinor;

  String get key => '$documentType:$documentId';
}

class _AllocationDraft {
  _AllocationDraft(this.target, {int? amountMinor})
      : controller = TextEditingController(
          text: amountMinor == null ? '' : minorToInput(amountMinor),
        );

  final _AllocationTarget target;
  final TextEditingController controller;

  void dispose() => controller.dispose();
}

class ReallocationSheet extends ConsumerStatefulWidget {
  const ReallocationSheet({
    required this.payment,
    required this.review,
    this.partyName,
    super.key,
  });

  final PaymentRecord payment;
  final PaymentAllocationReview review;
  final String? partyName;

  @override
  ConsumerState<ReallocationSheet> createState() => _ReallocationSheetState();
}

class _ReallocationSheetState extends ConsumerState<ReallocationSheet> {
  final _reason = TextEditingController();
  final _idempotencyKey = const Uuid().v4();
  late List<_AllocationDraft> _drafts;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final targets = _targets();
    _drafts = [
      for (final allocation in widget.payment.allocations)
        _AllocationDraft(
          _AllocationTarget(
            documentType: allocation.documentType,
            documentId: allocation.documentId ??
                allocation.saleId ??
                allocation.purchaseId ??
                '',
            number: allocation.documentNumber ?? allocation.documentId ?? '',
            availableMinor: (allocation.documentDueTotalMinor ?? 0) +
                allocation.amountMinor,
          ),
          amountMinor: allocation.amountMinor,
        ),
    ];
    if (_drafts.isEmpty && targets.isNotEmpty) {
      _drafts = [_AllocationDraft(targets.first)];
    }
  }

  @override
  void dispose() {
    _reason.dispose();
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  List<_AllocationTarget> _targets() {
    final expectedType =
        widget.payment.direction == 'RECEIPT' ? 'SALE' : 'PURCHASE';
    final currentByKey = {
      for (final allocation in widget.payment.allocations)
        '${allocation.documentType}:${allocation.documentId ?? allocation.saleId ?? allocation.purchaseId}':
            allocation,
    };
    final targets = <String, _AllocationTarget>{};
    for (final document in widget.review.outstandingDocuments) {
      if (document.documentType != expectedType ||
          (document.partyId != null &&
              document.partyId != widget.payment.partyId)) {
        continue;
      }
      final key = '${document.documentType}:${document.documentId}';
      final current = currentByKey[key];
      targets[key] = _AllocationTarget(
        documentType: document.documentType,
        documentId: document.documentId,
        number: document.number,
        availableMinor: document.dueTotalMinor + (current?.amountMinor ?? 0),
      );
    }
    for (final entry in currentByKey.entries) {
      if (entry.key.startsWith('$expectedType:') &&
          !targets.containsKey(entry.key)) {
        final allocation = entry.value;
        targets[entry.key] = _AllocationTarget(
          documentType: allocation.documentType,
          documentId: allocation.documentId ??
              allocation.saleId ??
              allocation.purchaseId ??
              '',
          number: allocation.documentNumber ?? allocation.documentId ?? '',
          availableMinor:
              (allocation.documentDueTotalMinor ?? 0) + allocation.amountMinor,
        );
      }
    }
    return targets.values.toList();
  }

  void _addDraft() {
    final selected = _drafts.map((draft) => draft.target.key).toSet();
    final candidates =
        _targets().where((item) => !selected.contains(item.key)).toList();
    if (candidates.isEmpty) return;
    setState(() => _drafts.add(_AllocationDraft(candidates.first)));
  }

  Future<void> _save() async {
    final strings = context.strings;
    if (!(ref.read(networkStatusProvider).valueOrNull ?? false)) {
      setState(() => _error = strings.t('offlineAction'));
      return;
    }
    final reason = _reason.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = strings.t('required'));
      return;
    }
    final allocations = <Map<String, dynamic>>[];
    final seen = <String>{};
    var total = 0;
    for (final draft in _drafts) {
      final amount = parseMinor(draft.controller.text);
      if (amount <= 0) {
        setState(() => _error = strings.t('invalidAmount'));
        return;
      }
      if (amount > draft.target.availableMinor) {
        setState(() => _error = strings.t('allocationExceedsPayment'));
        return;
      }
      if (!seen.add(draft.target.key)) {
        setState(() => _error = strings.t('required'));
        return;
      }
      total += amount;
      allocations.add({
        'document_type': draft.target.documentType,
        'document_id': draft.target.documentId,
        'amount_minor': amount,
      });
    }
    if (allocations.isEmpty || total != widget.payment.amountMinor) {
      setState(() => _error = strings.t('fullPaymentRequired'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(repositoryProvider).reallocatePayment(
            id: widget.payment.id,
            allocations: allocations,
            reason: reason,
            idempotencyKey: _idempotencyKey,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.t('allocationSaved'))),
      );
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error =
            describeDioError(error, 'The payment could not be reallocated.'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final locale = Localizations.localeOf(context).languageCode;
    final targets = _targets();
    final online = ref.watch(networkStatusProvider).valueOrNull ?? false;
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(DukaanTokens.space4),
        children: [
          Text(strings.t('reallocate'),
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: DukaanTokens.space1),
          Text(widget.partyName ?? widget.payment.partyId),
          const SizedBox(height: DukaanTokens.space2),
          Text('${strings.t('payment')}: '
              '${formatExactMoney(widget.payment.amountMinor, locale)}'),
          if (!online) ...[
            const SizedBox(height: DukaanTokens.space3),
            DukaanBanner(
              icon: Icons.cloud_off_rounded,
              title: strings.t('offline'),
              detail: strings.t('offlineAction'),
            ),
          ],
          const SizedBox(height: DukaanTokens.space4),
          if (targets.isEmpty)
            DukaanEmptyState(
              icon: Icons.receipt_long_outlined,
              title: strings.t('noOutstandingDocuments'),
              detail: strings.t('noOutstandingDocuments'),
            )
          else
            for (var index = 0; index < _drafts.length; index++)
              DukaanCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            key: Key('allocation-target-$index'),
                            initialValue: _drafts[index].target.key,
                            items: [
                              for (final target in targets)
                                DropdownMenuItem(
                                  value: target.key,
                                  child: Text(
                                    '${target.number} · '
                                    '${formatExactMoney(target.availableMinor, locale)}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: _saving
                                ? null
                                : (value) {
                                    final matches = targets
                                        .where((item) => item.key == value)
                                        .toList();
                                    if (matches.isNotEmpty) {
                                      final previous = _drafts[index];
                                      setState(() => _drafts[index] =
                                          _AllocationDraft(matches.first));
                                      previous.dispose();
                                    }
                                  },
                          ),
                        ),
                        IconButton(
                          tooltip: strings.t('delete'),
                          onPressed: _saving || _drafts.length == 1
                              ? null
                              : () => setState(() {
                                    _drafts.removeAt(index).dispose();
                                  }),
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: DukaanTokens.space2),
                    DukaanField(
                      label: strings.t('allocationAmount'),
                      child: TextField(
                        key: Key('allocation-amount-$index'),
                        controller: _drafts[index].controller,
                        enabled: !_saving,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(),
                      ),
                    ),
                  ],
                ),
              ),
          if (targets.isNotEmpty) ...[
            OutlinedButton.icon(
              key: const Key('allocation-add'),
              onPressed: _saving ? null : _addDraft,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(strings.t('addAllocation')),
            ),
            const SizedBox(height: DukaanTokens.space3),
            DukaanField(
              label: strings.t('reallocationReason'),
              child: TextField(
                key: const Key('allocation-reason'),
                controller: _reason,
                enabled: !_saving,
                maxLength: 240,
                decoration: const InputDecoration(),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: DukaanTokens.space2),
            _ErrorText(_error!),
          ],
          const SizedBox(height: DukaanTokens.space3),
          FilledButton.icon(
            key: const Key('allocation-save'),
            onPressed: online && !_saving && targets.isNotEmpty ? _save : null,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: Text(strings.t('saveAllocation')),
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow({
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: DukaanTokens.space3),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            const SizedBox(width: DukaanTokens.space3),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: (strong
                        ? DukaanTokens.textAmountLarge
                        : DukaanTokens.textAmount)
                    .copyWith(
                  color: warning ? Theme.of(context).colorScheme.error : null,
                ),
              ),
            ),
          ],
        ),
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

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
