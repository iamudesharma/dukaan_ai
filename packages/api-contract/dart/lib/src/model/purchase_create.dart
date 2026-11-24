//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/purchase_line_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'purchase_create.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PurchaseCreate {
  /// Returns a new [PurchaseCreate] instance.
  PurchaseCreate({
    required this.businessId,

    required this.locationId,

    required this.supplierId,

    this.purchaseDate,

    this.supplierBillNumber,

    this.taxInclusive = false,

    this.discountTotalMinor = 0,

    required this.lines,

    this.paidAmountMinor = 0,

    this.paymentMethod = PurchaseCreatePaymentMethodEnum.CASH,

    this.paymentReference,

    required this.idempotencyKey,
  });

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'location_id', required: true, includeIfNull: false)
  final String locationId;

  @JsonKey(name: r'supplier_id', required: true, includeIfNull: false)
  final String supplierId;

  @JsonKey(name: r'purchase_date', required: false, includeIfNull: false)
  final DateTime? purchaseDate;

  @JsonKey(name: r'supplier_bill_number', required: false, includeIfNull: false)
  final String? supplierBillNumber;

  @JsonKey(
    defaultValue: false,
    name: r'tax_inclusive',
    required: false,
    includeIfNull: false,
  )
  final bool? taxInclusive;

  // minimum: 0
  @JsonKey(
    defaultValue: 0,
    name: r'discount_total_minor',
    required: false,
    includeIfNull: false,
  )
  final int? discountTotalMinor;

  @JsonKey(name: r'lines', required: true, includeIfNull: false)
  final List<PurchaseLineInput> lines;

  // minimum: 0
  @JsonKey(
    defaultValue: 0,
    name: r'paid_amount_minor',
    required: false,
    includeIfNull: false,
  )
  final int? paidAmountMinor;

  /// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
  @JsonKey(
    defaultValue: 'CASH',
    name: r'payment_method',
    required: false,
    includeIfNull: false,
  )
  final PurchaseCreatePaymentMethodEnum? paymentMethod;

  @JsonKey(name: r'payment_reference', required: false, includeIfNull: false)
  final String? paymentReference;

  @JsonKey(name: r'idempotency_key', required: true, includeIfNull: false)
  final String idempotencyKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseCreate &&
          other.businessId == businessId &&
          other.locationId == locationId &&
          other.supplierId == supplierId &&
          other.purchaseDate == purchaseDate &&
          other.supplierBillNumber == supplierBillNumber &&
          other.taxInclusive == taxInclusive &&
          other.discountTotalMinor == discountTotalMinor &&
          other.lines == lines &&
          other.paidAmountMinor == paidAmountMinor &&
          other.paymentMethod == paymentMethod &&
          other.paymentReference == paymentReference &&
          other.idempotencyKey == idempotencyKey;

  @override
  int get hashCode =>
      businessId.hashCode +
      locationId.hashCode +
      supplierId.hashCode +
      purchaseDate.hashCode +
      supplierBillNumber.hashCode +
      taxInclusive.hashCode +
      discountTotalMinor.hashCode +
      lines.hashCode +
      paidAmountMinor.hashCode +
      paymentMethod.hashCode +
      paymentReference.hashCode +
      idempotencyKey.hashCode;

  factory PurchaseCreate.fromJson(Map<String, dynamic> json) =>
      _$PurchaseCreateFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
enum PurchaseCreatePaymentMethodEnum {
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

  const PurchaseCreatePaymentMethodEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
