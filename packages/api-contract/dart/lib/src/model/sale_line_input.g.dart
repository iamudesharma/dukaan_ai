// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_line_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaleLineInputCWProxy {
  SaleLineInput packId(String packId);

  SaleLineInput quantity(double quantity);

  SaleLineInput unitPriceMinor(int? unitPriceMinor);

  SaleLineInput discountMinor(int? discountMinor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaleLineInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaleLineInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SaleLineInput call({
    String packId,
    double quantity,
    int? unitPriceMinor,
    int? discountMinor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSaleLineInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSaleLineInput.copyWith.fieldName(...)`
class _$SaleLineInputCWProxyImpl implements _$SaleLineInputCWProxy {
  const _$SaleLineInputCWProxyImpl(this._value);

  final SaleLineInput _value;

  @override
  SaleLineInput packId(String packId) => this(packId: packId);

  @override
  SaleLineInput quantity(double quantity) => this(quantity: quantity);

  @override
  SaleLineInput unitPriceMinor(int? unitPriceMinor) =>
      this(unitPriceMinor: unitPriceMinor);

  @override
  SaleLineInput discountMinor(int? discountMinor) =>
      this(discountMinor: discountMinor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaleLineInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaleLineInput(...).copyWith(id: 12, name: "My name")
  /// ````
  SaleLineInput call({
    Object? packId = const $CopyWithPlaceholder(),
    Object? quantity = const $CopyWithPlaceholder(),
    Object? unitPriceMinor = const $CopyWithPlaceholder(),
    Object? discountMinor = const $CopyWithPlaceholder(),
  }) {
    return SaleLineInput(
      packId: packId == const $CopyWithPlaceholder()
          ? _value.packId
          // ignore: cast_nullable_to_non_nullable
          : packId as String,
      quantity: quantity == const $CopyWithPlaceholder()
          ? _value.quantity
          // ignore: cast_nullable_to_non_nullable
          : quantity as double,
      unitPriceMinor: unitPriceMinor == const $CopyWithPlaceholder()
          ? _value.unitPriceMinor
          // ignore: cast_nullable_to_non_nullable
          : unitPriceMinor as int?,
      discountMinor: discountMinor == const $CopyWithPlaceholder()
          ? _value.discountMinor
          // ignore: cast_nullable_to_non_nullable
          : discountMinor as int?,
    );
  }
}

extension $SaleLineInputCopyWith on SaleLineInput {
  /// Returns a callable class that can be used as follows: `instanceOfSaleLineInput.copyWith(...)` or like so:`instanceOfSaleLineInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaleLineInputCWProxy get copyWith => _$SaleLineInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleLineInput _$SaleLineInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SaleLineInput',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['pack_id', 'quantity']);
        final val = SaleLineInput(
          packId: $checkedConvert('pack_id', (v) => v as String),
          quantity: $checkedConvert('quantity', (v) => (v as num).toDouble()),
          unitPriceMinor: $checkedConvert(
            'unit_price_minor',
            (v) => (v as num?)?.toInt(),
          ),
          discountMinor: $checkedConvert(
            'discount_minor',
            (v) => (v as num?)?.toInt() ?? 0,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'packId': 'pack_id',
        'unitPriceMinor': 'unit_price_minor',
        'discountMinor': 'discount_minor',
      },
    );

Map<String, dynamic> _$SaleLineInputToJson(SaleLineInput instance) =>
    <String, dynamic>{
      'pack_id': instance.packId,
      'quantity': instance.quantity,
      'unit_price_minor': ?instance.unitPriceMinor,
      'discount_minor': ?instance.discountMinor,
    };
