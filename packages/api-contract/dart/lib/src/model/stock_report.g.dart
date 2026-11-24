// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_report.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StockReportCWProxy {
  StockReport results(List<StockReportRow> results);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StockReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StockReport(...).copyWith(id: 12, name: "My name")
  /// ````
  StockReport call({List<StockReportRow> results});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStockReport.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStockReport.copyWith.fieldName(...)`
class _$StockReportCWProxyImpl implements _$StockReportCWProxy {
  const _$StockReportCWProxyImpl(this._value);

  final StockReport _value;

  @override
  StockReport results(List<StockReportRow> results) => this(results: results);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StockReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StockReport(...).copyWith(id: 12, name: "My name")
  /// ````
  StockReport call({Object? results = const $CopyWithPlaceholder()}) {
    return StockReport(
      results: results == const $CopyWithPlaceholder()
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<StockReportRow>,
    );
  }
}

extension $StockReportCopyWith on StockReport {
  /// Returns a callable class that can be used as follows: `instanceOfStockReport.copyWith(...)` or like so:`instanceOfStockReport.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StockReportCWProxy get copyWith => _$StockReportCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockReport _$StockReportFromJson(Map<String, dynamic> json) =>
    $checkedCreate('StockReport', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['results']);
      final val = StockReport(
        results: $checkedConvert(
          'results',
          (v) => (v as List<dynamic>)
              .map((e) => StockReportRow.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$StockReportToJson(StockReport instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
