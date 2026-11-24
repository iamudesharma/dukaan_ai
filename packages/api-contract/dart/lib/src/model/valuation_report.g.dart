// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'valuation_report.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ValuationReportCWProxy {
  ValuationReport inventory(ValuationInventory inventory);

  ValuationReport sales(SalesMetrics sales);

  ValuationReport results(List<ValuationRow> results);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ValuationReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ValuationReport(...).copyWith(id: 12, name: "My name")
  /// ````
  ValuationReport call({
    ValuationInventory inventory,
    SalesMetrics sales,
    List<ValuationRow> results,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfValuationReport.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfValuationReport.copyWith.fieldName(...)`
class _$ValuationReportCWProxyImpl implements _$ValuationReportCWProxy {
  const _$ValuationReportCWProxyImpl(this._value);

  final ValuationReport _value;

  @override
  ValuationReport inventory(ValuationInventory inventory) =>
      this(inventory: inventory);

  @override
  ValuationReport sales(SalesMetrics sales) => this(sales: sales);

  @override
  ValuationReport results(List<ValuationRow> results) => this(results: results);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ValuationReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ValuationReport(...).copyWith(id: 12, name: "My name")
  /// ````
  ValuationReport call({
    Object? inventory = const $CopyWithPlaceholder(),
    Object? sales = const $CopyWithPlaceholder(),
    Object? results = const $CopyWithPlaceholder(),
  }) {
    return ValuationReport(
      inventory: inventory == const $CopyWithPlaceholder()
          ? _value.inventory
          // ignore: cast_nullable_to_non_nullable
          : inventory as ValuationInventory,
      sales: sales == const $CopyWithPlaceholder()
          ? _value.sales
          // ignore: cast_nullable_to_non_nullable
          : sales as SalesMetrics,
      results: results == const $CopyWithPlaceholder()
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<ValuationRow>,
    );
  }
}

extension $ValuationReportCopyWith on ValuationReport {
  /// Returns a callable class that can be used as follows: `instanceOfValuationReport.copyWith(...)` or like so:`instanceOfValuationReport.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ValuationReportCWProxy get copyWith => _$ValuationReportCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ValuationReport _$ValuationReportFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ValuationReport', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['inventory', 'sales', 'results']);
      final val = ValuationReport(
        inventory: $checkedConvert(
          'inventory',
          (v) => ValuationInventory.fromJson(v as Map<String, dynamic>),
        ),
        sales: $checkedConvert(
          'sales',
          (v) => SalesMetrics.fromJson(v as Map<String, dynamic>),
        ),
        results: $checkedConvert(
          'results',
          (v) => (v as List<dynamic>)
              .map((e) => ValuationRow.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ValuationReportToJson(ValuationReport instance) =>
    <String, dynamic>{
      'inventory': instance.inventory.toJson(),
      'sales': instance.sales.toJson(),
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
