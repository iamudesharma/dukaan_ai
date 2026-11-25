// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProductCWProxy {
  Product id(String id);

  Product business(String business);

  Product name(String name);

  Product sku(String? sku);

  Product baseUnit(ProductBaseUnitEnum? baseUnit);

  Product trackInventory(bool? trackInventory);

  Product hsnSac(String? hsnSac);

  Product taxRateBps(int? taxRateBps);

  Product lowStockThreshold(double? lowStockThreshold);

  Product isActive(bool? isActive);

  Product defaultPackId(String? defaultPackId);

  Product stockQuantity(String stockQuantity);

  Product isLowStock(bool isLowStock);

  Product packs(List<ProductPack> packs);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Product(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Product(...).copyWith(id: 12, name: "My name")
  /// ````
  Product call({
    String id,
    String business,
    String name,
    String? sku,
    ProductBaseUnitEnum? baseUnit,
    bool? trackInventory,
    String? hsnSac,
    int? taxRateBps,
    double? lowStockThreshold,
    bool? isActive,
    String? defaultPackId,
    String stockQuantity,
    bool isLowStock,
    List<ProductPack> packs,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProduct.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProduct.copyWith.fieldName(...)`
class _$ProductCWProxyImpl implements _$ProductCWProxy {
  const _$ProductCWProxyImpl(this._value);

  final Product _value;

  @override
  Product id(String id) => this(id: id);

  @override
  Product business(String business) => this(business: business);

  @override
  Product name(String name) => this(name: name);

  @override
  Product sku(String? sku) => this(sku: sku);

  @override
  Product baseUnit(ProductBaseUnitEnum? baseUnit) => this(baseUnit: baseUnit);

  @override
  Product trackInventory(bool? trackInventory) =>
      this(trackInventory: trackInventory);

  @override
  Product hsnSac(String? hsnSac) => this(hsnSac: hsnSac);

  @override
  Product taxRateBps(int? taxRateBps) => this(taxRateBps: taxRateBps);

  @override
  Product lowStockThreshold(double? lowStockThreshold) =>
      this(lowStockThreshold: lowStockThreshold);

  @override
  Product isActive(bool? isActive) => this(isActive: isActive);

  @override
  Product defaultPackId(String? defaultPackId) =>
      this(defaultPackId: defaultPackId);

  @override
  Product stockQuantity(String stockQuantity) =>
      this(stockQuantity: stockQuantity);

  @override
  Product isLowStock(bool isLowStock) => this(isLowStock: isLowStock);

  @override
  Product packs(List<ProductPack> packs) => this(packs: packs);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Product(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Product(...).copyWith(id: 12, name: "My name")
  /// ````
  Product call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? sku = const $CopyWithPlaceholder(),
    Object? baseUnit = const $CopyWithPlaceholder(),
    Object? trackInventory = const $CopyWithPlaceholder(),
    Object? hsnSac = const $CopyWithPlaceholder(),
    Object? taxRateBps = const $CopyWithPlaceholder(),
    Object? lowStockThreshold = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
    Object? defaultPackId = const $CopyWithPlaceholder(),
    Object? stockQuantity = const $CopyWithPlaceholder(),
    Object? isLowStock = const $CopyWithPlaceholder(),
    Object? packs = const $CopyWithPlaceholder(),
  }) {
    return Product(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      sku: sku == const $CopyWithPlaceholder()
          ? _value.sku
          // ignore: cast_nullable_to_non_nullable
          : sku as String?,
      baseUnit: baseUnit == const $CopyWithPlaceholder()
          ? _value.baseUnit
          // ignore: cast_nullable_to_non_nullable
          : baseUnit as ProductBaseUnitEnum?,
      trackInventory: trackInventory == const $CopyWithPlaceholder()
          ? _value.trackInventory
          // ignore: cast_nullable_to_non_nullable
          : trackInventory as bool?,
      hsnSac: hsnSac == const $CopyWithPlaceholder()
          ? _value.hsnSac
          // ignore: cast_nullable_to_non_nullable
          : hsnSac as String?,
      taxRateBps: taxRateBps == const $CopyWithPlaceholder()
          ? _value.taxRateBps
          // ignore: cast_nullable_to_non_nullable
          : taxRateBps as int?,
      lowStockThreshold: lowStockThreshold == const $CopyWithPlaceholder()
          ? _value.lowStockThreshold
          // ignore: cast_nullable_to_non_nullable
          : lowStockThreshold as double?,
      isActive: isActive == const $CopyWithPlaceholder()
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool?,
      defaultPackId: defaultPackId == const $CopyWithPlaceholder()
          ? _value.defaultPackId
          // ignore: cast_nullable_to_non_nullable
          : defaultPackId as String?,
      stockQuantity: stockQuantity == const $CopyWithPlaceholder()
          ? _value.stockQuantity
          // ignore: cast_nullable_to_non_nullable
          : stockQuantity as String,
      isLowStock: isLowStock == const $CopyWithPlaceholder()
          ? _value.isLowStock
          // ignore: cast_nullable_to_non_nullable
          : isLowStock as bool,
      packs: packs == const $CopyWithPlaceholder()
          ? _value.packs
          // ignore: cast_nullable_to_non_nullable
          : packs as List<ProductPack>,
    );
  }
}

extension $ProductCopyWith on Product {
  /// Returns a callable class that can be used as follows: `instanceOfProduct.copyWith(...)` or like so:`instanceOfProduct.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProductCWProxy get copyWith => _$ProductCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Product',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'business',
        'name',
        'default_pack_id',
        'stock_quantity',
        'is_low_stock',
        'packs',
      ],
    );
    final val = Product(
      id: $checkedConvert('id', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      sku: $checkedConvert('sku', (v) => v as String?),
      baseUnit: $checkedConvert(
        'base_unit',
        (v) => $enumDecodeNullable(_$ProductBaseUnitEnumEnumMap, v),
      ),
      trackInventory: $checkedConvert('track_inventory', (v) => v as bool?),
      hsnSac: $checkedConvert('hsn_sac', (v) => v as String?),
      taxRateBps: $checkedConvert('tax_rate_bps', (v) => (v as num?)?.toInt()),
      lowStockThreshold: $checkedConvert(
        'low_stock_threshold',
        (v) => (v as num?)?.toDouble(),
      ),
      isActive: $checkedConvert('is_active', (v) => v as bool?),
      defaultPackId: $checkedConvert('default_pack_id', (v) => v as String?),
      stockQuantity: $checkedConvert('stock_quantity', (v) => v as String),
      isLowStock: $checkedConvert('is_low_stock', (v) => v as bool),
      packs: $checkedConvert(
        'packs',
        (v) => (v as List<dynamic>)
            .map((e) => ProductPack.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'baseUnit': 'base_unit',
    'trackInventory': 'track_inventory',
    'hsnSac': 'hsn_sac',
    'taxRateBps': 'tax_rate_bps',
    'lowStockThreshold': 'low_stock_threshold',
    'isActive': 'is_active',
    'defaultPackId': 'default_pack_id',
    'stockQuantity': 'stock_quantity',
    'isLowStock': 'is_low_stock',
  },
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'business': instance.business,
  'name': instance.name,
  'sku': ?instance.sku,
  'base_unit': ?_$ProductBaseUnitEnumEnumMap[instance.baseUnit],
  'track_inventory': ?instance.trackInventory,
  'hsn_sac': ?instance.hsnSac,
  'tax_rate_bps': ?instance.taxRateBps,
  'low_stock_threshold': ?instance.lowStockThreshold,
  'is_active': ?instance.isActive,
  'default_pack_id': instance.defaultPackId,
  'stock_quantity': instance.stockQuantity,
  'is_low_stock': instance.isLowStock,
  'packs': instance.packs.map((e) => e.toJson()).toList(),
};

const _$ProductBaseUnitEnumEnumMap = {
  ProductBaseUnitEnum.PIECE: 'PIECE',
  ProductBaseUnitEnum.KILOGRAM: 'KILOGRAM',
  ProductBaseUnitEnum.LITRE: 'LITRE',
  ProductBaseUnitEnum.METRE: 'METRE',
  ProductBaseUnitEnum.SERVICE: 'SERVICE',
};
