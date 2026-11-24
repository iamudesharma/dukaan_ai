//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/sale_line.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sale.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Sale {
  /// Returns a new [Sale] instance.
  Sale({
    required this.id,

    required this.business,

    required this.location,

    this.customer,

    this.status,

    required this.number,

    required this.financialYear,

    required this.documentDate,

    this.priceMode,

    this.taxInclusive,

    this.sellerName,

    this.sellerGstin,

    this.buyerName,

    this.buyerGstin,

    this.placeOfSupply,

    this.subtotalMinor,

    this.discountTotalMinor,

    this.taxableTotalMinor,

    this.taxTotalMinor,

    this.grandTotalMinor,

    this.paidTotalMinor,

    this.dueTotalMinor,

    this.negativeStockAcknowledged,

    this.negativeStockReason,

    this.source_,

    required this.postedAt,

    this.reversalReason,

    this.reversedAt,

    required this.lines,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'location', required: true, includeIfNull: false)
  final String location;

  @JsonKey(name: r'customer', required: false, includeIfNull: false)
  final String? customer;

  /// * `DRAFT` - Draft * `POSTED` - Posted * `REVERSED` - Reversed
  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final SaleStatusEnum? status;

  @JsonKey(name: r'number', required: true, includeIfNull: false)
  final String number;

  @JsonKey(name: r'financial_year', required: true, includeIfNull: false)
  final String financialYear;

  @JsonKey(name: r'document_date', required: true, includeIfNull: false)
  final DateTime documentDate;

  /// * `RETAIL` - Retail * `WHOLESALE` - Wholesale
  @JsonKey(name: r'price_mode', required: false, includeIfNull: false)
  final SalePriceModeEnum? priceMode;

  @JsonKey(name: r'tax_inclusive', required: false, includeIfNull: false)
  final bool? taxInclusive;

  @JsonKey(name: r'seller_name', required: false, includeIfNull: false)
  final String? sellerName;

  @JsonKey(name: r'seller_gstin', required: false, includeIfNull: false)
  final String? sellerGstin;

  @JsonKey(name: r'buyer_name', required: false, includeIfNull: false)
  final String? buyerName;

  @JsonKey(name: r'buyer_gstin', required: false, includeIfNull: false)
  final String? buyerGstin;

  @JsonKey(name: r'place_of_supply', required: false, includeIfNull: false)
  final String? placeOfSupply;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'subtotal_minor', required: false, includeIfNull: false)
  final int? subtotalMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'discount_total_minor', required: false, includeIfNull: false)
  final int? discountTotalMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'taxable_total_minor', required: false, includeIfNull: false)
  final int? taxableTotalMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'tax_total_minor', required: false, includeIfNull: false)
  final int? taxTotalMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'grand_total_minor', required: false, includeIfNull: false)
  final int? grandTotalMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'paid_total_minor', required: false, includeIfNull: false)
  final int? paidTotalMinor;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'due_total_minor', required: false, includeIfNull: false)
  final int? dueTotalMinor;

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

  @JsonKey(name: r'source', required: false, includeIfNull: false)
  final String? source_;

  @JsonKey(name: r'posted_at', required: true, includeIfNull: false)
  final DateTime postedAt;

  @JsonKey(name: r'reversal_reason', required: false, includeIfNull: false)
  final String? reversalReason;

  @JsonKey(name: r'reversed_at', required: false, includeIfNull: false)
  final DateTime? reversedAt;

  @JsonKey(name: r'lines', required: true, includeIfNull: false)
  final List<SaleLine> lines;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sale &&
          other.id == id &&
          other.business == business &&
          other.location == location &&
          other.customer == customer &&
          other.status == status &&
          other.number == number &&
          other.financialYear == financialYear &&
          other.documentDate == documentDate &&
          other.priceMode == priceMode &&
          other.taxInclusive == taxInclusive &&
          other.sellerName == sellerName &&
          other.sellerGstin == sellerGstin &&
          other.buyerName == buyerName &&
          other.buyerGstin == buyerGstin &&
          other.placeOfSupply == placeOfSupply &&
          other.subtotalMinor == subtotalMinor &&
          other.discountTotalMinor == discountTotalMinor &&
          other.taxableTotalMinor == taxableTotalMinor &&
          other.taxTotalMinor == taxTotalMinor &&
          other.grandTotalMinor == grandTotalMinor &&
          other.paidTotalMinor == paidTotalMinor &&
          other.dueTotalMinor == dueTotalMinor &&
          other.negativeStockAcknowledged == negativeStockAcknowledged &&
          other.negativeStockReason == negativeStockReason &&
          other.source_ == source_ &&
          other.postedAt == postedAt &&
          other.reversalReason == reversalReason &&
          other.reversedAt == reversedAt &&
          other.lines == lines;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      location.hashCode +
      (customer == null ? 0 : customer.hashCode) +
      status.hashCode +
      number.hashCode +
      financialYear.hashCode +
      documentDate.hashCode +
      priceMode.hashCode +
      taxInclusive.hashCode +
      sellerName.hashCode +
      sellerGstin.hashCode +
      buyerName.hashCode +
      buyerGstin.hashCode +
      placeOfSupply.hashCode +
      subtotalMinor.hashCode +
      discountTotalMinor.hashCode +
      taxableTotalMinor.hashCode +
      taxTotalMinor.hashCode +
      grandTotalMinor.hashCode +
      paidTotalMinor.hashCode +
      dueTotalMinor.hashCode +
      negativeStockAcknowledged.hashCode +
      negativeStockReason.hashCode +
      source_.hashCode +
      postedAt.hashCode +
      reversalReason.hashCode +
      (reversedAt == null ? 0 : reversedAt.hashCode) +
      lines.hashCode;

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);

  Map<String, dynamic> toJson() => _$SaleToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `DRAFT` - Draft * `POSTED` - Posted * `REVERSED` - Reversed
enum SaleStatusEnum {
  @JsonValue(r'DRAFT')
  DRAFT(r'DRAFT'),
  @JsonValue(r'POSTED')
  POSTED(r'POSTED'),
  @JsonValue(r'REVERSED')
  REVERSED(r'REVERSED');

  const SaleStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `RETAIL` - Retail * `WHOLESALE` - Wholesale
enum SalePriceModeEnum {
  @JsonValue(r'RETAIL')
  RETAIL(r'RETAIL'),
  @JsonValue(r'WHOLESALE')
  WHOLESALE(r'WHOLESALE');

  const SalePriceModeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
