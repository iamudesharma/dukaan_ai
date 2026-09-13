import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:dukaan_ai_mobile/core/config.dart';
import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class ManualSalePage extends ConsumerStatefulWidget {
  const ManualSalePage({super.key});

  @override
  ConsumerState<ManualSalePage> createState() => _ManualSalePageState();
}

class _ManualSalePageState extends ConsumerState<ManualSalePage> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController(text: '1');
  final _price = TextEditingController();
  final _paid = TextEditingController(text: '0');
  String? _productId;
  String? _customerId;
  PriceMode _priceMode = PriceMode.retail;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  SaleDraft? _reviewDraft;
  PostedResult? _result;
  bool _saving = false;
  bool _draftSaved = false;
  String? _error;
  String? _resumedDraftId;
  bool _needsStockAck = false;
  bool _stockAck = false;
  final _stockReason = TextEditingController();

  @override
  void initState() {
    super.initState();
    final resume = ref.read(saleDraftResumeProvider);
    if (resume != null && resume.lines.isNotEmpty) {
      final line = resume.lines.first;
      _productId = line.productId;
      _customerId = resume.customerId;
      _quantity.text = line.quantity.toString();
      _price.text = minorToInput(line.unitPriceMinor);
      _paid.text = minorToInput(resume.paidAmountMinor);
      _priceMode = resume.priceMode;
      _paymentMethod = resume.paymentMethod;
      _resumedDraftId = resume.id;
      ref.read(saleDraftResumeProvider.notifier).state = null;
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _paid.dispose();
    _stockReason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null || _draftSaved) return _buildSuccess(context);
    if (_reviewDraft != null) return _buildReview(context, _reviewDraft!);

    final products = ref.watch(productsProvider);
    final parties = ref.watch(partiesProvider);
    final location = ref.watch(activeLocationProvider);
    if (products.isLoading || parties.isLoading || location.isLoading) {
      return const LoadingContent();
    }
    if (products.hasError || parties.hasError || location.hasError) {
      return ErrorContent(
        message: (products.error ?? parties.error ?? location.error).toString(),
        onRetry: () {
          ref
            ..invalidate(productsProvider)
            ..invalidate(partiesProvider)
            ..invalidate(activeLocationProvider);
        },
      );
    }

    final productItems = products.requireValue;
    final partyItems = parties.requireValue;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go('/entries'),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              Text(
                context.strings.t('manualSale'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedButton<PriceMode>(
            segments: [
              ButtonSegment(value: PriceMode.retail, label: Text(context.strings.t('retail'))),
              ButtonSegment(
                value: PriceMode.wholesale,
                label: Text(context.strings.t('wholesale')),
              ),
            ],
            selected: {_priceMode},
            onSelectionChanged: (value) {
              setState(() {
                _priceMode = value.single;
                final selected = _selectedProduct(productItems);
                if (selected != null) _setProductPrice(selected);
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: const Key('sale-product'),
            initialValue: _productId,
            decoration: InputDecoration(labelText: context.strings.t('product')),
            items: productItems
                .map(
                  (product) => DropdownMenuItem(
                    value: product.id,
                    child: Text(product.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            validator: (value) => value == null ? context.strings.t('selectProduct') : null,
            onChanged: (value) {
              setState(() {
                _productId = value;
                final selected = _selectedProduct(productItems);
                if (selected != null) _setProductPrice(selected);
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _customerId,
            decoration: InputDecoration(labelText: context.strings.t('customerOptional')),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Walk-in')),
              ...partyItems
                  .where((party) => party.kind != PartyKind.supplier)
                  .map(
                    (party) => DropdownMenuItem<String?>(
                      value: party.id,
                      child: Text(party.name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
            ],
            onChanged: (value) => setState(() => _customerId = value),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('sale-quantity'),
                  controller: _quantity,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  decoration: InputDecoration(labelText: context.strings.t('quantity')),
                  validator: _positiveDecimalValidator,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  key: const Key('sale-price'),
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  decoration: InputDecoration(
                    labelText: context.strings.t('unitPrice'),
                    prefixText: '₹ ',
                  ),
                  validator: _positiveDecimalValidator,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('sale-paid'),
            controller: _paid,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
            decoration: InputDecoration(
              labelText: context.strings.t('paidNow'),
              prefixText: '₹ ',
              helperText: context.strings.t('noMoneyMovement'),
              helperMaxLines: 2,
            ),
            validator: _nonNegativeDecimalValidator,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _paymentMethod,
            decoration: InputDecoration(labelText: context.strings.t('paymentMethod')),
            items: PaymentMethod.values
                .map(
                  (method) => DropdownMenuItem(
                    value: method,
                    child: Text(method.apiValue),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _paymentMethod = value);
            },
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(context.strings.t('taxServer')),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            key: const Key('review-sale-button'),
            onPressed: () => _review(productItems, partyItems, location.requireValue),
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(context.strings.t('reviewSale')),
          ),
        ],
      ),
    );
  }

  Widget _buildReview(BuildContext context, SaleDraft draft) {
    final locale = Localizations.localeOf(context).languageCode;
    final online = ref.watch(networkStatusProvider).valueOrNull ?? AppConfig.demoMode;
    return ListView(
      key: const ValueKey('sale-review'),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        Text(
          context.strings.t('reviewTitle'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        Text(context.strings.t('saleNotRecorded')),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _ReviewRow(label: context.strings.t('customerOptional'), value: draft.customerName ?? 'Walk-in'),
                _ReviewRow(
                  label: context.strings.t('product'),
                  value: '${draft.lines.first.quantity} × ${draft.lines.first.productName}',
                ),
                _ReviewRow(
                  label: context.strings.t('total'),
                  value: formatMoney(draft.totalMinor, locale),
                  strong: true,
                ),
                _ReviewRow(
                  label: context.strings.t('paidNow'),
                  value: formatMoney(draft.paidAmountMinor, locale),
                ),
                _ReviewRow(
                  label: context.strings.t('pending'),
                  value: formatMoney(draft.pendingMinor, locale),
                  warning: draft.pendingMinor > 0,
                ),
                _ReviewRow(
                  label: context.strings.t('stockEffect'),
                  value: '−${draft.lines.first.quantity}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          color: online
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.errorContainer,
          child: ListTile(
            leading: Icon(online ? Icons.cloud_done_outlined : Icons.cloud_off_rounded),
            title: Text(
              online ? context.strings.t('reviewDetail') : context.strings.t('offlineDetail'),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (_needsStockAck) ...[
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.strings.t('confirmNegativeStock')),
                    value: _stockAck,
                    onChanged: (value) => setState(() => _stockAck = value ?? false),
                  ),
                  TextField(
                    controller: _stockReason,
                    decoration: InputDecoration(
                      labelText: context.strings.t('reversalReason'),
                      hintText: context.strings.t('stockReasonHint'),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        FilledButton.icon(
          key: const Key('confirm-sale-button'),
          onPressed: _saving ? null : () => _confirmSale(draft, online),
          icon: _saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(online ? Icons.check_circle_outline_rounded : Icons.edit_note_rounded),
          label: Text(
            online
                ? '${context.strings.t('recordSale')} ${formatMoney(draft.totalMinor, locale)}'
                : context.strings.t('saveDraft'),
          ),
        ),
        TextButton(
          onPressed: _saving ? null : () => setState(() => _reviewDraft = null),
          child: Text(context.strings.t('editRequest')),
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _draftSaved ? Icons.edit_note_rounded : Icons.check_circle_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text(
                _draftSaved ? context.strings.t('draftSaved') : context.strings.t('saved'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _draftSaved
                    ? context.strings.t('draftSavedDetail')
                    : '${context.strings.t('savedDetail')}\n${_result!.reference}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/entries'),
                  child: Text(context.strings.t('backToEntries')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _review(
    List<Product> products,
    List<Party> parties,
    BusinessLocation location,
  ) {
    if (!_formKey.currentState!.validate()) return;
    final product = _selectedProduct(products)!;
    final quantity = decimalFrom(_quantity.text, '1');
    final unitPriceMinor = parseMinor(_price.text);
    final paidMinor = parseMinor(_paid.text);
    final totalMinor = (quantity * Decimal.fromInt(unitPriceMinor)).round().toBigInt().toInt();
    if (paidMinor > totalMinor) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.t('invalidAmount'))),
      );
      return;
    }
    if (paidMinor < totalMinor && _customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.t('customerDueRequired'))),
      );
      return;
    }
    Party? customer;
    for (final party in parties) {
      if (party.id == _customerId) customer = party;
    }
    setState(() {
      _error = null;
      _reviewDraft = SaleDraft(
        id: const Uuid().v4(),
        businessId: location.businessId,
        locationId: location.id,
        customerId: customer?.id,
        customerName: customer?.name,
        lines: [
          SaleLineDraft(
            productId: product.id,
            packId: product.packId,
            productName: product.name,
            quantity: quantity,
            unitPriceMinor: unitPriceMinor,
          ),
        ],
        paidAmountMinor: paidMinor,
        priceMode: _priceMode,
        paymentMethod: _paymentMethod,
        createdAt: DateTime.now(),
      );
    });
  }

  Future<void> _confirmSale(SaleDraft draft, bool online) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (!online) {
        await ref.read(draftStoreProvider).saveDraft(
              LocalDraft(
                id: draft.id,
                kind: DraftKind.sale,
                locationId: draft.locationId,
                label: '${context.strings.t('manualSale')}: ${draft.lines.first.productName}',
                payload: draft.toLocalJson(),
                createdAt: draft.createdAt ?? DateTime.now(),
              ),
            );
        ref.invalidate(localDraftsProvider);
        if (mounted) setState(() => _draftSaved = true);
      } else {
        final acknowledged = SaleDraft(
          id: draft.id,
          businessId: draft.businessId,
          locationId: draft.locationId,
          customerId: draft.customerId,
          customerName: draft.customerName,
          lines: draft.lines,
          paidAmountMinor: draft.paidAmountMinor,
          priceMode: draft.priceMode,
          paymentMethod: draft.paymentMethod,
          paymentReference: draft.paymentReference,
          createdAt: draft.createdAt,
          negativeStockAcknowledged: _stockAck,
          negativeStockReason: _stockReason.text.trim(),
        );
        final result = await ref.read(repositoryProvider).createSale(acknowledged);
        if (_resumedDraftId != null) {
          await ref.read(draftStoreProvider).deleteDraft(_resumedDraftId!);
          ref.invalidate(localDraftsProvider);
        }
        ref
          ..invalidate(dashboardProvider)
          ..invalidate(entriesProvider)
          ..invalidate(productsProvider)
          ..invalidate(partiesProvider);
        if (mounted) {
          setState(() {
            _result = result;
            _needsStockAck = false;
          });
        }
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _error = _friendlySaleError(error);
          _needsStockAck = _isStockConfirmation(error);
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _isStockConfirmation(Object error) {
    if (error is! DioException) return false;
    final data = error.response?.data;
    if (data is! Map) return false;
    final detail = (data['error'] is Map) ? data['error']['detail'] : data['detail'];
    if (detail is Map) return detail['code'] == 'negative_stock_confirmation_required';
    return false;
  }

  String _friendlySaleError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final detail = (data['error'] is Map) ? data['error']['detail'] : data['detail'];
        if (detail is Map && detail['message'] is String) {
          return (detail['message'] as String).toString();
        }
        if (detail is String && detail.isNotEmpty) return detail;
      }
    }
    return error.toString();
  }

  Product? _selectedProduct(List<Product> products) {
    for (final product in products) {
      if (product.id == _productId) return product;
    }
    return null;
  }

  void _setProductPrice(Product product) {
    _price.text = minorToInput(
      _priceMode == PriceMode.retail ? product.retailPriceMinor : product.wholesalePriceMinor,
    );
  }

  String? _positiveDecimalValidator(String? value) {
    final parsed = Decimal.tryParse(value ?? '');
    if (parsed == null || parsed <= Decimal.zero) return context.strings.t('invalidAmount');
    return null;
  }

  String? _nonNegativeDecimalValidator(String? value) {
    final parsed = Decimal.tryParse(value ?? '');
    if (parsed == null || parsed < Decimal.zero) return context.strings.t('invalidAmount');
    return null;
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
                  color: warning ? Theme.of(context).colorScheme.error : null,
                ),
              ),
            ),
          ],
        ),
      );
}
