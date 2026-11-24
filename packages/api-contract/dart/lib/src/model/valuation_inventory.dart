//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'valuation_inventory.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ValuationInventory {
  /// Returns a new [ValuationInventory] instance.
  ValuationInventory({
    required this.totalQuantity,

    required this.averageCostMinor,

    required this.totalValueMinor,

    required this.knownValueMinor,

    required this.costingComplete,
  });

  @JsonKey(name: r'total_quantity', required: true, includeIfNull: false)
  final double totalQuantity;

  @JsonKey(name: r'average_cost_minor', required: true, includeIfNull: true)
  final int? averageCostMinor;

  @JsonKey(name: r'total_value_minor', required: true, includeIfNull: true)
  final int? totalValueMinor;

  @JsonKey(name: r'known_value_minor', required: true, includeIfNull: false)
  final int knownValueMinor;

  @JsonKey(name: r'costing_complete', required: true, includeIfNull: false)
  final bool costingComplete;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValuationInventory &&
          other.totalQuantity == totalQuantity &&
          other.averageCostMinor == averageCostMinor &&
          other.totalValueMinor == totalValueMinor &&
          other.knownValueMinor == knownValueMinor &&
          other.costingComplete == costingComplete;

  @override
  int get hashCode =>
      totalQuantity.hashCode +
      (averageCostMinor == null ? 0 : averageCostMinor.hashCode) +
      (totalValueMinor == null ? 0 : totalValueMinor.hashCode) +
      knownValueMinor.hashCode +
      costingComplete.hashCode;

  factory ValuationInventory.fromJson(Map<String, dynamic> json) =>
      _$ValuationInventoryFromJson(json);

  Map<String, dynamic> toJson() => _$ValuationInventoryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
