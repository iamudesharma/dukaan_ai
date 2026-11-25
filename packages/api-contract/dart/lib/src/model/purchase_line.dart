//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'purchase_line.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PurchaseLine {
  /// Returns a new [PurchaseLine] instance.
  PurchaseLine({
    required this.id,

    required this.product,

    required this.pack,

    required this.description,

    this.hsnSac,

    required this.quantity,

    required this.conversionFactor,

    required this.baseQuantity,

    required this.unitCostMinor,

    this.discountMinor,

    required this.taxableValueMinor,

    this.taxRateBps,

    this.cgstAmountMinor,

    this.sgstAmountMinor,

    this.igstAmountMinor,

    required this.lineTotalMinor,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'product', required: true, includeIfNull: false)
  final String product;

  @JsonKey(name: r'pack', required: true, includeIfNull: false)
  final String pack;

  @JsonKey(name: r'description', required: true, includeIfNull: false)
  final String description;

  @JsonKey(name: r'hsn_sac', required: false, includeIfNull: false)
  final String? hsnSac;

  @JsonKey(name: r'quantity', required: true, includeIfNull: false)
  final double quantity;

  @JsonKey(name: r'conversion_factor', required: true, includeIfNull: false)
  final double conversionFactor;

  @JsonKey(name: r'base_quantity', required: true, includeIfNull: false)
  final double baseQuantity;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'unit_cost_minor', required: true, includeIfNull: false)
  final int unitCostMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'discount_minor', required: false, includeIfNull: false)
  final int? discountMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'taxable_value_minor', required: true, includeIfNull: false)
  final int taxableValueMinor;

  // minimum: 0
  // maximum: 10000
  @JsonKey(name: r'tax_rate_bps', required: false, includeIfNull: false)
  final int? taxRateBps;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'cgst_amount_minor', required: false, includeIfNull: false)
  final int? cgstAmountMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'sgst_amount_minor', required: false, includeIfNull: false)
  final int? sgstAmountMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'igst_amount_minor', required: false, includeIfNull: false)
  final int? igstAmountMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'line_total_minor', required: true, includeIfNull: false)
  final int lineTotalMinor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseLine &&
          other.id == id &&
          other.product == product &&
          other.pack == pack &&
          other.description == description &&
          other.hsnSac == hsnSac &&
          other.quantity == quantity &&
          other.conversionFactor == conversionFactor &&
          other.baseQuantity == baseQuantity &&
          other.unitCostMinor == unitCostMinor &&
          other.discountMinor == discountMinor &&
          other.taxableValueMinor == taxableValueMinor &&
          other.taxRateBps == taxRateBps &&
          other.cgstAmountMinor == cgstAmountMinor &&
          other.sgstAmountMinor == sgstAmountMinor &&
          other.igstAmountMinor == igstAmountMinor &&
          other.lineTotalMinor == lineTotalMinor;

  @override
  int get hashCode =>
      id.hashCode +
      product.hashCode +
      pack.hashCode +
      description.hashCode +
      hsnSac.hashCode +
      quantity.hashCode +
      conversionFactor.hashCode +
      baseQuantity.hashCode +
      unitCostMinor.hashCode +
      discountMinor.hashCode +
      taxableValueMinor.hashCode +
      taxRateBps.hashCode +
      cgstAmountMinor.hashCode +
      sgstAmountMinor.hashCode +
      igstAmountMinor.hashCode +
      lineTotalMinor.hashCode;

  factory PurchaseLine.fromJson(Map<String, dynamic> json) =>
      _$PurchaseLineFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseLineToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
