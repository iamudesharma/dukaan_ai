//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product_pack.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProductPack {
  /// Returns a new [ProductPack] instance.
  ProductPack({
    required this.id,

    required this.name,

    required this.conversionFactor,

    required this.retailPriceMinor,

    required this.wholesalePriceMinor,

    this.isActive,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'conversion_factor', required: true, includeIfNull: false)
  final double conversionFactor;

  // minimum: 0
  // maximum: 9223372036854775807
  @JsonKey(name: r'retail_price_minor', required: true, includeIfNull: false)
  final int retailPriceMinor;

  // minimum: 0
  // maximum: 9223372036854775807
  @JsonKey(name: r'wholesale_price_minor', required: true, includeIfNull: false)
  final int wholesalePriceMinor;

  @JsonKey(name: r'is_active', required: false, includeIfNull: false)
  final bool? isActive;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductPack &&
          other.id == id &&
          other.name == name &&
          other.conversionFactor == conversionFactor &&
          other.retailPriceMinor == retailPriceMinor &&
          other.wholesalePriceMinor == wholesalePriceMinor &&
          other.isActive == isActive;

  @override
  int get hashCode =>
      id.hashCode +
      name.hashCode +
      conversionFactor.hashCode +
      retailPriceMinor.hashCode +
      wholesalePriceMinor.hashCode +
      isActive.hashCode;

  factory ProductPack.fromJson(Map<String, dynamic> json) =>
      _$ProductPackFromJson(json);

  Map<String, dynamic> toJson() => _$ProductPackToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
