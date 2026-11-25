//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'purchase_line_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PurchaseLineInput {
  /// Returns a new [PurchaseLineInput] instance.
  PurchaseLineInput({
    required this.packId,

    required this.quantity,

    required this.unitCostMinor,

    this.discountMinor = 0,
  });

  @JsonKey(name: r'pack_id', required: true, includeIfNull: false)
  final String packId;

  @JsonKey(name: r'quantity', required: true, includeIfNull: false)
  final double quantity;

  // minimum: 0
  @JsonKey(name: r'unit_cost_minor', required: true, includeIfNull: false)
  final int unitCostMinor;

  // minimum: 0
  @JsonKey(
    defaultValue: 0,
    name: r'discount_minor',
    required: false,
    includeIfNull: false,
  )
  final int? discountMinor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseLineInput &&
          other.packId == packId &&
          other.quantity == quantity &&
          other.unitCostMinor == unitCostMinor &&
          other.discountMinor == discountMinor;

  @override
  int get hashCode =>
      packId.hashCode +
      quantity.hashCode +
      unitCostMinor.hashCode +
      discountMinor.hashCode;

  factory PurchaseLineInput.fromJson(Map<String, dynamic> json) =>
      _$PurchaseLineInputFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseLineInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
