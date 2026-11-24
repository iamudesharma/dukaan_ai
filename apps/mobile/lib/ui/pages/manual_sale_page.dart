import 'package:decimal/decimal.dart';
import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
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

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _paid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null || _draftSaved) return _buildSuccess(context);
    if (_reviewDraft != null) return _buildReview(context, _reviewDraft!);

    final products = ref.watch(productsProvider);
    final parties = ref.watch(partiesProvider);
    final location = ref.watch(activeLocationProvider);
    final canUseWholesale =
        ref.watch(currentBusinessRoleProvider).canUseWholesalePrices;
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
        padding: const EdgeInsets.fromLTRB(
          DukaanTokens.space4,
          DukaanTokens.space4,
          DukaanTokens.space4,
          DukaanTokens.space6,
        ),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => context.go('/entries'),
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
              const SizedBox(width: DukaanTokens.space1),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DukaanKicker('01 · ${context.strings.t('manualSale')}'),
                    const SizedBox(height: DukaanTokens.space1),
                    Text(
                      context.strings.t('manualSale'),
                      style: DukaanTokens.textTitle.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DukaanTokens.space2),
          const Divider(
            height: 1,
            thickness: 2,
            color: DukaanTokens.colorInk,
          ),
          if (canUseWholesale) ...[
            const SizedBox(height: DukaanTokens.space4),
            SegmentedButton<PriceMode>(
              segments: [
                ButtonSegment(
                    value: PriceMode.retail,
                    label: Text(context.strings.t('retail'))),
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
          ] else
            Align(
              alignment: Alignment.centerLeft,
              child: DukaanBadge(context.strings.t('retail')),
            ),
          const SizedBox(height: DukaanTokens.space4),
          DropdownButtonFormField<String>(
            key: const Key('sale-product'),
            initialValue: _productId,
            decoration:
                InputDecoration(labelText: context.strings.t('product')),
            items: productItems
                .map(
                  (product) => DropdownMenuItem(
                    value: product.id,
                    child: Text(product.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            validator: (value) =>
                value == null ? context.strings.t('selectProduct') : null,
            onChanged: (value) {
              setState(() {
                _productId = value;
                final selected = _selectedProduct(productItems);
                if (selected != null) _setProductPrice(selected);
              });
            },
          ),
          const SizedBox(height: DukaanTokens.space3),
          DropdownButtonFormField<String?>(
            initialValue: _customerId,
            decoration: InputDecoration(
                labelText: context.strings.t('customerOptional')),
            items: [
              const DropdownMenuItem<String?>(
                  value: null, child: Text('Walk-in')),
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
          const SizedBox(height: DukaanTokens.space3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('sale-quantity'),
                  controller: _quantity,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                  decoration:
                      InputDecoration(labelText: context.strings.t('quantity')),
                  validator: _positiveDecimalValidator,
                ),
              ),
              const SizedBox(width: DukaanTokens.space2),
              Expanded(
                child: TextFormField(
                  key: const Key('sale-price'),
                  controller: _price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                  decoration: InputDecoration(
                    labelText: context.strings.t('unitPrice'),
                    prefixText: '₹ ',
                  ),
                  validator: _positiveDecimalValidator,
                ),
              ),
            ],
          ),
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('sale-paid'),
            controller: _paid,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
            ],
            decoration: InputDecoration(
              labelText: context.strings.t('paidNow'),
              prefixText: '₹ ',
              helperText: context.strings.t('noMoneyMovement'),
              helperMaxLines: 2,
            ),
            validator: _nonNegativeDecimalValidator,
          ),
          const SizedBox(height: DukaanTokens.space3),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _paymentMethod,
            decoration:
                InputDecoration(labelText: context.strings.t('paymentMethod')),
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
          const SizedBox(height: DukaanTokens.space4),
          DukaanCard(
            color: Theme.of(context).colorScheme.surfaceContainer,
            padding: const EdgeInsets.symmetric(
              horizontal: DukaanTokens.space4,
              vertical: DukaanTokens.space1,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: DukaanTokens.space3),
                Expanded(
                  child: Text(
                    context.strings.t('taxServer'),
                    style: DukaanTokens.textLabel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DukaanTokens.space5),
          FilledButton.icon(
            key: const Key('review-sale-button'),
            onPressed: () =>
                _review(productItems, partyItems, location.requireValue),
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(context.strings.t('reviewSale')),
          ),
        ],
      ),
    );
  }

  Widget _buildReview(BuildContext context, SaleDraft draft) {
    final locale = Localizations.localeOf(context).languageCode;
    final online = ref.watch(networkStatusProvider).valueOrNull ?? false;
    return ListView(
      key: const ValueKey('sale-review'),
      padding: const EdgeInsets.fromLTRB(
        DukaanTokens.space4,
        DukaanTokens.space4,
        DukaanTokens.space4,
        DukaanTokens.space6,
      ),
      children: [
        DukaanKicker('02 · ${context.strings.t('manualSale')}'),
        const SizedBox(height: DukaanTokens.space1),
        Text(
          context.strings.t('reviewTitle'),
          style: DukaanTokens.textTitle.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: DukaanTokens.space1),
        Text(
          context.strings.t('saleNotRecorded'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: DukaanTokens.space4),
        DukaanCard(
          child: Column(
            children: [
              _ReviewRow(
                  label: context.strings.t('customerOptional'),
                  value: draft.customerName ?? 'Walk-in'),
              _ReviewRow(
                label: context.strings.t('product'),
                value:
                    '${draft.lines.first.quantity} × ${draft.lines.first.productName}',
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
        const SizedBox(height: DukaanTokens.space3),
        // Being offline means the sale becomes a draft. That is attention,
        // not failure, so it does not use the error tone.
        DukaanCard(
          color: online
              ? Theme.of(context).colorScheme.surfaceContainer
              : Theme.of(context).colorScheme.tertiaryContainer,
          padding: const EdgeInsets.symmetric(
            horizontal: DukaanTokens.space4,
            vertical: DukaanTokens.space1,
          ),
          child: Row(
            children: [
              Icon(
                online ? Icons.cloud_done_outlined : Icons.cloud_off_rounded,
                size: 20,
                color: online
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: DukaanTokens.space3),
              Expanded(
                child: Text(
                  online
                      ? context.strings.t('reviewDetail')
                      : context.strings.t('offlineDetail'),
                  style: DukaanTokens.textLabel.copyWith(
                    color: online
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: DukaanTokens.space2),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: DukaanTokens.space5),
        FilledButton.icon(
          key: const Key('confirm-sale-button'),
          onPressed: _saving ? null : () => _confirmSale(draft, online),
          icon: _saving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(online
                  ? Icons.check_circle_outline_rounded
                  : Icons.edit_note_rounded),
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
        padding: const EdgeInsets.all(DukaanTokens.space6),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: DukaanTokens.colorPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _draftSaved ? Icons.edit_note_rounded : Icons.check_rounded,
                  size: 28,
                  color: DukaanTokens.colorOnPrimary,
                ),
              ),
              const SizedBox(height: DukaanTokens.space4),
              Text(
                _draftSaved
                    ? context.strings.t('draftSaved')
                    : context.strings.t('saved'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: DukaanTokens.space2),
              Text(
                _draftSaved
                    ? context.strings.t('draftSavedDetail')
                    : '${context.strings.t('savedDetail')}\n${_result!.reference}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: DukaanTokens.space6),
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
    final totalMinor =
        (quantity * Decimal.fromInt(unitPriceMinor)).round().toBigInt().toInt();
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
        final label =
            '${context.strings.t('manualSale')}: ${draft.lines.first.productName}';
        final location = await ref.read(activeLocationProvider.future);
        if (location.id != draft.locationId ||
            location.businessId != draft.businessId) {
          throw StateError(
              'The active location changed. Review the sale again.');
        }
        final scope = await ref.read(currentDraftScopeProvider.future);
        await ref.read(draftStoreProvider).saveDraft(
              LocalDraft(
                id: draft.id,
                kind: DraftKind.sale,
                userId: scope.userId,
                businessId: scope.businessId,
                locationId: location.id,
                label: label,
                payload: draft.toLocalJson(),
                createdAt: draft.createdAt ?? DateTime.now(),
              ),
            );
        ref.invalidate(localDraftsProvider);
        if (mounted) setState(() => _draftSaved = true);
      } else {
        final result = await ref.read(repositoryProvider).createSale(draft);
        ref
          ..invalidate(dashboardProvider)
          ..invalidate(entriesProvider)
          ..invalidate(productsProvider)
          ..invalidate(partiesProvider);
        if (mounted) setState(() => _result = result);
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Product? _selectedProduct(List<Product> products) {
    for (final product in products) {
      if (product.id == _productId) return product;
    }
    return null;
  }

  void _setProductPrice(Product product) {
    _price.text = minorToInput(
      _priceMode == PriceMode.retail
          ? product.retailPriceMinor
          : product.wholesalePriceMinor,
    );
  }

  String? _positiveDecimalValidator(String? value) {
    final parsed = Decimal.tryParse(value ?? '');
    if (parsed == null || parsed <= Decimal.zero) {
      return context.strings.t('invalidAmount');
    }
    return null;
  }

  String? _nonNegativeDecimalValidator(String? value) {
    final parsed = Decimal.tryParse(value ?? '');
    if (parsed == null || parsed < Decimal.zero) {
      return context.strings.t('invalidAmount');
    }
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final valueStyle =
        strong ? DukaanTokens.textAmountLarge : DukaanTokens.textAmount;

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
              style: valueStyle.copyWith(
                color: warning ? scheme.onTertiaryContainer : scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
