import 'package:decimal/decimal.dart';
import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/core/generated/dukaan_tokens.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/state/auth_controller.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:dukaan_ai_mobile/ui/common/settings_page_layout.dart';
import 'package:dukaan_ai_mobile/ui/components/dukaan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

enum OperationFormType { purchase, expense, payment, transfer }

extension OperationFormTypeInfo on OperationFormType {
  OperationKind get kind => switch (this) {
        OperationFormType.purchase => OperationKind.purchase,
        OperationFormType.expense => OperationKind.expense,
        OperationFormType.payment => OperationKind.payment,
        OperationFormType.transfer => OperationKind.transfer,
      };

  String get path => switch (this) {
        OperationFormType.purchase => '/purchase/new',
        OperationFormType.expense => '/expense/new',
        OperationFormType.payment => '/payment/new',
        OperationFormType.transfer => '/transfer/new',
      };

  String get titleKey => switch (this) {
        OperationFormType.purchase => 'purchase',
        OperationFormType.expense => 'expense',
        OperationFormType.payment => 'payment',
        OperationFormType.transfer => 'stockTransfer',
      };
}

class OperationFormPage extends ConsumerWidget {
  const OperationFormPage({required this.type, super.key});

  final OperationFormType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentBusinessRoleProvider);
    final allowed =
        role.canManageOperations || type == OperationFormType.payment;
    return ManagerOnlyGate(
      allowed: allowed,
      child: _OperationForm(
          type: type, canManageOperations: role.canManageOperations),
    );
  }
}

class _OperationForm extends ConsumerStatefulWidget {
  const _OperationForm({
    required this.type,
    required this.canManageOperations,
  });

  final OperationFormType type;
  final bool canManageOperations;

  @override
  ConsumerState<_OperationForm> createState() => _OperationFormState();
}

class _OperationFormState extends ConsumerState<_OperationForm> {
  final _formKey = GlobalKey<FormState>();
  final _lines = <_OperationLine>[_OperationLine()];
  final _category = TextEditingController();
  final _payee = TextEditingController();
  final _note = TextEditingController();
  final _amount = TextEditingController();
  final _tax = TextEditingController(text: '0');
  final _reference = TextEditingController();
  final _billNumber = TextEditingController();
  final _paid = TextEditingController(text: '0');
  final _negativeReason = TextEditingController();
  String? _supplierId;
  String? _partyId;
  String? _fromLocationId;
  String? _toLocationId;
  bool _receipt = true;
  bool _taxInclusive = false;
  bool _negativeAcknowledged = false;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  DateTime _date = DateTime.now();
  OperationDraft? _reviewDraft;
  String? _reviewLabel;
  PostedResult? _result;
  bool _draftSaved = false;
  bool _submitting = false;
  String? _error;

  bool get _needsProducts =>
      widget.type == OperationFormType.purchase ||
      widget.type == OperationFormType.transfer;

  @override
  void dispose() {
    for (final line in _lines) {
      line.dispose();
    }
    _category.dispose();
    _payee.dispose();
    _note.dispose();
    _amount.dispose();
    _tax.dispose();
    _reference.dispose();
    _billNumber.dispose();
    _paid.dispose();
    _negativeReason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null || _draftSaved) return _buildSuccess(context);
    if (_reviewDraft != null) return _buildReview(context, _reviewDraft!);

    final location = ref.watch(activeLocationProvider);
    final parties = ref.watch(partiesProvider);
    final products = ref.watch(productsProvider);
    final locations = ref.watch(locationsProvider);
    if (location.isLoading ||
        parties.isLoading ||
        (_needsProducts && products.isLoading) ||
        (widget.type == OperationFormType.transfer && locations.isLoading)) {
      return const LoadingContent();
    }
    if (location.hasError ||
        parties.hasError ||
        (_needsProducts && products.hasError) ||
        (widget.type == OperationFormType.transfer && locations.hasError)) {
      return ErrorContent(
        message: (location.error ??
                parties.error ??
                (_needsProducts ? products.error : null) ??
                locations.error)
            .toString(),
        onRetry: () {
          ref
            ..invalidate(activeLocationProvider)
            ..invalidate(partiesProvider)
            ..invalidate(productsProvider)
            ..invalidate(locationsProvider);
        },
      );
    }

