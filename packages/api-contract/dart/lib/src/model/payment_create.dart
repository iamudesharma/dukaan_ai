//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_create.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaymentCreate {
  /// Returns a new [PaymentCreate] instance.
  PaymentCreate({
    required this.businessId,

    required this.locationId,

    required this.partyId,

    required this.direction,

    required this.method,

    required this.amountMinor,

    this.saleId,

    this.purchaseId,

    this.paymentDate,

    this.reference,

    this.note,

    required this.idempotencyKey,
  });

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'location_id', required: true, includeIfNull: false)
  final String locationId;

  @JsonKey(name: r'party_id', required: true, includeIfNull: false)
  final String partyId;

  /// * `RECEIPT` - Customer receipt * `PAYMENT` - Supplier payment
  @JsonKey(name: r'direction', required: true, includeIfNull: false)
  final PaymentCreateDirectionEnum direction;

  /// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
  @JsonKey(name: r'method', required: true, includeIfNull: false)
  final PaymentCreateMethodEnum method;

  // minimum: 1
  @JsonKey(name: r'amount_minor', required: true, includeIfNull: false)
  final int amountMinor;

  @JsonKey(name: r'sale_id', required: false, includeIfNull: false)
  final String? saleId;

  @JsonKey(name: r'purchase_id', required: false, includeIfNull: false)
  final String? purchaseId;

  @JsonKey(name: r'payment_date', required: false, includeIfNull: false)
  final DateTime? paymentDate;

  @JsonKey(name: r'reference', required: false, includeIfNull: false)
  final String? reference;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'idempotency_key', required: true, includeIfNull: false)
  final String idempotencyKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentCreate &&
          other.businessId == businessId &&
          other.locationId == locationId &&
          other.partyId == partyId &&
          other.direction == direction &&
          other.method == method &&
          other.amountMinor == amountMinor &&
          other.saleId == saleId &&
          other.purchaseId == purchaseId &&
          other.paymentDate == paymentDate &&
          other.reference == reference &&
          other.note == note &&
          other.idempotencyKey == idempotencyKey;

  @override
  int get hashCode =>
      businessId.hashCode +
      locationId.hashCode +
      partyId.hashCode +
      direction.hashCode +
      method.hashCode +
      amountMinor.hashCode +
      (saleId == null ? 0 : saleId.hashCode) +
      (purchaseId == null ? 0 : purchaseId.hashCode) +
      paymentDate.hashCode +
      reference.hashCode +
      note.hashCode +
      idempotencyKey.hashCode;

  factory PaymentCreate.fromJson(Map<String, dynamic> json) =>
      _$PaymentCreateFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `RECEIPT` - Customer receipt * `PAYMENT` - Supplier payment
enum PaymentCreateDirectionEnum {
  @JsonValue(r'RECEIPT')
  RECEIPT(r'RECEIPT'),
  @JsonValue(r'PAYMENT')
  PAYMENT(r'PAYMENT');

  const PaymentCreateDirectionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
enum PaymentCreateMethodEnum {
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

  const PaymentCreateMethodEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
