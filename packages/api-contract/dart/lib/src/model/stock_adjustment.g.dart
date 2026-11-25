// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_adjustment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$StockAdjustmentCWProxy {
  StockAdjustment businessId(String businessId);

  StockAdjustment locationId(String locationId);

  StockAdjustment productId(String productId);

  StockAdjustment quantityDelta(double quantityDelta);

  StockAdjustment movementType(StockAdjustmentMovementTypeEnum? movementType);

  StockAdjustment reason(String reason);

  StockAdjustment negativeStockAcknowledged(bool? negativeStockAcknowledged);

  StockAdjustment idempotencyKey(String idempotencyKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StockAdjustment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StockAdjustment(...).copyWith(id: 12, name: "My name")
  /// ````
  StockAdjustment call({
    String businessId,
    String locationId,
    String productId,
    double quantityDelta,
    StockAdjustmentMovementTypeEnum? movementType,
    String reason,
    bool? negativeStockAcknowledged,
    String idempotencyKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfStockAdjustment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfStockAdjustment.copyWith.fieldName(...)`
class _$StockAdjustmentCWProxyImpl implements _$StockAdjustmentCWProxy {
  const _$StockAdjustmentCWProxyImpl(this._value);

  final StockAdjustment _value;

  @override
  StockAdjustment businessId(String businessId) => this(businessId: businessId);

  @override
  StockAdjustment locationId(String locationId) => this(locationId: locationId);

  @override
  StockAdjustment productId(String productId) => this(productId: productId);

  @override
  StockAdjustment quantityDelta(double quantityDelta) =>
      this(quantityDelta: quantityDelta);

  @override
  StockAdjustment movementType(StockAdjustmentMovementTypeEnum? movementType) =>
      this(movementType: movementType);

  @override
  StockAdjustment reason(String reason) => this(reason: reason);

  @override
  StockAdjustment negativeStockAcknowledged(bool? negativeStockAcknowledged) =>
      this(negativeStockAcknowledged: negativeStockAcknowledged);

  @override
  StockAdjustment idempotencyKey(String idempotencyKey) =>
      this(idempotencyKey: idempotencyKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `StockAdjustment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// StockAdjustment(...).copyWith(id: 12, name: "My name")
  /// ````
  StockAdjustment call({
    Object? businessId = const $CopyWithPlaceholder(),
    Object? locationId = const $CopyWithPlaceholder(),
    Object? productId = const $CopyWithPlaceholder(),
    Object? quantityDelta = const $CopyWithPlaceholder(),
    Object? movementType = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? negativeStockAcknowledged = const $CopyWithPlaceholder(),
    Object? idempotencyKey = const $CopyWithPlaceholder(),
  }) {
    return StockAdjustment(
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      locationId: locationId == const $CopyWithPlaceholder()
          ? _value.locationId
          // ignore: cast_nullable_to_non_nullable
          : locationId as String,
      productId: productId == const $CopyWithPlaceholder()
          ? _value.productId
          // ignore: cast_nullable_to_non_nullable
          : productId as String,
      quantityDelta: quantityDelta == const $CopyWithPlaceholder()
          ? _value.quantityDelta
          // ignore: cast_nullable_to_non_nullable
          : quantityDelta as double,
      movementType: movementType == const $CopyWithPlaceholder()
          ? _value.movementType
          // ignore: cast_nullable_to_non_nullable
          : movementType as StockAdjustmentMovementTypeEnum?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      negativeStockAcknowledged:
          negativeStockAcknowledged == const $CopyWithPlaceholder()
          ? _value.negativeStockAcknowledged
          // ignore: cast_nullable_to_non_nullable
          : negativeStockAcknowledged as bool?,
      idempotencyKey: idempotencyKey == const $CopyWithPlaceholder()
          ? _value.idempotencyKey
          // ignore: cast_nullable_to_non_nullable
          : idempotencyKey as String,
    );
  }
}

extension $StockAdjustmentCopyWith on StockAdjustment {
  /// Returns a callable class that can be used as follows: `instanceOfStockAdjustment.copyWith(...)` or like so:`instanceOfStockAdjustment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StockAdjustmentCWProxy get copyWith => _$StockAdjustmentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockAdjustment _$StockAdjustmentFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'StockAdjustment',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'business_id',
        'location_id',
        'product_id',
        'quantity_delta',
        'reason',
        'idempotency_key',
      ],
    );
    final val = StockAdjustment(
      businessId: $checkedConvert('business_id', (v) => v as String),
      locationId: $checkedConvert('location_id', (v) => v as String),
      productId: $checkedConvert('product_id', (v) => v as String),
      quantityDelta: $checkedConvert(
        'quantity_delta',
        (v) => (v as num).toDouble(),
      ),
      movementType: $checkedConvert(
        'movement_type',
        (v) =>
            $enumDecodeNullable(_$StockAdjustmentMovementTypeEnumEnumMap, v) ??
            'ADJUSTMENT',
      ),
      reason: $checkedConvert('reason', (v) => v as String),
      negativeStockAcknowledged: $checkedConvert(
        'negative_stock_acknowledged',
        (v) => v as bool? ?? false,
      ),
      idempotencyKey: $checkedConvert('idempotency_key', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'businessId': 'business_id',
    'locationId': 'location_id',
    'productId': 'product_id',
    'quantityDelta': 'quantity_delta',
    'movementType': 'movement_type',
    'negativeStockAcknowledged': 'negative_stock_acknowledged',
    'idempotencyKey': 'idempotency_key',
  },
);

Map<String, dynamic> _$StockAdjustmentToJson(StockAdjustment instance) =>
    <String, dynamic>{
      'business_id': instance.businessId,
      'location_id': instance.locationId,
      'product_id': instance.productId,
      'quantity_delta': instance.quantityDelta,
      'movement_type':
          ?_$StockAdjustmentMovementTypeEnumEnumMap[instance.movementType],
      'reason': instance.reason,
      'negative_stock_acknowledged': ?instance.negativeStockAcknowledged,
      'idempotency_key': instance.idempotencyKey,
    };

const _$StockAdjustmentMovementTypeEnumEnumMap = {
  StockAdjustmentMovementTypeEnum.OPENING: 'OPENING',
  StockAdjustmentMovementTypeEnum.ADJUSTMENT: 'ADJUSTMENT',
};
