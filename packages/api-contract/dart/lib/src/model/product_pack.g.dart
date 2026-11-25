// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_pack.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ProductPackCWProxy {
  ProductPack id(String id);

  ProductPack name(String name);

  ProductPack conversionFactor(double conversionFactor);

  ProductPack retailPriceMinor(int retailPriceMinor);

  ProductPack wholesalePriceMinor(int wholesalePriceMinor);

  ProductPack isActive(bool? isActive);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProductPack(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProductPack(...).copyWith(id: 12, name: "My name")
  /// ````
  ProductPack call({
    String id,
    String name,
    double conversionFactor,
    int retailPriceMinor,
    int wholesalePriceMinor,
    bool? isActive,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfProductPack.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfProductPack.copyWith.fieldName(...)`
class _$ProductPackCWProxyImpl implements _$ProductPackCWProxy {
  const _$ProductPackCWProxyImpl(this._value);

  final ProductPack _value;

  @override
  ProductPack id(String id) => this(id: id);

  @override
  ProductPack name(String name) => this(name: name);

  @override
  ProductPack conversionFactor(double conversionFactor) =>
      this(conversionFactor: conversionFactor);

  @override
  ProductPack retailPriceMinor(int retailPriceMinor) =>
      this(retailPriceMinor: retailPriceMinor);

  @override
  ProductPack wholesalePriceMinor(int wholesalePriceMinor) =>
      this(wholesalePriceMinor: wholesalePriceMinor);

  @override
  ProductPack isActive(bool? isActive) => this(isActive: isActive);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ProductPack(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ProductPack(...).copyWith(id: 12, name: "My name")
  /// ````
  ProductPack call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? conversionFactor = const $CopyWithPlaceholder(),
    Object? retailPriceMinor = const $CopyWithPlaceholder(),
    Object? wholesalePriceMinor = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
  }) {
    return ProductPack(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      conversionFactor: conversionFactor == const $CopyWithPlaceholder()
          ? _value.conversionFactor
          // ignore: cast_nullable_to_non_nullable
          : conversionFactor as double,
      retailPriceMinor: retailPriceMinor == const $CopyWithPlaceholder()
          ? _value.retailPriceMinor
          // ignore: cast_nullable_to_non_nullable
          : retailPriceMinor as int,
      wholesalePriceMinor: wholesalePriceMinor == const $CopyWithPlaceholder()
          ? _value.wholesalePriceMinor
          // ignore: cast_nullable_to_non_nullable
          : wholesalePriceMinor as int,
      isActive: isActive == const $CopyWithPlaceholder()
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool?,
    );
  }
}

extension $ProductPackCopyWith on ProductPack {
  /// Returns a callable class that can be used as follows: `instanceOfProductPack.copyWith(...)` or like so:`instanceOfProductPack.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ProductPackCWProxy get copyWith => _$ProductPackCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductPack _$ProductPackFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ProductPack',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'name',
        'conversion_factor',
        'retail_price_minor',
        'wholesale_price_minor',
      ],
    );
    final val = ProductPack(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      conversionFactor: $checkedConvert(
        'conversion_factor',
        (v) => (v as num).toDouble(),
      ),
      retailPriceMinor: $checkedConvert(
        'retail_price_minor',
        (v) => (v as num).toInt(),
      ),
      wholesalePriceMinor: $checkedConvert(
        'wholesale_price_minor',
        (v) => (v as num).toInt(),
      ),
      isActive: $checkedConvert('is_active', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'conversionFactor': 'conversion_factor',
    'retailPriceMinor': 'retail_price_minor',
    'wholesalePriceMinor': 'wholesale_price_minor',
    'isActive': 'is_active',
  },
);

Map<String, dynamic> _$ProductPackToJson(ProductPack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'conversion_factor': instance.conversionFactor,
      'retail_price_minor': instance.retailPriceMinor,
      'wholesale_price_minor': instance.wholesalePriceMinor,
      'is_active': ?instance.isActive,
    };
