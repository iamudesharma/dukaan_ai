// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StockMovementCWProxy {
  StockMovement id(String id);

  StockMovement business(String business);

  StockMovement location(String location);

  StockMovement product(String product);

  StockMovement pack(String? pack);

  StockMovement movementType(StockMovementMovementTypeEnum movementType);

  StockMovement quantity(double quantity);

  StockMovement sourceType(String sourceType);

  StockMovement sourceId(String sourceId);

  StockMovement note(String? note);

  StockMovement occurredAt(DateTime occurredAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StockMovement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StockMovement(...).copyWith(id: 12, name: "My name")
  /// ````
  StockMovement call({
    String id,
    String business,
    String location,
    String product,
    String? pack,
    StockMovementMovementTypeEnum movementType,
    double quantity,
    String sourceType,
    String sourceId,
    String? note,
    DateTime occurredAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStockMovement.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStockMovement.copyWith.fieldName(...)`
class _$StockMovementCWProxyImpl implements _$StockMovementCWProxy {
  const _$StockMovementCWProxyImpl(this._value);

  final StockMovement _value;

  @override
  StockMovement id(String id) => this(id: id);

  @override
  StockMovement business(String business) => this(business: business);

  @override
  StockMovement location(String location) => this(location: location);

  @override
  StockMovement product(String product) => this(product: product);

  @override
  StockMovement pack(String? pack) => this(pack: pack);

  @override
  StockMovement movementType(StockMovementMovementTypeEnum movementType) =>
      this(movementType: movementType);

  @override
  StockMovement quantity(double quantity) => this(quantity: quantity);

  @override
  StockMovement sourceType(String sourceType) => this(sourceType: sourceType);

  @override
  StockMovement sourceId(String sourceId) => this(sourceId: sourceId);

  @override
  StockMovement note(String? note) => this(note: note);

  @override
  StockMovement occurredAt(DateTime occurredAt) => this(occurredAt: occurredAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StockMovement(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StockMovement(...).copyWith(id: 12, name: "My name")
  /// ````
  StockMovement call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? product = const $CopyWithPlaceholder(),
    Object? pack = const $CopyWithPlaceholder(),
    Object? movementType = const $CopyWithPlaceholder(),
    Object? quantity = const $CopyWithPlaceholder(),
    Object? sourceType = const $CopyWithPlaceholder(),
    Object? sourceId = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? occurredAt = const $CopyWithPlaceholder(),
  }) {
    return StockMovement(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as String,
      product: product == const $CopyWithPlaceholder()
          ? _value.product
          // ignore: cast_nullable_to_non_nullable
          : product as String,
      pack: pack == const $CopyWithPlaceholder()
          ? _value.pack
          // ignore: cast_nullable_to_non_nullable
          : pack as String?,
      movementType: movementType == const $CopyWithPlaceholder()
          ? _value.movementType
          // ignore: cast_nullable_to_non_nullable
          : movementType as StockMovementMovementTypeEnum,
      quantity: quantity == const $CopyWithPlaceholder()
          ? _value.quantity
          // ignore: cast_nullable_to_non_nullable
          : quantity as double,
      sourceType: sourceType == const $CopyWithPlaceholder()
          ? _value.sourceType
          // ignore: cast_nullable_to_non_nullable
          : sourceType as String,
      sourceId: sourceId == const $CopyWithPlaceholder()
          ? _value.sourceId
          // ignore: cast_nullable_to_non_nullable
          : sourceId as String,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      occurredAt: occurredAt == const $CopyWithPlaceholder()
          ? _value.occurredAt
          // ignore: cast_nullable_to_non_nullable
          : occurredAt as DateTime,
    );
  }
}

extension $StockMovementCopyWith on StockMovement {
  /// Returns a callable class that can be used as follows: `instanceOfStockMovement.copyWith(...)` or like so:`instanceOfStockMovement.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StockMovementCWProxy get copyWith => _$StockMovementCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockMovement _$StockMovementFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'StockMovement',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'business',
            'location',
            'product',
            'movement_type',
            'quantity',
            'source_type',
            'source_id',
            'occurred_at',
          ],
        );
        final val = StockMovement(
          id: $checkedConvert('id', (v) => v as String),
          business: $checkedConvert('business', (v) => v as String),
          location: $checkedConvert('location', (v) => v as String),
          product: $checkedConvert('product', (v) => v as String),
          pack: $checkedConvert('pack', (v) => v as String?),
          movementType: $checkedConvert(
            'movement_type',
            (v) => $enumDecode(_$StockMovementMovementTypeEnumEnumMap, v),
          ),
          quantity: $checkedConvert('quantity', (v) => (v as num).toDouble()),
          sourceType: $checkedConvert('source_type', (v) => v as String),
          sourceId: $checkedConvert('source_id', (v) => v as String),
          note: $checkedConvert('note', (v) => v as String?),
          occurredAt: $checkedConvert(
            'occurred_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'movementType': 'movement_type',
        'sourceType': 'source_type',
        'sourceId': 'source_id',
        'occurredAt': 'occurred_at',
      },
    );

Map<String, dynamic> _$StockMovementToJson(StockMovement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business': instance.business,
      'location': instance.location,
      'product': instance.product,
      'pack': ?instance.pack,
      'movement_type':
          _$StockMovementMovementTypeEnumEnumMap[instance.movementType]!,
      'quantity': instance.quantity,
      'source_type': instance.sourceType,
      'source_id': instance.sourceId,
      'note': ?instance.note,
      'occurred_at': instance.occurredAt.toIso8601String(),
    };

const _$StockMovementMovementTypeEnumEnumMap = {
  StockMovementMovementTypeEnum.OPENING: 'OPENING',
  StockMovementMovementTypeEnum.SALE: 'SALE',
  StockMovementMovementTypeEnum.SALE_REVERSAL: 'SALE_REVERSAL',
  StockMovementMovementTypeEnum.PURCHASE: 'PURCHASE',
  StockMovementMovementTypeEnum.PURCHASE_REVERSAL: 'PURCHASE_REVERSAL',
  StockMovementMovementTypeEnum.ADJUSTMENT: 'ADJUSTMENT',
  StockMovementMovementTypeEnum.TRANSFER_OUT: 'TRANSFER_OUT',
  StockMovementMovementTypeEnum.TRANSFER_IN: 'TRANSFER_IN',
  StockMovementMovementTypeEnum.TRANSFER_REVERSAL: 'TRANSFER_REVERSAL',
};
