// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_metrics.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SalesMetricsCWProxy {
  SalesMetrics postedSaleCount(int postedSaleCount);

  SalesMetrics lineCount(int lineCount);

  SalesMetrics netSalesMinor(int netSalesMinor);

  SalesMetrics cogsMinor(int cogsMinor);

  SalesMetrics grossProfitMinor(int? grossProfitMinor);

  SalesMetrics missingCostLineCount(int missingCostLineCount);

  SalesMetrics costingComplete(bool costingComplete);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SalesMetrics(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SalesMetrics(...).copyWith(id: 12, name: "My name")
  /// ````
  SalesMetrics call({
    int postedSaleCount,
    int lineCount,
    int netSalesMinor,
    int cogsMinor,
    int? grossProfitMinor,
    int missingCostLineCount,
    bool costingComplete,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSalesMetrics.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSalesMetrics.copyWith.fieldName(...)`
class _$SalesMetricsCWProxyImpl implements _$SalesMetricsCWProxy {
  const _$SalesMetricsCWProxyImpl(this._value);

  final SalesMetrics _value;

  @override
  SalesMetrics postedSaleCount(int postedSaleCount) =>
      this(postedSaleCount: postedSaleCount);

  @override
  SalesMetrics lineCount(int lineCount) => this(lineCount: lineCount);

  @override
  SalesMetrics netSalesMinor(int netSalesMinor) =>
      this(netSalesMinor: netSalesMinor);

  @override
  SalesMetrics cogsMinor(int cogsMinor) => this(cogsMinor: cogsMinor);

  @override
  SalesMetrics grossProfitMinor(int? grossProfitMinor) =>
      this(grossProfitMinor: grossProfitMinor);

  @override
  SalesMetrics missingCostLineCount(int missingCostLineCount) =>
      this(missingCostLineCount: missingCostLineCount);

  @override
  SalesMetrics costingComplete(bool costingComplete) =>
      this(costingComplete: costingComplete);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SalesMetrics(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SalesMetrics(...).copyWith(id: 12, name: "My name")
  /// ````
  SalesMetrics call({
    Object? postedSaleCount = const $CopyWithPlaceholder(),
    Object? lineCount = const $CopyWithPlaceholder(),
    Object? netSalesMinor = const $CopyWithPlaceholder(),
    Object? cogsMinor = const $CopyWithPlaceholder(),
    Object? grossProfitMinor = const $CopyWithPlaceholder(),
    Object? missingCostLineCount = const $CopyWithPlaceholder(),
    Object? costingComplete = const $CopyWithPlaceholder(),
  }) {
    return SalesMetrics(
      postedSaleCount: postedSaleCount == const $CopyWithPlaceholder()
          ? _value.postedSaleCount
          // ignore: cast_nullable_to_non_nullable
          : postedSaleCount as int,
      lineCount: lineCount == const $CopyWithPlaceholder()
          ? _value.lineCount
          // ignore: cast_nullable_to_non_nullable
          : lineCount as int,
      netSalesMinor: netSalesMinor == const $CopyWithPlaceholder()
          ? _value.netSalesMinor
          // ignore: cast_nullable_to_non_nullable
          : netSalesMinor as int,
      cogsMinor: cogsMinor == const $CopyWithPlaceholder()
          ? _value.cogsMinor
          // ignore: cast_nullable_to_non_nullable
          : cogsMinor as int,
      grossProfitMinor: grossProfitMinor == const $CopyWithPlaceholder()
          ? _value.grossProfitMinor
          // ignore: cast_nullable_to_non_nullable
          : grossProfitMinor as int?,
      missingCostLineCount: missingCostLineCount == const $CopyWithPlaceholder()
          ? _value.missingCostLineCount
          // ignore: cast_nullable_to_non_nullable
          : missingCostLineCount as int,
      costingComplete: costingComplete == const $CopyWithPlaceholder()
          ? _value.costingComplete
          // ignore: cast_nullable_to_non_nullable
          : costingComplete as bool,
    );
  }
}

extension $SalesMetricsCopyWith on SalesMetrics {
  /// Returns a callable class that can be used as follows: `instanceOfSalesMetrics.copyWith(...)` or like so:`instanceOfSalesMetrics.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SalesMetricsCWProxy get copyWith => _$SalesMetricsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesMetrics _$SalesMetricsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SalesMetrics',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'posted_sale_count',
            'line_count',
            'net_sales_minor',
            'cogs_minor',
            'gross_profit_minor',
            'missing_cost_line_count',
            'costing_complete',
          ],
        );
        final val = SalesMetrics(
          postedSaleCount: $checkedConvert(
            'posted_sale_count',
            (v) => (v as num).toInt(),
          ),
          lineCount: $checkedConvert('line_count', (v) => (v as num).toInt()),
          netSalesMinor: $checkedConvert(
            'net_sales_minor',
            (v) => (v as num).toInt(),
          ),
          cogsMinor: $checkedConvert('cogs_minor', (v) => (v as num).toInt()),
          grossProfitMinor: $checkedConvert(
            'gross_profit_minor',
            (v) => (v as num?)?.toInt(),
          ),
          missingCostLineCount: $checkedConvert(
            'missing_cost_line_count',
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
        'postedSaleCount': 'posted_sale_count',
        'lineCount': 'line_count',
        'netSalesMinor': 'net_sales_minor',
        'cogsMinor': 'cogs_minor',
        'grossProfitMinor': 'gross_profit_minor',
        'missingCostLineCount': 'missing_cost_line_count',
        'costingComplete': 'costing_complete',
      },
    );

Map<String, dynamic> _$SalesMetricsToJson(SalesMetrics instance) =>
    <String, dynamic>{
      'posted_sale_count': instance.postedSaleCount,
      'line_count': instance.lineCount,
      'net_sales_minor': instance.netSalesMinor,
      'cogs_minor': instance.cogsMinor,
      'gross_profit_minor': instance.grossProfitMinor,
      'missing_cost_line_count': instance.missingCostLineCount,
      'costing_complete': instance.costingComplete,
    };
