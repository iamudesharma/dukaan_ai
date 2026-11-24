//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sale_line_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaleLineInput {
  /// Returns a new [SaleLineInput] instance.
  SaleLineInput({
    required this.packId,

    required this.quantity,

    this.unitPriceMinor,

    this.discountMinor = 0,
  });

  @JsonKey(name: r'pack_id', required: true, includeIfNull: false)
  final String packId;

  @JsonKey(name: r'quantity', required: true, includeIfNull: false)
  final double quantity;

  // minimum: 0
  @JsonKey(name: r'unit_price_minor', required: false, includeIfNull: false)
  final int? unitPriceMinor;

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
      other is SaleLineInput &&
          other.packId == packId &&
          other.quantity == quantity &&
          other.unitPriceMinor == unitPriceMinor &&
          other.discountMinor == discountMinor;

  @override
  int get hashCode =>
      packId.hashCode +
      quantity.hashCode +
      unitPriceMinor.hashCode +
      discountMinor.hashCode;

  factory SaleLineInput.fromJson(Map<String, dynamic> json) =>
      _$SaleLineInputFromJson(json);

  Map<String, dynamic> toJson() => _$SaleLineInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
