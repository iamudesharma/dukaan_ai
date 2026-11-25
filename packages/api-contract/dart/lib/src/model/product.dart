//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/product_pack.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Product {
  /// Returns a new [Product] instance.
  Product({
    required this.id,

    required this.business,

    required this.name,

    this.sku,

    this.baseUnit,

    this.trackInventory,

    this.hsnSac,

    this.taxRateBps,

    this.lowStockThreshold,

    this.isActive,

    required this.defaultPackId,

    required this.stockQuantity,

    required this.isLowStock,

    required this.packs,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'sku', required: false, includeIfNull: false)
  final String? sku;

  /// * `PIECE` - Piece * `KILOGRAM` - Kilogram * `LITRE` - Litre * `METRE` - Metre * `SERVICE` - Service
  @JsonKey(name: r'base_unit', required: false, includeIfNull: false)
  final ProductBaseUnitEnum? baseUnit;

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

  @JsonKey(name: r'default_pack_id', required: true, includeIfNull: true)
  final String? defaultPackId;

  @JsonKey(name: r'stock_quantity', required: true, includeIfNull: false)
  final String stockQuantity;

  @JsonKey(name: r'is_low_stock', required: true, includeIfNull: false)
  final bool isLowStock;

  @JsonKey(name: r'packs', required: true, includeIfNull: false)
  final List<ProductPack> packs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
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
          other.defaultPackId == defaultPackId &&
          other.stockQuantity == stockQuantity &&
          other.isLowStock == isLowStock &&
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
      (defaultPackId == null ? 0 : defaultPackId.hashCode) +
      stockQuantity.hashCode +
      isLowStock.hashCode +
      packs.hashCode;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `PIECE` - Piece * `KILOGRAM` - Kilogram * `LITRE` - Litre * `METRE` - Metre * `SERVICE` - Service
enum ProductBaseUnitEnum {
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

  const ProductBaseUnitEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
