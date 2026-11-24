// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_line.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TransferLineCWProxy {
  TransferLine id(String id);

  TransferLine product(String product);

  TransferLine pack(String pack);

  TransferLine quantity(double quantity);

  TransferLine conversionFactor(double conversionFactor);

  TransferLine baseQuantity(double baseQuantity);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TransferLine(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TransferLine(...).copyWith(id: 12, name: "My name")
  /// ````
  TransferLine call({
    String id,
    String product,
    String pack,
    double quantity,
    double conversionFactor,
    double baseQuantity,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTransferLine.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTransferLine.copyWith.fieldName(...)`
class _$TransferLineCWProxyImpl implements _$TransferLineCWProxy {
  const _$TransferLineCWProxyImpl(this._value);

  final TransferLine _value;

  @override
  TransferLine id(String id) => this(id: id);

  @override
  TransferLine product(String product) => this(product: product);

  @override
  TransferLine pack(String pack) => this(pack: pack);

  @override
  TransferLine quantity(double quantity) => this(quantity: quantity);

  @override
  TransferLine conversionFactor(double conversionFactor) =>
      this(conversionFactor: conversionFactor);

  @override
  TransferLine baseQuantity(double baseQuantity) =>
      this(baseQuantity: baseQuantity);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TransferLine(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TransferLine(...).copyWith(id: 12, name: "My name")
  /// ````
  TransferLine call({
    Object? id = const $CopyWithPlaceholder(),
    Object? product = const $CopyWithPlaceholder(),
    Object? pack = const $CopyWithPlaceholder(),
    Object? quantity = const $CopyWithPlaceholder(),
    Object? conversionFactor = const $CopyWithPlaceholder(),
    Object? baseQuantity = const $CopyWithPlaceholder(),
  }) {
    return TransferLine(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      product: product == const $CopyWithPlaceholder()
          ? _value.product
          // ignore: cast_nullable_to_non_nullable
          : product as String,
      pack: pack == const $CopyWithPlaceholder()
          ? _value.pack
          // ignore: cast_nullable_to_non_nullable
          : pack as String,
      quantity: quantity == const $CopyWithPlaceholder()
          ? _value.quantity
          // ignore: cast_nullable_to_non_nullable
          : quantity as double,
      conversionFactor: conversionFactor == const $CopyWithPlaceholder()
          ? _value.conversionFactor
          // ignore: cast_nullable_to_non_nullable
          : conversionFactor as double,
      baseQuantity: baseQuantity == const $CopyWithPlaceholder()
          ? _value.baseQuantity
          // ignore: cast_nullable_to_non_nullable
          : baseQuantity as double,
    );
  }
}

extension $TransferLineCopyWith on TransferLine {
  /// Returns a callable class that can be used as follows: `instanceOfTransferLine.copyWith(...)` or like so:`instanceOfTransferLine.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TransferLineCWProxy get copyWith => _$TransferLineCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferLine _$TransferLineFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TransferLine',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'product',
            'pack',
            'quantity',
            'conversion_factor',
            'base_quantity',
          ],
        );
        final val = TransferLine(
          id: $checkedConvert('id', (v) => v as String),
          product: $checkedConvert('product', (v) => v as String),
          pack: $checkedConvert('pack', (v) => v as String),
          quantity: $checkedConvert('quantity', (v) => (v as num).toDouble()),
          conversionFactor: $checkedConvert(
            'conversion_factor',
            (v) => (v as num).toDouble(),
          ),
          baseQuantity: $checkedConvert(
            'base_quantity',
            (v) => (v as num).toDouble(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'conversionFactor': 'conversion_factor',
        'baseQuantity': 'base_quantity',
      },
    );

Map<String, dynamic> _$TransferLineToJson(TransferLine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'pack': instance.pack,
      'quantity': instance.quantity,
      'conversion_factor': instance.conversionFactor,
      'base_quantity': instance.baseQuantity,
    };
