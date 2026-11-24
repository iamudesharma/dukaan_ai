// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_line_input.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PurchaseLineInputCWProxy {
  PurchaseLineInput packId(String packId);

  PurchaseLineInput quantity(double quantity);

  PurchaseLineInput unitCostMinor(int unitCostMinor);

  PurchaseLineInput discountMinor(int? discountMinor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PurchaseLineInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PurchaseLineInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PurchaseLineInput call({
    String packId,
    double quantity,
    int unitCostMinor,
    int? discountMinor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPurchaseLineInput.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPurchaseLineInput.copyWith.fieldName(...)`
class _$PurchaseLineInputCWProxyImpl implements _$PurchaseLineInputCWProxy {
  const _$PurchaseLineInputCWProxyImpl(this._value);

  final PurchaseLineInput _value;

  @override
  PurchaseLineInput packId(String packId) => this(packId: packId);

  @override
  PurchaseLineInput quantity(double quantity) => this(quantity: quantity);

  @override
  PurchaseLineInput unitCostMinor(int unitCostMinor) =>
      this(unitCostMinor: unitCostMinor);

  @override
  PurchaseLineInput discountMinor(int? discountMinor) =>
      this(discountMinor: discountMinor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PurchaseLineInput(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PurchaseLineInput(...).copyWith(id: 12, name: "My name")
  /// ````
  PurchaseLineInput call({
    Object? packId = const $CopyWithPlaceholder(),
    Object? quantity = const $CopyWithPlaceholder(),
    Object? unitCostMinor = const $CopyWithPlaceholder(),
    Object? discountMinor = const $CopyWithPlaceholder(),
  }) {
    return PurchaseLineInput(
      packId: packId == const $CopyWithPlaceholder()
          ? _value.packId
          // ignore: cast_nullable_to_non_nullable
          : packId as String,
      quantity: quantity == const $CopyWithPlaceholder()
          ? _value.quantity
          // ignore: cast_nullable_to_non_nullable
          : quantity as double,
      unitCostMinor: unitCostMinor == const $CopyWithPlaceholder()
          ? _value.unitCostMinor
          // ignore: cast_nullable_to_non_nullable
          : unitCostMinor as int,
      discountMinor: discountMinor == const $CopyWithPlaceholder()
          ? _value.discountMinor
          // ignore: cast_nullable_to_non_nullable
          : discountMinor as int?,
    );
  }
}

extension $PurchaseLineInputCopyWith on PurchaseLineInput {
  /// Returns a callable class that can be used as follows: `instanceOfPurchaseLineInput.copyWith(...)` or like so:`instanceOfPurchaseLineInput.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PurchaseLineInputCWProxy get copyWith =>
      _$PurchaseLineInputCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseLineInput _$PurchaseLineInputFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PurchaseLineInput',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['pack_id', 'quantity', 'unit_cost_minor'],
        );
        final val = PurchaseLineInput(
          packId: $checkedConvert('pack_id', (v) => v as String),
          quantity: $checkedConvert('quantity', (v) => (v as num).toDouble()),
          unitCostMinor: $checkedConvert(
            'unit_cost_minor',
            (v) => (v as num).toInt(),
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
        'unitCostMinor': 'unit_cost_minor',
        'discountMinor': 'discount_minor',
      },
    );

Map<String, dynamic> _$PurchaseLineInputToJson(PurchaseLineInput instance) =>
    <String, dynamic>{
      'pack_id': instance.packId,
      'quantity': instance.quantity,
      'unit_cost_minor': instance.unitCostMinor,
      'discount_minor': ?instance.discountMinor,
    };
