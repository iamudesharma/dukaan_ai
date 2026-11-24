//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sales_metrics.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SalesMetrics {
  /// Returns a new [SalesMetrics] instance.
  SalesMetrics({
    required this.postedSaleCount,

    required this.lineCount,

    required this.netSalesMinor,

    required this.cogsMinor,

    required this.grossProfitMinor,

    required this.missingCostLineCount,

    required this.costingComplete,
  });

  @JsonKey(name: r'posted_sale_count', required: true, includeIfNull: false)
  final int postedSaleCount;

  @JsonKey(name: r'line_count', required: true, includeIfNull: false)
  final int lineCount;

  @JsonKey(name: r'net_sales_minor', required: true, includeIfNull: false)
  final int netSalesMinor;

  @JsonKey(name: r'cogs_minor', required: true, includeIfNull: false)
  final int cogsMinor;

  @JsonKey(name: r'gross_profit_minor', required: true, includeIfNull: true)
  final int? grossProfitMinor;

  @JsonKey(
    name: r'missing_cost_line_count',
    required: true,
    includeIfNull: false,
  )
  final int missingCostLineCount;

  @JsonKey(name: r'costing_complete', required: true, includeIfNull: false)
  final bool costingComplete;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesMetrics &&
          other.postedSaleCount == postedSaleCount &&
          other.lineCount == lineCount &&
          other.netSalesMinor == netSalesMinor &&
          other.cogsMinor == cogsMinor &&
          other.grossProfitMinor == grossProfitMinor &&
          other.missingCostLineCount == missingCostLineCount &&
          other.costingComplete == costingComplete;

  @override
  int get hashCode =>
      postedSaleCount.hashCode +
      lineCount.hashCode +
      netSalesMinor.hashCode +
      cogsMinor.hashCode +
      (grossProfitMinor == null ? 0 : grossProfitMinor.hashCode) +
      missingCostLineCount.hashCode +
      costingComplete.hashCode;

  factory SalesMetrics.fromJson(Map<String, dynamic> json) =>
      _$SalesMetricsFromJson(json);

  Map<String, dynamic> toJson() => _$SalesMetricsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
