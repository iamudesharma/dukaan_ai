import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Entry detail bottom sheet: lines, totals, record-payment (when money is
/// due) and reversal with a mandatory reason.
Future<void> showEntryDetailSheet(
  BuildContext context,
  WidgetRef ref, {
  required BusinessEntry entry,
}) async {
  Map<String, dynamic>? detail;
  String? error;
  try {
    final repository = ref.read(repositoryProvider);
    detail = switch (entry.type) {
      EntryType.sale => await repository.fetchSale(entry.id),
      EntryType.purchase => await repository.fetchPurchase(entry.id),
      EntryType.payment => await repository.fetchPayment(entry.id),
      EntryType.expense => await repository.fetchExpense(entry.id),
    };
  } on Object catch (err) {
    error = err.toString();
  }
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => _EntryDetailBody(
      entry: entry,
      detail: detail,
      loadError: error,
      locale: Localizations.localeOf(sheetContext).languageCode,
    ),
  );
}

class _EntryDetailBody extends ConsumerStatefulWidget {
  const _EntryDetailBody({
    required this.entry,
    required this.detail,
    required this.loadError,
    required this.locale,
  });

  final BusinessEntry entry;
  final Map<String, dynamic>? detail;
  final String? loadError;
  final String locale;

  @override
  ConsumerState<_EntryDetailBody> createState() => _EntryDetailBodyState();
}

class _EntryDetailBodyState extends ConsumerState<_EntryDetailBody> {
  final _reason = TextEditingController();
  bool _working = false;
  bool _invoiceWorking = false;
  String? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  int _minor(Object? value) => minorFrom(value);

  Future<void> _reverse() async {
    if (_reason.text.trim().isEmpty) {
      setState(() => _error = context.strings.t('reversalReason'));
      return;
    }
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      final repository = ref.read(repositoryProvider);
      final reason = _reason.text.trim();
      switch (widget.entry.type) {
        case EntryType.sale:
          await repository.reverseSale(id: widget.entry.id, reason: reason);
        case EntryType.purchase:
          await repository.reversePurchase(id: widget.entry.id, reason: reason);
        case EntryType.payment:
          await repository.reversePayment(id: widget.entry.id, reason: reason);
        case EntryType.expense:
          await repository.reverseExpense(id: widget.entry.id, reason: reason);
      }
      invalidateBusinessData(ref.invalidate);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.strings.t('entryReversed'))),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _error = error is DioException
              ? (error.response?.data is Map &&
                      (error.response?.data as Map)['error'] is Map
                  ? (((error.response?.data as Map)['error'] as Map)['detail'] is Map
                      ? ((((error.response?.data as Map)['error'] as Map)['detail'] as Map)['message']?.toString())
                      : null)
                  : null) ??
                  error.toString()
              : error.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _downloadInvoice() async {
    setState(() {
      _invoiceWorking = true;
      _error = null;
    });
    try {
      final repository = ref.read(repositoryProvider);
      final created = await repository.createSaleInvoice(widget.entry.id);
      final attachmentId = (created['id'] ?? '').toString();
      Map<String, dynamic> attachment = created;
      for (var i = 0; i < 20; i++) {
        final status = (attachment['status'] ?? '').toString();
        if (status == 'READY' || status == 'FAILED') break;
        await Future<void>.delayed(const Duration(seconds: 1));
        attachment = await repository.fetchAttachment(attachmentId);
      }
      if ((attachment['status'] ?? '').toString() != 'READY') {
        throw StateError('not ready');
      }
      final downloadUrl = (attachment['download_url'] ?? '').toString();
      final bytes = await repository.downloadBytes(
        downloadUrl.isEmpty ? 'attachments/$attachmentId/' : downloadUrl,
      );
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/invoice-${widget.entry.reference}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path, mimeType: 'application/pdf')]),
      );
    } on Object catch (_) {
      if (mounted) {
        setState(() => _error = context.strings.t('invoiceFailed'));
      }
    } finally {
      if (mounted) setState(() => _invoiceWorking = false);
    }
  }

  Future<void> _recordPayment() async {
    final paid = await showPaymentSheet(
      context,
      ref,
      entry: widget.entry,
    );
    if (paid && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final entry = widget.entry;
    final detail = widget.detail;
    final lines = detail?['lines'] is List
        ? (detail!['lines'] as List).whereType<Map>().toList(growable: false)
        : const [];
    final canPay = !entry.reversed &&
        (entry.type == EntryType.sale || entry.type == EntryType.purchase) &&
        entry.pendingMinor > 0 &&
        (entry.partyId ?? '').isNotEmpty;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Text(
            entry.partyName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text('${entry.reference} · ${formatDateTime(entry.occurredAt, widget.locale)}'),
          if (widget.loadError != null) ...[
            const SizedBox(height: 8),
            Text(widget.loadError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 12),
          _Row(label: strings.t('total'), value: formatMoney(entry.totalMinor, widget.locale), strong: true),
          if (entry.pendingMinor > 0)
            _Row(
              label: strings.t('pending'),
              value: formatMoney(entry.pendingMinor, widget.locale),
              warning: true,
            ),
          if (lines.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(strings.t('entryLines'), style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            for (final line in lines)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text((line['description'] ?? '').toString()),
                subtitle: Text('${line['quantity'] ?? ''}'),
                trailing: Text(
                  formatMoney(
                    _minor(line['line_total_minor'] ?? line['unit_price_minor']),
                    widget.locale,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
          ],
          const SizedBox(height: 16),
          if (canPay)
            FilledButton.icon(
              onPressed: _working ? null : _recordPayment,
              icon: const Icon(Icons.payments_outlined),
              label: Text(strings.t('recordPayment')),
            ),
          if (entry.type == EntryType.sale && !entry.reversed) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _invoiceWorking ? null : _downloadInvoice,
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                _invoiceWorking
                    ? strings.t('invoicePreparing')
                    : strings.t('downloadInvoice'),
              ),
            ),
          ],
          if (!entry.reversed) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _reason,
              decoration: InputDecoration(labelText: strings.t('reversalReason')),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _working ? null : _reverse,
              icon: const Icon(Icons.undo_rounded),
              label: Text(strings.t('reverseEntry')),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.strong = false, this.warning = false});

  final String label;
  final String value;
  final bool strong;
  final bool warning;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              value,
              style: TextStyle(
                fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
                color: warning ? Theme.of(context).colorScheme.error : null,
              ),
            ),
          ],
        ),
      );
}

