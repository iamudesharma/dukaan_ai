//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/sale_line_input.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sale_create.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaleCreate {
  /// Returns a new [SaleCreate] instance.
  SaleCreate({
    required this.businessId,

    required this.locationId,

    this.customerId,

    this.invoiceDate,

    this.priceMode = SaleCreatePriceModeEnum.RETAIL,

    this.taxInclusive = false,

    this.discountTotalMinor = 0,

    required this.lines,

    this.paidAmountMinor = 0,

    this.paymentMethod = SaleCreatePaymentMethodEnum.CASH,

    this.paymentReference,

    this.negativeStockAcknowledged = false,

    this.negativeStockReason,

    required this.idempotencyKey,
  });

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'location_id', required: true, includeIfNull: false)
  final String locationId;

  @JsonKey(name: r'customer_id', required: false, includeIfNull: false)
  final String? customerId;

  @JsonKey(name: r'invoice_date', required: false, includeIfNull: false)
  final DateTime? invoiceDate;

  /// * `RETAIL` - Retail * `WHOLESALE` - Wholesale
  @JsonKey(
    defaultValue: 'RETAIL',
    name: r'price_mode',
    required: false,
    includeIfNull: false,
  )
  final SaleCreatePriceModeEnum? priceMode;

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
  final List<SaleLineInput> lines;

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
  final SaleCreatePaymentMethodEnum? paymentMethod;

  @JsonKey(name: r'payment_reference', required: false, includeIfNull: false)
  final String? paymentReference;

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
      other is SaleCreate &&
          other.businessId == businessId &&
          other.locationId == locationId &&
          other.customerId == customerId &&
          other.invoiceDate == invoiceDate &&
          other.priceMode == priceMode &&
          other.taxInclusive == taxInclusive &&
          other.discountTotalMinor == discountTotalMinor &&
          other.lines == lines &&
          other.paidAmountMinor == paidAmountMinor &&
          other.paymentMethod == paymentMethod &&
          other.paymentReference == paymentReference &&
          other.negativeStockAcknowledged == negativeStockAcknowledged &&
          other.negativeStockReason == negativeStockReason &&
          other.idempotencyKey == idempotencyKey;

  @override
  int get hashCode =>
      businessId.hashCode +
      locationId.hashCode +
      (customerId == null ? 0 : customerId.hashCode) +
      invoiceDate.hashCode +
      priceMode.hashCode +
      taxInclusive.hashCode +
      discountTotalMinor.hashCode +
      lines.hashCode +
      paidAmountMinor.hashCode +
      paymentMethod.hashCode +
      paymentReference.hashCode +
      negativeStockAcknowledged.hashCode +
      negativeStockReason.hashCode +
      idempotencyKey.hashCode;

  factory SaleCreate.fromJson(Map<String, dynamic> json) =>
      _$SaleCreateFromJson(json);

  Map<String, dynamic> toJson() => _$SaleCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `RETAIL` - Retail * `WHOLESALE` - Wholesale
enum SaleCreatePriceModeEnum {
  @JsonValue(r'RETAIL')
  RETAIL(r'RETAIL'),
  @JsonValue(r'WHOLESALE')
  WHOLESALE(r'WHOLESALE');

  const SaleCreatePriceModeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `CASH` - Cash * `UPI` - UPI * `CARD` - Card * `BANK` - Bank transfer * `OTHER` - Other
enum SaleCreatePaymentMethodEnum {
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

  const SaleCreatePaymentMethodEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