    final partyItems = parties.requireValue;
    final productItems =
        _needsProducts ? products.requireValue : const <Product>[];
    final locationItems = widget.type == OperationFormType.transfer
        ? locations.requireValue
        : const <BusinessLocation>[];
    final visibleParties = partyItems.where((party) {
      if (widget.type == OperationFormType.purchase) {
        return party.kind != PartyKind.customer;
      }
      if (widget.type == OperationFormType.payment) {
        return _receipt
            ? party.kind == PartyKind.customer
            : party.kind != PartyKind.customer;
      }
      return false;
    }).toList(growable: false);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    DukaanKicker(
                        '01 · ${context.strings.t(widget.type.titleKey)}'),
                    const SizedBox(height: DukaanTokens.space1),
                    Text(
                      context.strings.t(widget.type.titleKey),
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
          const Divider(height: 1, thickness: 2, color: DukaanTokens.colorInk),
          const SizedBox(height: DukaanTokens.space4),
          ..._fields(
            context,
            partyItems: visibleParties,
            productItems: productItems,
            locationItems: locationItems,
            activeLocation: location.requireValue,
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
                const Icon(Icons.info_outline_rounded, size: 20),
                const SizedBox(width: DukaanTokens.space3),
                Expanded(
                  child: Text(
                    widget.type == OperationFormType.purchase
                        ? context.strings.t('serverTotalMayIncludeTax')
                        : context.strings.t('reviewDetail'),
                    style: DukaanTokens.textLabel,
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: DukaanTokens.space3),
            _ErrorText(_error!),
          ],
          const SizedBox(height: DukaanTokens.space5),
          FilledButton.icon(
            key: Key('review-${widget.type.name}-button'),
            onPressed: () => _review(
              partyItems: partyItems,
              activeLocation: location.requireValue,
            ),
            icon: const Icon(Icons.fact_check_outlined, size: 18),
            label: Text(context.strings.t('reviewOperation')),
          ),
        ],
      ),
    );
  }

  List<Widget> _fields(
    BuildContext context, {
    required List<Party> partyItems,
    required List<Product> productItems,
    required List<BusinessLocation> locationItems,
    required BusinessLocation activeLocation,
  }) {
    final strings = context.strings;
    return switch (widget.type) {
      OperationFormType.purchase => [
          DropdownButtonFormField<String>(
            key: const Key('purchase-supplier'),
            initialValue: _supplierId,
            isExpanded: true,
            decoration: InputDecoration(labelText: strings.t('supplier')),
            items: [
              for (final party in partyItems)
                DropdownMenuItem(
                  value: party.id,
                  child: Text(party.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            validator: (value) =>
                value == null ? strings.t('selectSupplier') : null,
            onChanged: (value) => setState(() => _supplierId = value),
          ),
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('purchase-bill-number'),
            controller: _billNumber,
            maxLength: 64,
            decoration: InputDecoration(labelText: strings.t('billNumber')),
          ),
          const SizedBox(height: DukaanTokens.space3),
          _DateField(date: _date, onChanged: (value) => _date = value),
          const SizedBox(height: DukaanTokens.space3),
          SwitchListTile(
            key: const Key('purchase-tax-inclusive'),
            contentPadding: EdgeInsets.zero,
            title: Text(strings.t('taxInclusive')),
            subtitle: Text(strings.t('taxInclusiveDetail')),
            value: _taxInclusive,
            onChanged: (value) => setState(() => _taxInclusive = value),
          ),
          const SizedBox(height: DukaanTokens.space2),
          ..._lineEditors(context, productItems, showCost: true),
          OutlinedButton.icon(
            key: const Key('purchase-add-line'),
            onPressed: () => setState(() => _lines.add(_OperationLine())),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(strings.t('addLine')),
          ),
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('purchase-paid'),
            controller: _paid,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_decimalFormatter],
            decoration: InputDecoration(
              labelText: strings.t('paidNow'),
              prefixText: '₹ ',
            ),
            validator: _nonNegativeValidator,
          ),
          const SizedBox(height: DukaanTokens.space3),
          _paymentMethodField(strings),
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('purchase-payment-reference'),
            controller: _reference,
            maxLength: 120,
            decoration:
                InputDecoration(labelText: strings.t('paymentReference')),
          ),
        ],
      OperationFormType.expense => [
          TextFormField(
            key: const Key('expense-category'),
            controller: _category,
            maxLength: 80,
            decoration: InputDecoration(labelText: strings.t('category')),
            validator: _requiredValidator,
          ),
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('expense-payee'),
            controller: _payee,
            maxLength: 180,
            decoration: InputDecoration(labelText: strings.t('payee')),
          ),
          const SizedBox(height: DukaanTokens.space3),
          _DateField(date: _date, onChanged: (value) => _date = value),
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('expense-amount'),
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_decimalFormatter],
            decoration: InputDecoration(
              labelText: strings.t('amount'),
              prefixText: '₹ ',
            ),
            validator: _positiveMinorValidator,
          ),
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('expense-tax'),
            controller: _tax,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_decimalFormatter],
            decoration: InputDecoration(
              labelText: strings.t('taxAmount'),
              prefixText: '₹ ',
            ),
            validator: _nonNegativeValidator,
          ),
          const SizedBox(height: DukaanTokens.space3),
          _paymentMethodField(strings),
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('expense-note'),
            controller: _note,
            maxLength: 240,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: strings.t('note')),
          ),
        ],
      OperationFormType.payment => [
          if (widget.canManageOperations) ...[
            SegmentedButton<bool>(
              key: const Key('payment-direction'),
              segments: [
                ButtonSegment(
                  value: true,
                  label: Text(strings.t('receipt')),
                ),
                ButtonSegment(
                  value: false,
                  label: Text(strings.t('supplierPayment')),
                ),
              ],
              selected: {_receipt},
              showSelectedIcon: false,
              onSelectionChanged: (value) => setState(() {
                _receipt = value.single;
                _partyId = null;
              }),
            ),
            const SizedBox(height: DukaanTokens.space3),
          ] else
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DukaanBadge(strings.t('receipt')),
            ),
          DropdownButtonFormField<String>(
            key: const Key('payment-party'),
            initialValue: _partyId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText:
                  _receipt ? strings.t('customer') : strings.t('supplier'),
            ),
            items: [
              for (final party in partyItems)
                DropdownMenuItem(
                  value: party.id,
                  child: Text(party.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            validator: (value) =>
                value == null ? strings.t('selectParty') : null,
            onChanged: (value) => setState(() => _partyId = value),
          ),
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('payment-amount'),
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_decimalFormatter],
            decoration: InputDecoration(
              labelText: strings.t('amount'),
              prefixText: '₹ ',
              helperText: strings.t('noMoneyMovement'),
            ),
            validator: _positiveMinorValidator,
          ),
          const SizedBox(height: DukaanTokens.space3),
          _DateField(date: _date, onChanged: (value) => _date = value),
          const SizedBox(height: DukaanTokens.space3),
          _paymentMethodField(strings),
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('payment-reference'),
            controller: _reference,
            maxLength: 120,
            decoration: InputDecoration(labelText: strings.t('reference')),
          ),
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('payment-note'),
            controller: _note,
            maxLength: 240,
            decoration: InputDecoration(labelText: strings.t('note')),
          ),
        ],
      OperationFormType.transfer => [
          DropdownButtonFormField<String>(
            key: const Key('transfer-from'),
            initialValue: _fromLocationId ?? activeLocation.id,
            isExpanded: true,
            decoration: InputDecoration(labelText: strings.t('fromLocation')),
            items: [
              for (final location in locationItems)
                DropdownMenuItem(
                  value: location.id,
                  child: Text(location.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            validator: (value) =>
                value == null ? strings.t('selectLocation') : null,
            onChanged: (value) => setState(() => _fromLocationId = value),
          ),
          const SizedBox(height: DukaanTokens.space3),
          DropdownButtonFormField<String>(
            key: const Key('transfer-to'),
            initialValue: _toLocationId,
            isExpanded: true,
            decoration: InputDecoration(labelText: strings.t('toLocation')),
            items: [
              for (final location in locationItems)
                DropdownMenuItem(
                  value: location.id,
                  child: Text(location.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            validator: (value) =>
                value == null ? strings.t('selectLocation') : null,
            onChanged: (value) => setState(() => _toLocationId = value),
          ),
          const SizedBox(height: DukaanTokens.space3),
          _DateField(date: _date, onChanged: (value) => _date = value),
          const SizedBox(height: DukaanTokens.space2),
          ..._lineEditors(context, productItems, showCost: false),
          OutlinedButton.icon(
            key: const Key('transfer-add-line'),
            onPressed: () => setState(() => _lines.add(_OperationLine())),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(strings.t('addLine')),
          ),
          const SizedBox(height: DukaanTokens.space3),
          SwitchListTile(
            key: const Key('transfer-negative-ack'),
            contentPadding: EdgeInsets.zero,
            title: Text(strings.t('negativeStockAck')),
            value: _negativeAcknowledged,
            onChanged: (value) => setState(() => _negativeAcknowledged = value),
          ),
          if (_negativeAcknowledged) ...[
            const SizedBox(height: DukaanTokens.space2),
            TextFormField(
              key: const Key('transfer-negative-reason'),
              controller: _negativeReason,
              maxLength: 240,
              decoration:
                  InputDecoration(labelText: strings.t('negativeStockReason')),
              validator: _requiredValidator,
            ),
          ],
          const SizedBox(height: DukaanTokens.space3),
          TextFormField(
            key: const Key('transfer-note'),
            controller: _note,
            maxLength: 240,
            decoration: InputDecoration(labelText: strings.t('note')),
          ),
        ],
    };
  }

  List<Widget> _lineEditors(
    BuildContext context,
    List<Product> products, {
    required bool showCost,
  }) =>
      [
        for (var index = 0; index < _lines.length; index++)
          _OperationLineEditor(
            key: ValueKey('operation-line-$index'),
            line: _lines[index],
            index: index,
            products: products,
            showCost: showCost,
            canRemove: _lines.length > 1,
            onRemove: () => setState(() {
              _lines.removeAt(index).dispose();
            }),
          ),
      ];

  Widget _paymentMethodField(AppStrings strings) =>
      DropdownButtonFormField<PaymentMethod>(
        initialValue: _paymentMethod,
        decoration: InputDecoration(labelText: strings.t('paymentMethod')),
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
      );

  void _review({
    required List<Party> partyItems,
    required BusinessLocation activeLocation,
  }) {
    final strings = context.strings;
    if (!_formKey.currentState!.validate()) return;
    final date = _date.toIso8601String().split('T').first;
    late final Map<String, dynamic> payload;
    late final String label;
    switch (widget.type) {
      case OperationFormType.purchase:
        final supplier =
            _firstWhereOrNull(partyItems, (party) => party.id == _supplierId);
        if (supplier == null) {
          _showError(strings.t('selectSupplier'));
          return;
        }
        if (!_validateLineDiscounts()) return;
        payload = {
          'supplier_id': supplier.id,
          'purchase_date': date,
          'supplier_bill_number': _billNumber.text.trim(),
          'tax_inclusive': _taxInclusive,
          'discount_total_minor': 0,
          'lines': [
            for (final line in _lines)
              {
                'pack_id': line.packId.value,
                'quantity': decimalFrom(line.quantity.text).toString(),
                'unit_cost_minor': parseMinor(line.price.text),
                'discount_minor': parseMinor(line.discount.text),
              },
          ],
          'paid_amount_minor': parseMinor(_paid.text),
          'payment_method': _paymentMethod.apiValue,
          if (_reference.text.trim().isNotEmpty)
            'payment_reference': _reference.text.trim(),
        };
        label = '${strings.t('purchase')}: ${supplier.name}';

      case OperationFormType.expense:
        payload = {
          'expense_date': date,
          'category': _category.text.trim(),
          'payee': _payee.text.trim(),
          'note': _note.text.trim(),
          'amount_minor': parseMinor(_amount.text),
          'tax_amount_minor': parseMinor(_tax.text),
          'payment_method': _paymentMethod.apiValue,
        };
        label = '${strings.t('expense')}: ${_category.text.trim()}';

      case OperationFormType.payment:
        final party =
            _firstWhereOrNull(partyItems, (item) => item.id == _partyId);
        if (party == null) {
          _showError(strings.t('selectParty'));
          return;
        }
        if (!widget.canManageOperations && !_receipt) {
          _showError(strings.t('cashierSalesOnly'));
          return;
        }
        payload = {
          'party_id': party.id,
          'direction': _receipt ? 'RECEIPT' : 'PAYMENT',
          'method': _paymentMethod.apiValue,
          'amount_minor': parseMinor(_amount.text),
          'payment_date': date,
          'reference': _reference.text.trim(),
          'note': _note.text.trim(),
        };
        label =
            '${strings.t(_receipt ? 'receipt' : 'supplierPayment')}: ${party.name}';
      case OperationFormType.transfer:
        final fromId = _fromLocationId ?? activeLocation.id;
        if (_toLocationId == null || fromId == _toLocationId) {
          _showError(strings.t('sameLocation'));
          return;
        }
        if (_negativeAcknowledged && _negativeReason.text.trim().isEmpty) {
          _showError(strings.t('required'));
          return;
        }
        payload = {
          'from_location_id': fromId,
          'to_location_id': _toLocationId,
          'transfer_date': date,
          'note': _note.text.trim(),
          'lines': [
            for (final line in _lines)
              {
                'pack_id': line.packId.value,
                'quantity': decimalFrom(line.quantity.text).toString(),
              },
          ],
          'negative_stock_acknowledged': _negativeAcknowledged,
          'negative_stock_reason': _negativeReason.text.trim(),
        };
        label = strings.t('stockTransfer');
    }
    setState(() {
      _error = null;
      _reviewLabel = label;
      _reviewDraft = OperationDraft(
        id: const Uuid().v4(),
        kind: widget.type.kind,
        businessId: activeLocation.businessId,
        locationId: activeLocation.id,
        payload: payload,
        createdAt: DateTime.now(),
      );
    });
  }

  bool _validateLineDiscounts() {
    for (final line in _lines) {
      final gross = (decimalFrom(line.quantity.text) *
              Decimal.fromInt(parseMinor(line.price.text)))
          .round()
          .toBigInt()
          .toInt();
      if (parseMinor(line.discount.text) > gross) {
        _showError(context.strings.t('discountExceedsLine'));
        return false;
      }
    }
    return true;
  }

  Widget _buildReview(BuildContext context, OperationDraft draft) {
    final online = ref.watch(networkStatusProvider).valueOrNull ?? false;
    final parties = draft.kind == OperationKind.purchase ||
            draft.kind == OperationKind.payment
        ? ref.watch(partiesProvider).valueOrNull ?? const <Party>[]
        : const <Party>[];
    final products = draft.kind == OperationKind.purchase ||
            draft.kind == OperationKind.transfer
        ? ref.watch(productsProvider).valueOrNull ?? const <Product>[]
        : const <Product>[];
    final locations = draft.kind == OperationKind.transfer
        ? ref.watch(locationsProvider).valueOrNull ?? const <BusinessLocation>[]
        : const <BusinessLocation>[];
    return ListView(
      key: const ValueKey('operation-review'),
      padding: const EdgeInsets.fromLTRB(
        DukaanTokens.space4,
        DukaanTokens.space4,
        DukaanTokens.space4,
        DukaanTokens.space6,
      ),
      children: [
        DukaanKicker('02 · ${context.strings.t(widget.type.titleKey)}'),
        const SizedBox(height: DukaanTokens.space1),
        Text(
          context.strings.t('reviewTitle'),
          style: DukaanTokens.textTitle.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: DukaanTokens.space1),
        Text(
          context.strings.t('operationNotRecorded'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: DukaanTokens.space4),
        OperationReviewCard(
          draft: draft,
          partyNames: {for (final party in parties) party.id: party.name},
          productNames: {
            for (final product in products) product.packId: product.name
          },
          locationNames: {
            for (final location in locations) location.id: location.name
          },
        ),
        const SizedBox(height: DukaanTokens.space3),
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
              ),
              const SizedBox(width: DukaanTokens.space3),
              Expanded(
                child: Text(
                  online
                      ? context.strings.t('reviewDetail')
                      : context.strings.t('offlineDetail'),
                  style: DukaanTokens.textLabel,
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: DukaanTokens.space3),
          _ErrorText(_error!),
        ],
        const SizedBox(height: DukaanTokens.space5),
        FilledButton.icon(
          key: Key('submit-${widget.type.name}-button'),
          onPressed: _submitting ? null : () => _submit(draft),
          icon: _submitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(online
                  ? Icons.check_circle_outline_rounded
                  : Icons.edit_note_rounded),
          label: Text(
            online
                ? context.strings.t('recordOperation')
                : context.strings.t('saveDraft'),
          ),
        ),
        TextButton(
          onPressed:
              _submitting ? null : () => setState(() => _reviewDraft = null),
          child: Text(context.strings.t('editRequest')),
        ),
      ],
    );
  }

  Future<void> _submit(OperationDraft draft) async {
    final label = _reviewLabel ?? _labelFor(draft);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      var online = false;
      try {
        online = await ref.read(networkStatusProvider.future);
      } on Object {
        online = false;
      }
      final role = ref.read(currentBusinessRoleProvider);
      if (!draft.canBeRecordedBy(role)) {
        throw StateError(
            'Your current role cannot send this operation. Cashiers can send receipts only.');
      }
      final location = await ref.read(activeLocationProvider.future);
      if (location.id != draft.locationId ||
          location.businessId != draft.businessId) {
        throw StateError(
            'The active location changed. Review the entry again.');
      }
      if (!online) {
        final scope = await ref.read(currentDraftScopeProvider.future);
        await ref.read(draftStoreProvider).saveDraft(
              LocalDraft(
                id: draft.id,
                kind: draft.kind.draftKind,
                userId: scope.userId,
                businessId: scope.businessId,
                locationId: location.id,
                label: label,
                payload: draft.toLocalJson(),
                createdAt: draft.createdAt,
              ),
            );
        ref.invalidate(localDraftsProvider);
        if (mounted) setState(() => _draftSaved = true);
      } else {
        final repository = ref.read(repositoryProvider);
        final payload = draft.toApiJson('form:${draft.id}');
        final PostedResult result;
        switch (draft.kind) {
          case OperationKind.purchase:
            result = await repository.createPurchase(payload);
          case OperationKind.expense:
            result = await repository.createExpense(payload);
          case OperationKind.payment:
            result = await repository.createPayment(payload);
          case OperationKind.transfer:
            result = await repository.createTransfer(payload);
        }
        ref
          ..invalidate(dashboardProvider)
          ..invalidate(entriesProvider)
          ..invalidate(productsProvider)
          ..invalidate(partiesProvider);
        if (mounted) setState(() => _result = result);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = describeDioError(
              error,
              'The entry could not be saved.',
            ));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _labelFor(OperationDraft draft) => switch (draft.kind) {
        OperationKind.purchase =>
          '${context.strings.t('purchase')}: ${draft.payload['supplier_id']}',
        OperationKind.expense =>
          '${context.strings.t('expense')}: ${draft.payload['category']}',
        OperationKind.payment =>
          '${context.strings.t(draft.isReceipt ? 'receipt' : 'supplierPayment')}: ${draft.payload['party_id']}',
        OperationKind.transfer => context.strings.t('stockTransfer'),
      };

  Widget _buildSuccess(BuildContext context) => Center(
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
                      : context.strings.t('operationSaved'),
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

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty
          ? context.strings.t('required')
          : null;

  String? _positiveMinorValidator(String? value) =>
      parseMinor(value ?? '') <= 0 ? context.strings.t('invalidAmount') : null;

  String? _nonNegativeValidator(String? value) {
    final parsed = Decimal.tryParse(value ?? '');
    return parsed == null || parsed < Decimal.zero
        ? context.strings.t('invalidAmount')
        : null;
  }
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}

final _decimalFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'));

class _OperationLine {
  final packId = ValueNotifier<String?>(null);
  final quantity = TextEditingController(text: '1');
  final price = TextEditingController();
  final discount = TextEditingController(text: '0');

  void dispose() {
    packId.dispose();
    quantity.dispose();
    price.dispose();
    discount.dispose();
  }
}

class _OperationLineEditor extends StatelessWidget {
  const _OperationLineEditor({
    required this.line,
    required this.index,
    required this.products,
    required this.showCost,
    required this.canRemove,
    required this.onRemove,
    super.key,
  });

  final _OperationLine line;
  final int index;
  final List<Product> products;
  final bool showCost;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Padding(
      padding: const EdgeInsets.only(bottom: DukaanTokens.space3),
      child: DukaanCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${strings.t('lineItems')} ${index + 1}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: strings.t('removeLine'),
                  onPressed: canRemove ? onRemove : null,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
              ],
            ),
            ValueListenableBuilder<String?>(
              valueListenable: line.packId,
              builder: (context, value, _) => DropdownButtonFormField<String>(
                key: Key('operation-line-product-$index'),
                initialValue: value,
                isExpanded: true,
                decoration: InputDecoration(labelText: strings.t('product')),
                items: [
                  for (final product in products)
                    DropdownMenuItem(
                      value: product.packId,
                      child:
                          Text(product.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                validator: (value) =>
                    value == null ? strings.t('selectProduct') : null,
                onChanged: (selected) {
                  line.packId.value = selected;
                  // Purchase cost is entered explicitly; retail price is not a
                  // reliable proxy for supplier cost.
                },
              ),
            ),
            const SizedBox(height: DukaanTokens.space3),
            TextFormField(
              key: Key('operation-line-quantity-$index'),
              controller: line.quantity,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_decimalFormatter],
              decoration: InputDecoration(labelText: strings.t('quantity')),
              validator: (value) {
                final parsed = Decimal.tryParse(value ?? '');
                return parsed == null || parsed <= Decimal.zero
                    ? strings.t('invalidAmount')
                    : null;
              },
            ),
            if (showCost) ...[
              const SizedBox(height: DukaanTokens.space3),
              TextFormField(
                key: Key('operation-line-cost-$index'),
                controller: line.price,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_decimalFormatter],
                decoration: InputDecoration(
                  labelText: strings.t('unitCost'),
                  prefixText: '₹ ',
                ),
                validator: (value) => parseMinor(value ?? '') <= 0
                    ? strings.t('invalidAmount')
                    : null,
              ),
              const SizedBox(height: DukaanTokens.space3),
              TextFormField(
                key: Key('operation-line-discount-$index'),
                controller: line.discount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_decimalFormatter],
                decoration: InputDecoration(
                  labelText: strings.t('discount'),
                  prefixText: '₹ ',
                ),
                validator: (value) {
                  final parsed = Decimal.tryParse(value ?? '');
                  return parsed == null || parsed < Decimal.zero
                      ? strings.t('invalidAmount')
                      : null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return OutlinedButton.icon(
      key: const Key('operation-date'),
      onPressed: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(date.year - 5),
          lastDate: DateTime(date.year + 1),
        );
        if (selected != null) onChanged(selected);
      },
      icon: const Icon(Icons.event_outlined, size: 18),
      label: Text(
          '${strings.t('date')}: ${date.toIso8601String().split('T').first}'),
    );
  }
}

/// Shared read-only review used by new forms and their offline drafts.
class OperationReviewCard extends StatelessWidget {
  const OperationReviewCard({
    required this.draft,
    this.partyNames = const {},
    this.productNames = const {},
    this.locationNames = const {},
    super.key,
  });

  final OperationDraft draft;
  final Map<String, String> partyNames;
  final Map<String, String> productNames;
  final Map<String, String> locationNames;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final locale = Localizations.localeOf(context).languageCode;
    final payload = draft.payload;
    final lines = payload['lines'] is List
        ? (payload['lines'] as List).whereType<Map>().toList()
        : const <Map>[];
    return DukaanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.t(switch (draft.kind) {
              OperationKind.purchase => 'purchase',
              OperationKind.expense => 'expense',
              OperationKind.payment =>
                draft.isReceipt ? 'receipt' : 'supplierPayment',
              OperationKind.transfer => 'stockTransfer',
            }),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: DukaanTokens.space3),
          ...switch (draft.kind) {
            OperationKind.purchase => [
                _ReviewRow(
                  label: strings.t('supplier'),
                  value: partyNames[payload['supplier_id']] ??
                      payload['supplier_id'].toString(),
                ),
                if ((payload['supplier_bill_number'] ?? '')
                    .toString()
                    .isNotEmpty)
                  _ReviewRow(
                    label: strings.t('billNumber'),
                    value: payload['supplier_bill_number'].toString(),
                  ),
                for (final line in lines)
                  _ReviewRow(
                    label: productNames[line['pack_id']] ??
                        line['pack_id'].toString(),
                    value:
                        '${decimalFrom(line['quantity'])} × ${formatExactMoney(minorFrom(line['unit_cost_minor']), locale)}',
                  ),
                _ReviewRow(
                  label: strings.t('estimatedSubtotal'),
                  value: formatExactMoney(_purchaseSubtotal(payload), locale),
                  strong: true,
                ),
                _ReviewRow(
                  label: strings.t('paidNow'),
                  value: formatExactMoney(
                      minorFrom(payload['paid_amount_minor']), locale),
                ),
                _ReviewRow(
                  label: strings.t('taxMode'),
                  value: strings.t(payload['tax_inclusive'] == true
                      ? 'taxInclusive'
                      : 'taxExclusive'),
                ),
              ],
            OperationKind.expense => [
                _ReviewRow(
                  label: strings.t('category'),
                  value: payload['category'].toString(),
                ),
                if ((payload['payee'] ?? '').toString().isNotEmpty)
                  _ReviewRow(
                      label: strings.t('payee'),
                      value: payload['payee'].toString()),
                _ReviewRow(
                  label: strings.t('amount'),
                  value: formatExactMoney(
                      minorFrom(payload['amount_minor']), locale),
                  strong: true,
                ),
                _ReviewRow(
                  label: strings.t('taxAmount'),
                  value: formatExactMoney(
                      minorFrom(payload['tax_amount_minor']), locale),
                ),
                _ReviewRow(
                  label: strings.t('total'),
                  value: formatExactMoney(_expenseTotal(payload), locale),
                  strong: true,
                ),
              ],
            OperationKind.payment => [
                _ReviewRow(
                  label: strings.t(_receiptLabel(payload)),
                  value: partyNames[payload['party_id']] ??
                      payload['party_id'].toString(),
                ),
                _ReviewRow(
                  label: strings.t('amount'),
                  value: formatExactMoney(
                      minorFrom(payload['amount_minor']), locale),
                  strong: true,
                ),
                if ((payload['reference'] ?? '').toString().isNotEmpty)
                  _ReviewRow(
                    label: strings.t('reference'),
                    value: payload['reference'].toString(),
                  ),
              ],
            OperationKind.transfer => [
                _ReviewRow(
                  label: strings.t('fromLocation'),
                  value: locationNames[payload['from_location_id']] ??
                      payload['from_location_id'].toString(),
                ),
                _ReviewRow(
                  label: strings.t('toLocation'),
                  value: locationNames[payload['to_location_id']] ??
                      payload['to_location_id'].toString(),
                ),
                for (final line in lines)
                  _ReviewRow(
                    label: productNames[line['pack_id']] ??
                        line['pack_id'].toString(),
                    value: decimalFrom(line['quantity']).toString(),
                  ),
                if (payload['negative_stock_acknowledged'] == true)
                  _ReviewRow(
                    label: strings.t('negativeStockAck'),
                    value: payload['negative_stock_reason'].toString(),
                    warning: true,
                  ),
              ],
          },
          _ReviewRow(
            label: strings.t('date'),
            value: (payload['purchase_date'] ??
                    payload['expense_date'] ??
                    payload['payment_date'] ??
                    payload['transfer_date'] ??
                    '')
                .toString(),
          ),
          if (payload['payment_method'] != null || payload['method'] != null)
            _ReviewRow(
              label: strings.t('paymentMethod'),
              value:
                  (payload['payment_method'] ?? payload['method']).toString(),
            ),
          if ((payload['note'] ?? '').toString().isNotEmpty)
            _ReviewRow(
                label: strings.t('note'), value: payload['note'].toString()),
        ],
      ),
    );
  }

  String _receiptLabel(Map<String, dynamic> payload) =>
      payload['direction'] == 'RECEIPT' ? 'receipt' : 'supplierPayment';
}

int _purchaseSubtotal(Map<String, dynamic> payload) {
  final lines = payload['lines'] is List ? payload['lines'] as List : const [];
  var total = 0;
  for (final raw in lines.whereType<Map>()) {
    final gross = (decimalFrom(raw['quantity']) *
            Decimal.fromInt(minorFrom(raw['unit_cost_minor'])))
        .round()
        .toBigInt()
        .toInt();
    total += gross - minorFrom(raw['discount_minor']);
  }
  return total - minorFrom(payload['discount_total_minor']);
}

int _expenseTotal(Map<String, dynamic> payload) =>
    minorFrom(payload['amount_minor']) + minorFrom(payload['tax_amount_minor']);

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
        padding: const EdgeInsets.only(bottom: DukaanTokens.space3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: DukaanTokens.textLabel.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
                  color: warning
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurface,
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