/// Records a payment against the entry's outstanding balance. Returns true
/// when a payment was posted.
Future<bool> showPaymentSheet(
  BuildContext context,
  WidgetRef ref, {
  required BusinessEntry entry,
}) async {
  final strings = context.strings;
  final locale = Localizations.localeOf(context).languageCode;
  final amount = TextEditingController(text: minorToInput(entry.pendingMinor));
  var method = PaymentMethod.upi;
  String? message;
  final posted = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          24 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.t('recordPayment'),
              style: Theme.of(sheetContext)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '${entry.partyName} · ${strings.t('pending')} ${formatMoney(entry.pendingMinor, locale)}',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: strings.t('paymentAmount'),
                prefixText: '₹ ',
                helperText: strings.t('noMoneyMovement'),
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PaymentMethod>(
              initialValue: method,
              decoration: InputDecoration(labelText: strings.t('paymentMethod')),
              items: PaymentMethod.values
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item.apiValue)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setSheetState(() => method = value);
              },
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, style: TextStyle(color: Theme.of(sheetContext).colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final minor = parseMinor(amount.text);
                if (minor <= 0 || minor > entry.pendingMinor) {
                  setSheetState(() => message = strings.t('amountExceedsDue'));
                  return;
                }
                try {
                  final location = await ref.read(activeLocationProvider.future);
                  final isSale = entry.type == EntryType.sale;
                  await ref.read(repositoryProvider).createPayment({
                    'business_id': location.businessId,
                    'location_id': location.id,
                    'party_id': entry.partyId,
                    'direction': isSale ? 'RECEIPT' : 'PAYMENT',
                    'method': method.apiValue,
                    'amount_minor': minor,
                    if (isSale) 'sale_id': entry.id else 'purchase_id': entry.id,
                  });
                  invalidateBusinessData(ref.invalidate);
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop(true);
                } on Object catch (err) {
                  setSheetState(() => message = err.toString());
                }
              },
              child: Text(strings.t('recordPayment')),
            ),
          ],
        ),
      ),
    ),
  );
  amount.dispose();
  if ((posted ?? false) && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.t('paymentRecorded'))),
    );
  }
  return posted ?? false;
}
