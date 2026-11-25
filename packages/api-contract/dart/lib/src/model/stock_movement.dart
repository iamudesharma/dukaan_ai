//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stock_movement.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StockMovement {
  /// Returns a new [StockMovement] instance.
  StockMovement({
    required this.id,

    required this.business,

    required this.location,

    required this.product,

    this.pack,

    required this.movementType,

    required this.quantity,

    required this.sourceType,

    required this.sourceId,

    this.note,

    required this.occurredAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'location', required: true, includeIfNull: false)
  final String location;

  @JsonKey(name: r'product', required: true, includeIfNull: false)
  final String product;

  @JsonKey(name: r'pack', required: false, includeIfNull: false)
  final String? pack;

  /// * `OPENING` - Opening stock * `SALE` - Sale * `SALE_REVERSAL` - Sale reversal * `PURCHASE` - Purchase * `PURCHASE_REVERSAL` - Purchase reversal * `ADJUSTMENT` - Adjustment * `TRANSFER_OUT` - Transfer out * `TRANSFER_IN` - Transfer in * `TRANSFER_REVERSAL` - Transfer reversal
  @JsonKey(name: r'movement_type', required: true, includeIfNull: false)
  final StockMovementMovementTypeEnum movementType;

  @JsonKey(name: r'quantity', required: true, includeIfNull: false)
  final double quantity;

  @JsonKey(name: r'source_type', required: true, includeIfNull: false)
  final String sourceType;

  @JsonKey(name: r'source_id', required: true, includeIfNull: false)
  final String sourceId;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'occurred_at', required: true, includeIfNull: false)
  final DateTime occurredAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockMovement &&
          other.id == id &&
          other.business == business &&
          other.location == location &&
          other.product == product &&
          other.pack == pack &&
          other.movementType == movementType &&
          other.quantity == quantity &&
          other.sourceType == sourceType &&
          other.sourceId == sourceId &&
          other.note == note &&
          other.occurredAt == occurredAt;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      location.hashCode +
      product.hashCode +
      (pack == null ? 0 : pack.hashCode) +
      movementType.hashCode +
      quantity.hashCode +
      sourceType.hashCode +
      sourceId.hashCode +
      note.hashCode +
      occurredAt.hashCode;

  factory StockMovement.fromJson(Map<String, dynamic> json) =>
      _$StockMovementFromJson(json);

  Map<String, dynamic> toJson() => _$StockMovementToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `OPENING` - Opening stock * `SALE` - Sale * `SALE_REVERSAL` - Sale reversal * `PURCHASE` - Purchase * `PURCHASE_REVERSAL` - Purchase reversal * `ADJUSTMENT` - Adjustment * `TRANSFER_OUT` - Transfer out * `TRANSFER_IN` - Transfer in * `TRANSFER_REVERSAL` - Transfer reversal
enum StockMovementMovementTypeEnum {
  @JsonValue(r'OPENING')
  OPENING(r'OPENING'),
  @JsonValue(r'SALE')
  SALE(r'SALE'),
  @JsonValue(r'SALE_REVERSAL')
  SALE_REVERSAL(r'SALE_REVERSAL'),
  @JsonValue(r'PURCHASE')
  PURCHASE(r'PURCHASE'),
  @JsonValue(r'PURCHASE_REVERSAL')
  PURCHASE_REVERSAL(r'PURCHASE_REVERSAL'),
  @JsonValue(r'ADJUSTMENT')
  ADJUSTMENT(r'ADJUSTMENT'),
  @JsonValue(r'TRANSFER_OUT')
  TRANSFER_OUT(r'TRANSFER_OUT'),
  @JsonValue(r'TRANSFER_IN')
  TRANSFER_IN(r'TRANSFER_IN'),
  @JsonValue(r'TRANSFER_REVERSAL')
  TRANSFER_REVERSAL(r'TRANSFER_REVERSAL');

  const StockMovementMovementTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
