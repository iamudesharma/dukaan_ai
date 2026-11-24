// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_books.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardBooksCWProxy {
  DashboardBooks salesMinor(int salesMinor);

  DashboardBooks purchasesMinor(int purchasesMinor);

  DashboardBooks expensesMinor(int expensesMinor);

  DashboardBooks receiptsMinor(int receiptsMinor);

  DashboardBooks supplierPaymentsMinor(int supplierPaymentsMinor);

  DashboardBooks receivableMinor(int receivableMinor);

  DashboardBooks payableMinor(int payableMinor);

  DashboardBooks cashFlowMinor(int cashFlowMinor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardBooks(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardBooks(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardBooks call({
    int salesMinor,
    int purchasesMinor,
    int expensesMinor,
    int receiptsMinor,
    int supplierPaymentsMinor,
    int receivableMinor,
    int payableMinor,
    int cashFlowMinor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboardBooks.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboardBooks.copyWith.fieldName(...)`
class _$DashboardBooksCWProxyImpl implements _$DashboardBooksCWProxy {
  const _$DashboardBooksCWProxyImpl(this._value);

  final DashboardBooks _value;

  @override
  DashboardBooks salesMinor(int salesMinor) => this(salesMinor: salesMinor);

  @override
  DashboardBooks purchasesMinor(int purchasesMinor) =>
      this(purchasesMinor: purchasesMinor);

  @override
  DashboardBooks expensesMinor(int expensesMinor) =>
      this(expensesMinor: expensesMinor);

  @override
  DashboardBooks receiptsMinor(int receiptsMinor) =>
      this(receiptsMinor: receiptsMinor);

  @override
  DashboardBooks supplierPaymentsMinor(int supplierPaymentsMinor) =>
      this(supplierPaymentsMinor: supplierPaymentsMinor);

  @override
  DashboardBooks receivableMinor(int receivableMinor) =>
      this(receivableMinor: receivableMinor);

  @override
  DashboardBooks payableMinor(int payableMinor) =>
      this(payableMinor: payableMinor);

  @override
  DashboardBooks cashFlowMinor(int cashFlowMinor) =>
      this(cashFlowMinor: cashFlowMinor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardBooks(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardBooks(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardBooks call({
    Object? salesMinor = const $CopyWithPlaceholder(),
    Object? purchasesMinor = const $CopyWithPlaceholder(),
    Object? expensesMinor = const $CopyWithPlaceholder(),
    Object? receiptsMinor = const $CopyWithPlaceholder(),
    Object? supplierPaymentsMinor = const $CopyWithPlaceholder(),
    Object? receivableMinor = const $CopyWithPlaceholder(),
    Object? payableMinor = const $CopyWithPlaceholder(),
    Object? cashFlowMinor = const $CopyWithPlaceholder(),
  }) {
    return DashboardBooks(
      salesMinor: salesMinor == const $CopyWithPlaceholder()
          ? _value.salesMinor
          // ignore: cast_nullable_to_non_nullable
          : salesMinor as int,
      purchasesMinor: purchasesMinor == const $CopyWithPlaceholder()
          ? _value.purchasesMinor
          // ignore: cast_nullable_to_non_nullable
          : purchasesMinor as int,
      expensesMinor: expensesMinor == const $CopyWithPlaceholder()
          ? _value.expensesMinor
          // ignore: cast_nullable_to_non_nullable
          : expensesMinor as int,
      receiptsMinor: receiptsMinor == const $CopyWithPlaceholder()
          ? _value.receiptsMinor
          // ignore: cast_nullable_to_non_nullable
          : receiptsMinor as int,
      supplierPaymentsMinor:
          supplierPaymentsMinor == const $CopyWithPlaceholder()
          ? _value.supplierPaymentsMinor
          // ignore: cast_nullable_to_non_nullable
          : supplierPaymentsMinor as int,
      receivableMinor: receivableMinor == const $CopyWithPlaceholder()
          ? _value.receivableMinor
          // ignore: cast_nullable_to_non_nullable
          : receivableMinor as int,
      payableMinor: payableMinor == const $CopyWithPlaceholder()
          ? _value.payableMinor
          // ignore: cast_nullable_to_non_nullable
          : payableMinor as int,
      cashFlowMinor: cashFlowMinor == const $CopyWithPlaceholder()
          ? _value.cashFlowMinor
          // ignore: cast_nullable_to_non_nullable
          : cashFlowMinor as int,
    );
  }
}

extension $DashboardBooksCopyWith on DashboardBooks {
  /// Returns a callable class that can be used as follows: `instanceOfDashboardBooks.copyWith(...)` or like so:`instanceOfDashboardBooks.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardBooksCWProxy get copyWith => _$DashboardBooksCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardBooks _$DashboardBooksFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'DashboardBooks',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'sales_minor',
            'purchases_minor',
            'expenses_minor',
            'receipts_minor',
            'supplier_payments_minor',
            'receivable_minor',
            'payable_minor',
            'cash_flow_minor',
          ],
        );
        final val = DashboardBooks(
          salesMinor: $checkedConvert('sales_minor', (v) => (v as num).toInt()),
          purchasesMinor: $checkedConvert(
            'purchases_minor',
            (v) => (v as num).toInt(),
          ),
          expensesMinor: $checkedConvert(
            'expenses_minor',
            (v) => (v as num).toInt(),
          ),
          receiptsMinor: $checkedConvert(
            'receipts_minor',
            (v) => (v as num).toInt(),
          ),
          supplierPaymentsMinor: $checkedConvert(
            'supplier_payments_minor',
            (v) => (v as num).toInt(),
          ),
          receivableMinor: $checkedConvert(
            'receivable_minor',
            (v) => (v as num).toInt(),
          ),
          payableMinor: $checkedConvert(
            'payable_minor',
            (v) => (v as num).toInt(),
          ),
          cashFlowMinor: $checkedConvert(
            'cash_flow_minor',
            (v) => (v as num).toInt(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'salesMinor': 'sales_minor',
        'purchasesMinor': 'purchases_minor',
        'expensesMinor': 'expenses_minor',
        'receiptsMinor': 'receipts_minor',
        'supplierPaymentsMinor': 'supplier_payments_minor',
        'receivableMinor': 'receivable_minor',
        'payableMinor': 'payable_minor',
        'cashFlowMinor': 'cash_flow_minor',
      },
    );

Map<String, dynamic> _$DashboardBooksToJson(DashboardBooks instance) =>
    <String, dynamic>{
      'sales_minor': instance.salesMinor,
      'purchases_minor': instance.purchasesMinor,
      'expenses_minor': instance.expensesMinor,
      'receipts_minor': instance.receiptsMinor,
      'supplier_payments_minor': instance.supplierPaymentsMinor,
      'receivable_minor': instance.receivableMinor,
      'payable_minor': instance.payableMinor,
      'cash_flow_minor': instance.cashFlowMinor,
    };
