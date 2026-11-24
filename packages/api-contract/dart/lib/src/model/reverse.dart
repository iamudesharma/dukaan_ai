//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reverse.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Reverse {
  /// Returns a new [Reverse] instance.
  Reverse({
    required this.reason,

    required this.idempotencyKey,

    this.negativeStockAcknowledged = false,
  });

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @JsonKey(name: r'idempotency_key', required: true, includeIfNull: false)
  final String idempotencyKey;

  @JsonKey(
    defaultValue: false,
    name: r'negative_stock_acknowledged',
    required: false,
    includeIfNull: false,
  )
  final bool? negativeStockAcknowledged;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reverse &&
          other.reason == reason &&
          other.idempotencyKey == idempotencyKey &&
          other.negativeStockAcknowledged == negativeStockAcknowledged;

  @override
  int get hashCode =>
      reason.hashCode +
      idempotencyKey.hashCode +
      negativeStockAcknowledged.hashCode;

  factory Reverse.fromJson(Map<String, dynamic> json) =>
      _$ReverseFromJson(json);

  Map<String, dynamic> toJson() => _$ReverseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
