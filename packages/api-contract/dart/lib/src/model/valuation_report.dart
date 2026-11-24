//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/valuation_row.dart';
import 'package:dukaanai_api_client/src/model/sales_metrics.dart';
import 'package:dukaanai_api_client/src/model/valuation_inventory.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'valuation_report.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ValuationReport {
  /// Returns a new [ValuationReport] instance.
  ValuationReport({
    required this.inventory,

    required this.sales,

    required this.results,
  });

  @JsonKey(name: r'inventory', required: true, includeIfNull: false)
  final ValuationInventory inventory;

  @JsonKey(name: r'sales', required: true, includeIfNull: false)
  final SalesMetrics sales;

  @JsonKey(name: r'results', required: true, includeIfNull: false)
  final List<ValuationRow> results;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValuationReport &&
          other.inventory == inventory &&
          other.sales == sales &&
          other.results == results;

  @override
  int get hashCode => inventory.hashCode + sales.hashCode + results.hashCode;

  factory ValuationReport.fromJson(Map<String, dynamic> json) =>
      _$ValuationReportFromJson(json);

  Map<String, dynamic> toJson() => _$ValuationReportToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
