//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/transfer_line.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transfer.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Transfer {
  /// Returns a new [Transfer] instance.
  Transfer({
    required this.id,

    required this.business,

    required this.fromLocation,

    required this.toLocation,

    this.status,

    required this.number,

    required this.documentDate,

    this.note,

    this.negativeStockAcknowledged,

    this.negativeStockReason,

    required this.postedAt,

    this.reversalReason,

    this.reversedAt,

    required this.lines,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'from_location', required: true, includeIfNull: false)
  final String fromLocation;

  @JsonKey(name: r'to_location', required: true, includeIfNull: false)
  final String toLocation;

  /// * `DRAFT` - Draft * `POSTED` - Posted * `REVERSED` - Reversed
  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final TransferStatusEnum? status;

  @JsonKey(name: r'number', required: true, includeIfNull: false)
  final String number;

  @JsonKey(name: r'document_date', required: true, includeIfNull: false)
  final DateTime documentDate;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(
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

  @JsonKey(name: r'posted_at', required: true, includeIfNull: false)
  final DateTime postedAt;

  @JsonKey(name: r'reversal_reason', required: false, includeIfNull: false)
  final String? reversalReason;

  @JsonKey(name: r'reversed_at', required: false, includeIfNull: false)
  final DateTime? reversedAt;

  @JsonKey(name: r'lines', required: true, includeIfNull: false)
  final List<TransferLine> lines;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transfer &&
          other.id == id &&
          other.business == business &&
          other.fromLocation == fromLocation &&
          other.toLocation == toLocation &&
          other.status == status &&
          other.number == number &&
          other.documentDate == documentDate &&
          other.note == note &&
          other.negativeStockAcknowledged == negativeStockAcknowledged &&
          other.negativeStockReason == negativeStockReason &&
          other.postedAt == postedAt &&
          other.reversalReason == reversalReason &&
          other.reversedAt == reversedAt &&
          other.lines == lines;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      fromLocation.hashCode +
      toLocation.hashCode +
      status.hashCode +
      number.hashCode +
      documentDate.hashCode +
      note.hashCode +
      negativeStockAcknowledged.hashCode +
      negativeStockReason.hashCode +
      postedAt.hashCode +
      reversalReason.hashCode +
      (reversedAt == null ? 0 : reversedAt.hashCode) +
      lines.hashCode;

  factory Transfer.fromJson(Map<String, dynamic> json) =>
      _$TransferFromJson(json);

  Map<String, dynamic> toJson() => _$TransferToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `DRAFT` - Draft * `POSTED` - Posted * `REVERSED` - Reversed
enum TransferStatusEnum {
  @JsonValue(r'DRAFT')
  DRAFT(r'DRAFT'),
  @JsonValue(r'POSTED')
  POSTED(r'POSTED'),
  @JsonValue(r'REVERSED')
  REVERSED(r'REVERSED');

  const TransferStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
