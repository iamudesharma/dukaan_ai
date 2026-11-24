//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/product_pack.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'patched_product.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PatchedProduct {
  /// Returns a new [PatchedProduct] instance.
  PatchedProduct({
    this.id,

    this.business,

    this.name,

    this.sku,

    this.baseUnit,

    this.trackInventory,

    this.hsnSac,

    this.taxRateBps,

    this.lowStockThreshold,

    this.isActive,

    this.stockQuantity,

    this.packs,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'business', required: false, includeIfNull: false)
  final String? business;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'sku', required: false, includeIfNull: false)
  final String? sku;

  /// * `PIECE` - Piece * `KILOGRAM` - Kilogram * `LITRE` - Litre * `METRE` - Metre * `SERVICE` - Service
  @JsonKey(name: r'base_unit', required: false, includeIfNull: false)
  final PatchedProductBaseUnitEnum? baseUnit;

  @JsonKey(name: r'track_inventory', required: false, includeIfNull: false)
  final bool? trackInventory;

  @JsonKey(name: r'hsn_sac', required: false, includeIfNull: false)
  final String? hsnSac;

  // minimum: 0
  // maximum: 10000
  @JsonKey(name: r'tax_rate_bps', required: false, includeIfNull: false)
  final int? taxRateBps;

  @JsonKey(name: r'low_stock_threshold', required: false, includeIfNull: false)
  final double? lowStockThreshold;

  @JsonKey(name: r'is_active', required: false, includeIfNull: false)
  final bool? isActive;

  @JsonKey(name: r'stock_quantity', required: false, includeIfNull: false)
  final double? stockQuantity;

  @JsonKey(name: r'packs', required: false, includeIfNull: false)
  final List<ProductPack>? packs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatchedProduct &&
          other.id == id &&
          other.business == business &&
          other.name == name &&
          other.sku == sku &&
          other.baseUnit == baseUnit &&
          other.trackInventory == trackInventory &&
          other.hsnSac == hsnSac &&
          other.taxRateBps == taxRateBps &&
          other.lowStockThreshold == lowStockThreshold &&
          other.isActive == isActive &&
          other.stockQuantity == stockQuantity &&
          other.packs == packs;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      name.hashCode +
      sku.hashCode +
      baseUnit.hashCode +
      trackInventory.hashCode +
      hsnSac.hashCode +
      taxRateBps.hashCode +
      lowStockThreshold.hashCode +
      isActive.hashCode +
      stockQuantity.hashCode +
      packs.hashCode;

  factory PatchedProduct.fromJson(Map<String, dynamic> json) =>
      _$PatchedProductFromJson(json);

  Map<String, dynamic> toJson() => _$PatchedProductToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `PIECE` - Piece * `KILOGRAM` - Kilogram * `LITRE` - Litre * `METRE` - Metre * `SERVICE` - Service
enum PatchedProductBaseUnitEnum {
  @JsonValue(r'PIECE')
  PIECE(r'PIECE'),
  @JsonValue(r'KILOGRAM')
  KILOGRAM(r'KILOGRAM'),
  @JsonValue(r'LITRE')
  LITRE(r'LITRE'),
  @JsonValue(r'METRE')
  METRE(r'METRE'),
  @JsonValue(r'SERVICE')
  SERVICE(r'SERVICE');

  const PatchedProductBaseUnitEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
