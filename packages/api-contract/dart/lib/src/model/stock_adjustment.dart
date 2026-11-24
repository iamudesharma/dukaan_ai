//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stock_adjustment.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StockAdjustment {
  /// Returns a new [StockAdjustment] instance.
  StockAdjustment({
    required this.businessId,

    required this.locationId,

    required this.productId,

    required this.quantityDelta,

    this.movementType = StockAdjustmentMovementTypeEnum.ADJUSTMENT,

    required this.reason,

    this.negativeStockAcknowledged = false,

    required this.idempotencyKey,
  });

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'location_id', required: true, includeIfNull: false)
  final String locationId;

  @JsonKey(name: r'product_id', required: true, includeIfNull: false)
  final String productId;

  @JsonKey(name: r'quantity_delta', required: true, includeIfNull: false)
  final double quantityDelta;

  /// * `OPENING` - OPENING * `ADJUSTMENT` - ADJUSTMENT
  @JsonKey(
    defaultValue: 'ADJUSTMENT',
    name: r'movement_type',
    required: false,
    includeIfNull: false,
  )
  final StockAdjustmentMovementTypeEnum? movementType;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @JsonKey(
    defaultValue: false,
    name: r'negative_stock_acknowledged',
    required: false,
    includeIfNull: false,
  )
  final bool? negativeStockAcknowledged;

  @JsonKey(name: r'idempotency_key', required: true, includeIfNull: false)
  final String idempotencyKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockAdjustment &&
          other.businessId == businessId &&
          other.locationId == locationId &&
          other.productId == productId &&
          other.quantityDelta == quantityDelta &&
          other.movementType == movementType &&
          other.reason == reason &&
          other.negativeStockAcknowledged == negativeStockAcknowledged &&
          other.idempotencyKey == idempotencyKey;

  @override
  int get hashCode =>
      businessId.hashCode +
      locationId.hashCode +
      productId.hashCode +
      quantityDelta.hashCode +
      movementType.hashCode +
      reason.hashCode +
      negativeStockAcknowledged.hashCode +
      idempotencyKey.hashCode;

  factory StockAdjustment.fromJson(Map<String, dynamic> json) =>
      _$StockAdjustmentFromJson(json);

  Map<String, dynamic> toJson() => _$StockAdjustmentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `OPENING` - OPENING * `ADJUSTMENT` - ADJUSTMENT
enum StockAdjustmentMovementTypeEnum {
  @JsonValue(r'OPENING')
  OPENING(r'OPENING'),
  @JsonValue(r'ADJUSTMENT')
  ADJUSTMENT(r'ADJUSTMENT');

  const StockAdjustmentMovementTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
