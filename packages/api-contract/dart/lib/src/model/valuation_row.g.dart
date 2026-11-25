// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valuation_row.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ValuationRowCWProxy {
  ValuationRow productId(String productId);

  ValuationRow name(String name);

  ValuationRow unit(String unit);

  ValuationRow quantity(double quantity);

  ValuationRow averageCostMinor(int? averageCostMinor);

  ValuationRow totalValueMinor(int? totalValueMinor);

  ValuationRow knownValueMinor(int knownValueMinor);

  ValuationRow unknownCostQuantity(double unknownCostQuantity);

  ValuationRow costingComplete(bool costingComplete);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ValuationRow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ValuationRow(...).copyWith(id: 12, name: "My name")
  /// ````
  ValuationRow call({
    String productId,
    String name,
    String unit,
    double quantity,
    int? averageCostMinor,
    int? totalValueMinor,
    int knownValueMinor,
    double unknownCostQuantity,
    bool costingComplete,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfValuationRow.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfValuationRow.copyWith.fieldName(...)`
class _$ValuationRowCWProxyImpl implements _$ValuationRowCWProxy {
  const _$ValuationRowCWProxyImpl(this._value);

  final ValuationRow _value;

  @override
  ValuationRow productId(String productId) => this(productId: productId);

  @override
  ValuationRow name(String name) => this(name: name);

  @override
  ValuationRow unit(String unit) => this(unit: unit);

  @override
  ValuationRow quantity(double quantity) => this(quantity: quantity);

  @override
  ValuationRow averageCostMinor(int? averageCostMinor) =>
      this(averageCostMinor: averageCostMinor);

  @override
  ValuationRow totalValueMinor(int? totalValueMinor) =>
      this(totalValueMinor: totalValueMinor);

  @override
  ValuationRow knownValueMinor(int knownValueMinor) =>
      this(knownValueMinor: knownValueMinor);

  @override
  ValuationRow unknownCostQuantity(double unknownCostQuantity) =>
      this(unknownCostQuantity: unknownCostQuantity);

  @override
  ValuationRow costingComplete(bool costingComplete) =>
      this(costingComplete: costingComplete);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ValuationRow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ValuationRow(...).copyWith(id: 12, name: "My name")
  /// ````
  ValuationRow call({
    Object? productId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? unit = const $CopyWithPlaceholder(),
    Object? quantity = const $CopyWithPlaceholder(),
    Object? averageCostMinor = const $CopyWithPlaceholder(),
    Object? totalValueMinor = const $CopyWithPlaceholder(),
    Object? knownValueMinor = const $CopyWithPlaceholder(),
    Object? unknownCostQuantity = const $CopyWithPlaceholder(),
    Object? costingComplete = const $CopyWithPlaceholder(),
  }) {
    return ValuationRow(
      productId: productId == const $CopyWithPlaceholder()
          ? _value.productId
          // ignore: cast_nullable_to_non_nullable
          : productId as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      unit: unit == const $CopyWithPlaceholder()
          ? _value.unit
          // ignore: cast_nullable_to_non_nullable
          : unit as String,
      quantity: quantity == const $CopyWithPlaceholder()
          ? _value.quantity
          // ignore: cast_nullable_to_non_nullable
          : quantity as double,
      averageCostMinor: averageCostMinor == const $CopyWithPlaceholder()
          ? _value.averageCostMinor
          // ignore: cast_nullable_to_non_nullable
          : averageCostMinor as int?,
      totalValueMinor: totalValueMinor == const $CopyWithPlaceholder()
          ? _value.totalValueMinor
          // ignore: cast_nullable_to_non_nullable
          : totalValueMinor as int?,
      knownValueMinor: knownValueMinor == const $CopyWithPlaceholder()
          ? _value.knownValueMinor
          // ignore: cast_nullable_to_non_nullable
          : knownValueMinor as int,
      unknownCostQuantity: unknownCostQuantity == const $CopyWithPlaceholder()
          ? _value.unknownCostQuantity
          // ignore: cast_nullable_to_non_nullable
          : unknownCostQuantity as double,
      costingComplete: costingComplete == const $CopyWithPlaceholder()
          ? _value.costingComplete
          // ignore: cast_nullable_to_non_nullable
          : costingComplete as bool,
    );
  }
}

extension $ValuationRowCopyWith on ValuationRow {
  /// Returns a callable class that can be used as follows: `instanceOfValuationRow.copyWith(...)` or like so:`instanceOfValuationRow.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ValuationRowCWProxy get copyWith => _$ValuationRowCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValuationRow _$ValuationRowFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ValuationRow',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'product_id',
            'name',
            'unit',
            'quantity',
            'average_cost_minor',
            'total_value_minor',
            'known_value_minor',
            'unknown_cost_quantity',
            'costing_complete',
          ],
        );
        final val = ValuationRow(
          productId: $checkedConvert('product_id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          unit: $checkedConvert('unit', (v) => v as String),
          quantity: $checkedConvert('quantity', (v) => (v as num).toDouble()),
          averageCostMinor: $checkedConvert(
            'average_cost_minor',
            (v) => (v as num?)?.toInt(),
          ),
          totalValueMinor: $checkedConvert(
            'total_value_minor',
            (v) => (v as num?)?.toInt(),
          ),
          knownValueMinor: $checkedConvert(
            'known_value_minor',
            (v) => (v as num).toInt(),
          ),
          unknownCostQuantity: $checkedConvert(
            'unknown_cost_quantity',
            (v) => (v as num).toDouble(),
          ),
          costingComplete: $checkedConvert(
            'costing_complete',
            (v) => v as bool,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'productId': 'product_id',
        'averageCostMinor': 'average_cost_minor',
        'totalValueMinor': 'total_value_minor',
        'knownValueMinor': 'known_value_minor',
        'unknownCostQuantity': 'unknown_cost_quantity',
        'costingComplete': 'costing_complete',
      },
    );

Map<String, dynamic> _$ValuationRowToJson(ValuationRow instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'name': instance.name,
      'unit': instance.unit,
      'quantity': instance.quantity,
      'average_cost_minor': instance.averageCostMinor,
      'total_value_minor': instance.totalValueMinor,
      'known_value_minor': instance.knownValueMinor,
      'unknown_cost_quantity': instance.unknownCostQuantity,
      'costing_complete': instance.costingComplete,
    };
