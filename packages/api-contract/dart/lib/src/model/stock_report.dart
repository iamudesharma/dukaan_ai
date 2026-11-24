//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/stock_report_row.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stock_report.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StockReport {
  /// Returns a new [StockReport] instance.
  StockReport({required this.results});

  @JsonKey(name: r'results', required: true, includeIfNull: false)
  final List<StockReportRow> results;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockReport && other.results == results;

  @override
  int get hashCode => results.hashCode;

  factory StockReport.fromJson(Map<String, dynamic> json) =>
      _$StockReportFromJson(json);

  Map<String, dynamic> toJson() => _$StockReportToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
