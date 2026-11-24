//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/payment_allocation_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_reallocation.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaymentReallocation {
  /// Returns a new [PaymentReallocation] instance.
  PaymentReallocation({
    required this.allocations,

    required this.reason,

    required this.idempotencyKey,
  });

  @JsonKey(name: r'allocations', required: true, includeIfNull: false)
  final List<PaymentAllocationInput> allocations;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @JsonKey(name: r'idempotency_key', required: true, includeIfNull: false)
  final String idempotencyKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentReallocation &&
          other.allocations == allocations &&
          other.reason == reason &&
          other.idempotencyKey == idempotencyKey;

  @override
  int get hashCode =>
      allocations.hashCode + reason.hashCode + idempotencyKey.hashCode;

  factory PaymentReallocation.fromJson(Map<String, dynamic> json) =>
      _$PaymentReallocationFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentReallocationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
