//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/payment_allocation.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Payment {
  /// Returns a new [Payment] instance.
  Payment({
    required this.id,

    required this.business,

    required this.location,

    this.party,

    required this.partyName,

    required this.direction,

    required this.method,

    required this.amountMinor,

    this.reference,

    this.note,

    required this.paymentDate,

    required this.occurredAt,

    this.status,

    this.source_,

    this.reversalReason,

    this.reversedAt,

    required this.allocations,

    required this.allocatedTotalMinor,

    required this.unallocatedTotalMinor,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'location', required: true, includeIfNull: false)
  final String location;

  @JsonKey(name: r'party', required: false, includeIfNull: false)
  final String? party;

  @JsonKey(name: r'party_name', required: true, includeIfNull: false)
  final String partyName;

  /// * `RECEIPT` - Customer receipt * `PAYMENT` - Supplier payment
  @JsonKey(name: r'direction', required: true, includeIfNull: false)
  final PaymentDirectionEnum direction;

  /// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
  @JsonKey(name: r'method', required: true, includeIfNull: false)
  final PaymentMethodEnum method;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'amount_minor', required: true, includeIfNull: false)
  final int amountMinor;

  @JsonKey(name: r'reference', required: false, includeIfNull: false)
  final String? reference;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'payment_date', required: true, includeIfNull: false)
  final DateTime paymentDate;

  @JsonKey(name: r'occurred_at', required: true, includeIfNull: false)
  final DateTime occurredAt;

  /// * `DRAFT` - Draft * `POSTED` - Posted * `REVERSED` - Reversed
  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final PaymentStatusEnum? status;

  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final String? source_;

  @JsonKey(name: r'reversal_reason', required: false, includeIfNull: false)
  final String? reversalReason;

  @JsonKey(name: r'reversed_at', required: false, includeIfNull: false)
  final DateTime? reversedAt;

  @JsonKey(name: r'allocations', required: true, includeIfNull: false)
  final List<PaymentAllocation> allocations;

  @JsonKey(name: r'allocated_total_minor', required: true, includeIfNull: false)
  final int allocatedTotalMinor;

  @JsonKey(
    name: r'unallocated_total_minor',
    required: true,
    includeIfNull: false,
  )
  final int unallocatedTotalMinor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payment &&
          other.id == id &&
          other.business == business &&
          other.location == location &&
          other.party == party &&
          other.partyName == partyName &&
          other.direction == direction &&
          other.method == method &&
          other.amountMinor == amountMinor &&
          other.reference == reference &&
          other.note == note &&
          other.paymentDate == paymentDate &&
          other.occurredAt == occurredAt &&
          other.status == status &&
          other.source_ == source_ &&
          other.reversalReason == reversalReason &&
          other.reversedAt == reversedAt &&
          other.allocations == allocations &&
          other.allocatedTotalMinor == allocatedTotalMinor &&
          other.unallocatedTotalMinor == unallocatedTotalMinor;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      location.hashCode +
      (party == null ? 0 : party.hashCode) +
      partyName.hashCode +
      direction.hashCode +
      method.hashCode +
      amountMinor.hashCode +
      reference.hashCode +
      note.hashCode +
      paymentDate.hashCode +
      occurredAt.hashCode +
      status.hashCode +
      source_.hashCode +
      reversalReason.hashCode +
      (reversedAt == null ? 0 : reversedAt.hashCode) +
      allocations.hashCode +
      allocatedTotalMinor.hashCode +
      unallocatedTotalMinor.hashCode;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `RECEIPT` - Customer receipt * `PAYMENT` - Supplier payment
enum PaymentDirectionEnum {
  @JsonValue(r'RECEIPT')
  RECEIPT(r'RECEIPT'),
  @JsonValue(r'PAYMENT')
  PAYMENT(r'PAYMENT');

  const PaymentDirectionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
enum PaymentMethodEnum {
  @JsonValue(r'CASH')
  CASH(r'CASH'),
  @JsonValue(r'UPI')
  UPI(r'UPI'),
  @JsonValue(r'CARD')
  CARD(r'CARD'),
  @JsonValue(r'BANK')
  BANK(r'BANK'),
  @JsonValue(r'OTHER')
  OTHER(r'OTHER');

  const PaymentMethodEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `DRAFT` - Draft * `POSTED` - Posted * `REVERSED` - Reversed
enum PaymentStatusEnum {
  @JsonValue(r'DRAFT')
  DRAFT(r'DRAFT'),
  @JsonValue(r'POSTED')
  POSTED(r'POSTED'),
  @JsonValue(r'REVERSED')
  REVERSED(r'REVERSED');

  const PaymentStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
