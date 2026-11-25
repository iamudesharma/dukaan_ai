// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valuation_inventory.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ValuationInventoryCWProxy {
  ValuationInventory totalQuantity(double totalQuantity);

  ValuationInventory averageCostMinor(int? averageCostMinor);

  ValuationInventory totalValueMinor(int? totalValueMinor);

  ValuationInventory knownValueMinor(int knownValueMinor);

  ValuationInventory costingComplete(bool costingComplete);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ValuationInventory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ValuationInventory(...).copyWith(id: 12, name: "My name")
  /// ````
  ValuationInventory call({
    double totalQuantity,
    int? averageCostMinor,
    int? totalValueMinor,
    int knownValueMinor,
    bool costingComplete,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfValuationInventory.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfValuationInventory.copyWith.fieldName(...)`
class _$ValuationInventoryCWProxyImpl implements _$ValuationInventoryCWProxy {
  const _$ValuationInventoryCWProxyImpl(this._value);

  final ValuationInventory _value;

  @override
  ValuationInventory totalQuantity(double totalQuantity) =>
      this(totalQuantity: totalQuantity);

  @override
  ValuationInventory averageCostMinor(int? averageCostMinor) =>
      this(averageCostMinor: averageCostMinor);

  @override
  ValuationInventory totalValueMinor(int? totalValueMinor) =>
      this(totalValueMinor: totalValueMinor);

  @override
  ValuationInventory knownValueMinor(int knownValueMinor) =>
      this(knownValueMinor: knownValueMinor);

  @override
  ValuationInventory costingComplete(bool costingComplete) =>
      this(costingComplete: costingComplete);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ValuationInventory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ValuationInventory(...).copyWith(id: 12, name: "My name")
  /// ````
  ValuationInventory call({
    Object? totalQuantity = const $CopyWithPlaceholder(),
    Object? averageCostMinor = const $CopyWithPlaceholder(),
    Object? totalValueMinor = const $CopyWithPlaceholder(),
    Object? knownValueMinor = const $CopyWithPlaceholder(),
    Object? costingComplete = const $CopyWithPlaceholder(),
  }) {
    return ValuationInventory(
      totalQuantity: totalQuantity == const $CopyWithPlaceholder()
          ? _value.totalQuantity
          // ignore: cast_nullable_to_non_nullable
          : totalQuantity as double,
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
      costingComplete: costingComplete == const $CopyWithPlaceholder()
          ? _value.costingComplete
          // ignore: cast_nullable_to_non_nullable
          : costingComplete as bool,
    );
  }
}

extension $ValuationInventoryCopyWith on ValuationInventory {
  /// Returns a callable class that can be used as follows: `instanceOfValuationInventory.copyWith(...)` or like so:`instanceOfValuationInventory.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ValuationInventoryCWProxy get copyWith =>
      _$ValuationInventoryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValuationInventory _$ValuationInventoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ValuationInventory',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'total_quantity',
            'average_cost_minor',
            'total_value_minor',
            'known_value_minor',
            'costing_complete',
          ],
        );
        final val = ValuationInventory(
          totalQuantity: $checkedConvert(
            'total_quantity',
            (v) => (v as num).toDouble(),
          ),
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
          costingComplete: $checkedConvert(
            'costing_complete',
            (v) => v as bool,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'totalQuantity': 'total_quantity',
        'averageCostMinor': 'average_cost_minor',
        'totalValueMinor': 'total_value_minor',
        'knownValueMinor': 'known_value_minor',
        'costingComplete': 'costing_complete',
      },
    );

Map<String, dynamic> _$ValuationInventoryToJson(ValuationInventory instance) =>
    <String, dynamic>{
      'total_quantity': instance.totalQuantity,
      'average_cost_minor': instance.averageCostMinor,
      'total_value_minor': instance.totalValueMinor,
      'known_value_minor': instance.knownValueMinor,
      'costing_complete': instance.costingComplete,
    };
