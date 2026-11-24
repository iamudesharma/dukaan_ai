//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/transfer_line_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transfer_create.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TransferCreate {
  /// Returns a new [TransferCreate] instance.
  TransferCreate({
    required this.businessId,

    required this.fromLocationId,

    required this.toLocationId,

    this.transferDate,

    this.note,

    required this.lines,

    this.negativeStockAcknowledged = false,

    this.negativeStockReason,

    required this.idempotencyKey,
  });

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'from_location_id', required: true, includeIfNull: false)
  final String fromLocationId;

  @JsonKey(name: r'to_location_id', required: true, includeIfNull: false)
  final String toLocationId;

  @JsonKey(name: r'transfer_date', required: false, includeIfNull: false)
  final DateTime? transferDate;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'lines', required: true, includeIfNull: false)
  final List<TransferLineInput> lines;

  @JsonKey(
    defaultValue: false,
    name: r'negative_stock_acknowledged',
    required: false,
    includeIfNull: false,
  )
  final bool? negativeStockAcknowledged;

  @JsonKey(
    name: r'negative_stock_reason',
    required: false,
    includeIfNull: false,
  )
  final String? negativeStockReason;

  @JsonKey(name: r'idempotency_key', required: true, includeIfNull: false)
  final String idempotencyKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferCreate &&
          other.businessId == businessId &&
          other.fromLocationId == fromLocationId &&
          other.toLocationId == toLocationId &&
          other.transferDate == transferDate &&
          other.note == note &&
          other.lines == lines &&
          other.negativeStockAcknowledged == negativeStockAcknowledged &&
          other.negativeStockReason == negativeStockReason &&
          other.idempotencyKey == idempotencyKey;

  @override
  int get hashCode =>
      businessId.hashCode +
      fromLocationId.hashCode +
      toLocationId.hashCode +
      transferDate.hashCode +
      note.hashCode +
      lines.hashCode +
      negativeStockAcknowledged.hashCode +
      negativeStockReason.hashCode +
      idempotencyKey.hashCode;

  factory TransferCreate.fromJson(Map<String, dynamic> json) =>
      _$TransferCreateFromJson(json);

  Map<String, dynamic> toJson() => _$TransferCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
