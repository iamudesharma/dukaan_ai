import 'package:decimal/decimal.dart';
import 'package:dukaan_ai_mobile/core/formatters.dart';
import 'package:dukaan_ai_mobile/domain/models.dart';
import 'package:dukaan_ai_mobile/l10n/app_strings.dart';
import 'package:dukaan_ai_mobile/state/app_providers.dart';
import 'package:dukaan_ai_mobile/ui/common/async_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum QuickKind { purchase, expense }

class QuickEntryPage extends ConsumerStatefulWidget {
  const QuickEntryPage({required this.kind, super.key});

  final QuickKind kind;

  @override
  ConsumerState<QuickEntryPage> createState() => _QuickEntryPageState();
}

class _QuickEntryPageState extends ConsumerState<QuickEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController(text: '1');
  final _unitCost = TextEditingController();
  final _paid = TextEditingController(text: '0');
  final _category = TextEditingController();
  final _amount = TextEditingController();
  final _payee = TextEditingController();
  final _billNumber = TextEditingController();
  String? _partyId;
  String? _productId;
  PaymentMethod _method = PaymentMethod.cash;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _quantity.dispose();
    _unitCost.dispose();
    _paid.dispose();
    _category.dispose();
    _amount.dispose();
    _payee.dispose();
    _billNumber.dispose();
    super.dispose();
  }

  bool get _isPurchase => widget.kind == QuickKind.purchase;

  Future<void> _submit(List<Product> products, List<Party> parties) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final location = await ref.read(activeLocationProvider.future);
      final repository = ref.read(repositoryProvider);
      if (_isPurchase) {
        final product = products.firstWhere((item) => item.id == _productId);
        await repository.createPurchase({
          'business_id': location.businessId,
          'location_id': location.id,
          'supplier_id': _partyId,
          'lines': [
            {
              'pack_id': product.packId,
              'quantity': _quantity.text.trim(),
              'unit_cost_minor': parseMinor(_unitCost.text),
            },
          ],
          'paid_amount_minor': parseMinor(_paid.text),
          'payment_method': _method.apiValue,
          if (_billNumber.text.trim().isNotEmpty)
            'supplier_bill_number': _billNumber.text.trim(),
        });
      } else {
        await repository.createExpense({
          'business_id': location.businessId,
          'location_id': location.id,
          'category': _category.text.trim(),
          'amount_minor': parseMinor(_amount.text),
          'payment_method': _method.apiValue,
          if (_payee.text.trim().isNotEmpty) 'payee': _payee.text.trim(),
        });
      }
      invalidateBusinessData(ref.invalidate);
      if (mounted) context.go('/entries');
    } on Object catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final products = ref.watch(productsProvider);
    final parties = ref.watch(partiesProvider);
    if (products.isLoading || parties.isLoading) return const LoadingContent();
    if (products.hasError || parties.hasError) {
      return ErrorContent(
        message: (products.error ?? parties.error).toString(),
        onRetry: () {
          ref
            ..invalidate(productsProvider)
            ..invalidate(partiesProvider);
        },
      );
    }
    final productItems = products.requireValue;
    final suppliers = parties.requireValue
        .where((party) => party.kind != PartyKind.customer)
        .toList(growable: false);
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
                _isPurchase ? strings.t('newPurchase') : strings.t('newExpense'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isPurchase) ...[
            DropdownButtonFormField<String>(
              initialValue: _partyId,
              decoration: InputDecoration(labelText: strings.t('supplierOptional')),
              items: suppliers
                  .map(
                    (party) => DropdownMenuItem(
                      value: party.id,
                      child: Text(party.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              validator: (value) => value == null ? strings.t('selectSupplier') : null,
              onChanged: (value) => setState(() => _partyId = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _productId,
              decoration: InputDecoration(labelText: strings.t('product')),
              items: productItems
                  .map(
                    (product) => DropdownMenuItem(
                      value: product.id,
                      child: Text(product.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              validator: (value) => value == null ? strings.t('selectProduct') : null,
              onChanged: (value) => setState(() => _productId = value),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantity,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: InputDecoration(labelText: strings.t('quantity')),
                    validator: _positive,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _unitCost,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: InputDecoration(
                      labelText: strings.t('unitPrice'),
                      prefixText: '₹ ',
                    ),
                    validator: _positive,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _paid,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: InputDecoration(
                labelText: strings.t('paidNow'),
                prefixText: '₹ ',
                helperText: strings.t('noMoneyMovement'),
                helperMaxLines: 2,
              ),
              validator: _nonNegative,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _billNumber,
              decoration: InputDecoration(labelText: strings.t('billNumberOptional')),
            ),
          ] else ...[
            TextFormField(
              controller: _category,
              decoration: InputDecoration(
                labelText: strings.t('categoryLabel'),
                hintText: strings.t('categoryHint'),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? strings.t('required') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              decoration: InputDecoration(
                labelText: strings.t('paymentAmount'),
                prefixText: '₹ ',
              ),
              validator: _positive,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _payee,
              decoration: InputDecoration(labelText: strings.t('payeeOptional')),
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _method,
            decoration: InputDecoration(labelText: strings.t('paymentMethod')),
            items: PaymentMethod.values
                .map((method) => DropdownMenuItem(value: method, child: Text(method.apiValue)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _method = value);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : () => _submit(productItems, parties.requireValue),
            child: Text(
              _saving
                  ? strings.t('parsing')
                  : _isPurchase
                      ? strings.t('recordPurchase')
                      : strings.t('recordExpense'),
            ),
          ),
        ],
      ),
    );
  }

  String? _positive(String? value) {
    final parsed = Decimal.tryParse(value ?? '');
    if (parsed == null || parsed <= Decimal.zero) return context.strings.t('invalidAmount');
    return null;
  }

  String? _nonNegative(String? value) {
    final parsed = Decimal.tryParse(value ?? '');
    if (parsed == null || parsed < Decimal.zero) return context.strings.t('invalidAmount');
    return null;
  }
}
