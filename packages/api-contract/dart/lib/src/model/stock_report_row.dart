//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stock_report_row.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StockReportRow {
  /// Returns a new [StockReportRow] instance.
  StockReportRow({
    required this.productId,

    required this.name,

    required this.unit,

    required this.quantity,

    required this.lowStockThreshold,

    required this.isLowStock,
  });

  @JsonKey(name: r'product_id', required: true, includeIfNull: false)
  final String productId;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'unit', required: true, includeIfNull: false)
  final String unit;

  @JsonKey(name: r'quantity', required: true, includeIfNull: false)
  final double quantity;

  @JsonKey(name: r'low_stock_threshold', required: true, includeIfNull: false)
  final double lowStockThreshold;

  @JsonKey(name: r'is_low_stock', required: true, includeIfNull: false)
  final bool isLowStock;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockReportRow &&
          other.productId == productId &&
          other.name == name &&
          other.unit == unit &&
          other.quantity == quantity &&
          other.lowStockThreshold == lowStockThreshold &&
          other.isLowStock == isLowStock;

  @override
  int get hashCode =>
      productId.hashCode +
      name.hashCode +
      unit.hashCode +
      quantity.hashCode +
      lowStockThreshold.hashCode +
      isLowStock.hashCode;

  factory StockReportRow.fromJson(Map<String, dynamic> json) =>
      _$StockReportRowFromJson(json);

  Map<String, dynamic> toJson() => _$StockReportRowToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
