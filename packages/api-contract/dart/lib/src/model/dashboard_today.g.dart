// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_today.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardTodayCWProxy {
  DashboardToday salesMinor(int salesMinor);

  DashboardToday purchasesMinor(int purchasesMinor);

  DashboardToday expensesMinor(int expensesMinor);

  DashboardToday receiptsMinor(int receiptsMinor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardToday(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardToday(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardToday call({
    int salesMinor,
    int purchasesMinor,
    int expensesMinor,
    int receiptsMinor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboardToday.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboardToday.copyWith.fieldName(...)`
class _$DashboardTodayCWProxyImpl implements _$DashboardTodayCWProxy {
  const _$DashboardTodayCWProxyImpl(this._value);

  final DashboardToday _value;

  @override
  DashboardToday salesMinor(int salesMinor) => this(salesMinor: salesMinor);

  @override
  DashboardToday purchasesMinor(int purchasesMinor) =>
      this(purchasesMinor: purchasesMinor);

  @override
  DashboardToday expensesMinor(int expensesMinor) =>
      this(expensesMinor: expensesMinor);

  @override
  DashboardToday receiptsMinor(int receiptsMinor) =>
      this(receiptsMinor: receiptsMinor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardToday(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardToday(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardToday call({
    Object? salesMinor = const $CopyWithPlaceholder(),
    Object? purchasesMinor = const $CopyWithPlaceholder(),
    Object? expensesMinor = const $CopyWithPlaceholder(),
    Object? receiptsMinor = const $CopyWithPlaceholder(),
  }) {
    return DashboardToday(
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
    );
  }
}

extension $DashboardTodayCopyWith on DashboardToday {
  /// Returns a callable class that can be used as follows: `instanceOfDashboardToday.copyWith(...)` or like so:`instanceOfDashboardToday.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardTodayCWProxy get copyWith => _$DashboardTodayCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardToday _$DashboardTodayFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'DashboardToday',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'sales_minor',
            'purchases_minor',
            'expenses_minor',
            'receipts_minor',
          ],
        );
        final val = DashboardToday(
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
        );
        return val;
      },
      fieldKeyMap: const {
        'salesMinor': 'sales_minor',
        'purchasesMinor': 'purchases_minor',
        'expensesMinor': 'expenses_minor',
        'receiptsMinor': 'receipts_minor',
      },
    );

Map<String, dynamic> _$DashboardTodayToJson(DashboardToday instance) =>
    <String, dynamic>{
      'sales_minor': instance.salesMinor,
      'purchases_minor': instance.purchasesMinor,
      'expenses_minor': instance.expensesMinor,
      'receipts_minor': instance.receiptsMinor,
    };
