//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'valuation_row.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ValuationRow {
  /// Returns a new [ValuationRow] instance.
  ValuationRow({
    required this.productId,

    required this.name,

    required this.unit,

    required this.quantity,

    required this.averageCostMinor,

    required this.totalValueMinor,

    required this.knownValueMinor,

    required this.unknownCostQuantity,

    required this.costingComplete,
  });

  @JsonKey(name: r'product_id', required: true, includeIfNull: false)
  final String productId;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'unit', required: true, includeIfNull: false)
  final String unit;

  @JsonKey(name: r'quantity', required: true, includeIfNull: false)
  final double quantity;

  @JsonKey(name: r'average_cost_minor', required: true, includeIfNull: true)
  final int? averageCostMinor;

  @JsonKey(name: r'total_value_minor', required: true, includeIfNull: true)
  final int? totalValueMinor;

  @JsonKey(name: r'known_value_minor', required: true, includeIfNull: false)
  final int knownValueMinor;

  @JsonKey(name: r'unknown_cost_quantity', required: true, includeIfNull: false)
  final double unknownCostQuantity;

  @JsonKey(name: r'costing_complete', required: true, includeIfNull: false)
  final bool costingComplete;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValuationRow &&
          other.productId == productId &&
          other.name == name &&
          other.unit == unit &&
          other.quantity == quantity &&
          other.averageCostMinor == averageCostMinor &&
          other.totalValueMinor == totalValueMinor &&
          other.knownValueMinor == knownValueMinor &&
          other.unknownCostQuantity == unknownCostQuantity &&
          other.costingComplete == costingComplete;

  @override
  int get hashCode =>
      productId.hashCode +
      name.hashCode +
      unit.hashCode +
      quantity.hashCode +
      (averageCostMinor == null ? 0 : averageCostMinor.hashCode) +
      (totalValueMinor == null ? 0 : totalValueMinor.hashCode) +
      knownValueMinor.hashCode +
      unknownCostQuantity.hashCode +
      costingComplete.hashCode;

  factory ValuationRow.fromJson(Map<String, dynamic> json) =>
      _$ValuationRowFromJson(json);

  Map<String, dynamic> toJson() => _$ValuationRowToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
