// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaleCWProxy {
  Sale id(String id);

  Sale business(String business);

  Sale location(String location);

  Sale customer(String? customer);

  Sale customerName(String customerName);

  Sale status(SaleStatusEnum? status);

  Sale number(String number);

  Sale invoiceNumber(String invoiceNumber);

  Sale occurredAt(DateTime occurredAt);

  Sale financialYear(String financialYear);

  Sale documentDate(DateTime documentDate);

  Sale priceMode(SalePriceModeEnum? priceMode);

  Sale taxInclusive(bool? taxInclusive);

  Sale sellerName(String? sellerName);

  Sale sellerGstin(String? sellerGstin);

  Sale buyerName(String? buyerName);

  Sale buyerGstin(String? buyerGstin);

  Sale placeOfSupply(String? placeOfSupply);

  Sale subtotalMinor(int? subtotalMinor);

  Sale discountTotalMinor(int? discountTotalMinor);

  Sale taxableTotalMinor(int? taxableTotalMinor);

  Sale taxTotalMinor(int? taxTotalMinor);

  Sale grandTotalMinor(int? grandTotalMinor);

  Sale paidTotalMinor(int? paidTotalMinor);

  Sale dueTotalMinor(int? dueTotalMinor);

  Sale negativeStockAcknowledged(bool? negativeStockAcknowledged);

  Sale negativeStockReason(String? negativeStockReason);

  Sale source_(String? source_);

  Sale postedAt(DateTime postedAt);

  Sale reversalReason(String? reversalReason);

  Sale reversedAt(DateTime? reversedAt);

  Sale lines(List<SaleLine> lines);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Sale(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Sale(...).copyWith(id: 12, name: "My name")
  /// ````
  Sale call({
    String id,
    String business,
    String location,
    String? customer,
    String customerName,
    SaleStatusEnum? status,
    String number,
    String invoiceNumber,
    DateTime occurredAt,
    String financialYear,
    DateTime documentDate,
    SalePriceModeEnum? priceMode,
    bool? taxInclusive,
    String? sellerName,
    String? sellerGstin,
    String? buyerName,
    String? buyerGstin,
    String? placeOfSupply,
    int? subtotalMinor,
    int? discountTotalMinor,
    int? taxableTotalMinor,
    int? taxTotalMinor,
    int? grandTotalMinor,
    int? paidTotalMinor,
    int? dueTotalMinor,
    bool? negativeStockAcknowledged,
    String? negativeStockReason,
    String? source_,
    DateTime postedAt,
    String? reversalReason,
    DateTime? reversedAt,
    List<SaleLine> lines,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSale.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSale.copyWith.fieldName(...)`
class _$SaleCWProxyImpl implements _$SaleCWProxy {
  const _$SaleCWProxyImpl(this._value);

  final Sale _value;

  @override
  Sale id(String id) => this(id: id);

  @override
  Sale business(String business) => this(business: business);

  @override
  Sale location(String location) => this(location: location);

  @override
  Sale customer(String? customer) => this(customer: customer);

  @override
  Sale customerName(String customerName) => this(customerName: customerName);

  @override
  Sale status(SaleStatusEnum? status) => this(status: status);

  @override
  Sale number(String number) => this(number: number);

  @override
  Sale invoiceNumber(String invoiceNumber) =>
      this(invoiceNumber: invoiceNumber);

  @override
  Sale occurredAt(DateTime occurredAt) => this(occurredAt: occurredAt);

  @override
  Sale financialYear(String financialYear) =>
      this(financialYear: financialYear);

  @override
  Sale documentDate(DateTime documentDate) => this(documentDate: documentDate);

  @override
  Sale priceMode(SalePriceModeEnum? priceMode) => this(priceMode: priceMode);

  @override
  Sale taxInclusive(bool? taxInclusive) => this(taxInclusive: taxInclusive);

  @override
  Sale sellerName(String? sellerName) => this(sellerName: sellerName);

  @override
  Sale sellerGstin(String? sellerGstin) => this(sellerGstin: sellerGstin);

  @override
  Sale buyerName(String? buyerName) => this(buyerName: buyerName);

  @override
  Sale buyerGstin(String? buyerGstin) => this(buyerGstin: buyerGstin);

  @override
  Sale placeOfSupply(String? placeOfSupply) =>
      this(placeOfSupply: placeOfSupply);

  @override
  Sale subtotalMinor(int? subtotalMinor) => this(subtotalMinor: subtotalMinor);

  @override
  Sale discountTotalMinor(int? discountTotalMinor) =>
      this(discountTotalMinor: discountTotalMinor);

  @override
  Sale taxableTotalMinor(int? taxableTotalMinor) =>
      this(taxableTotalMinor: taxableTotalMinor);

  @override
  Sale taxTotalMinor(int? taxTotalMinor) => this(taxTotalMinor: taxTotalMinor);

  @override
  Sale grandTotalMinor(int? grandTotalMinor) =>
      this(grandTotalMinor: grandTotalMinor);

  @override
  Sale paidTotalMinor(int? paidTotalMinor) =>
      this(paidTotalMinor: paidTotalMinor);

  @override
  Sale dueTotalMinor(int? dueTotalMinor) => this(dueTotalMinor: dueTotalMinor);

  @override
  Sale negativeStockAcknowledged(bool? negativeStockAcknowledged) =>
      this(negativeStockAcknowledged: negativeStockAcknowledged);

  @override
  Sale negativeStockReason(String? negativeStockReason) =>
      this(negativeStockReason: negativeStockReason);

  @override
  Sale source_(String? source_) => this(source_: source_);

  @override
  Sale postedAt(DateTime postedAt) => this(postedAt: postedAt);

  @override
  Sale reversalReason(String? reversalReason) =>
      this(reversalReason: reversalReason);

  @override
  Sale reversedAt(DateTime? reversedAt) => this(reversedAt: reversedAt);

  @override
  Sale lines(List<SaleLine> lines) => this(lines: lines);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Sale(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Sale(...).copyWith(id: 12, name: "My name")
  /// ````
  Sale call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? customer = const $CopyWithPlaceholder(),
    Object? customerName = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? number = const $CopyWithPlaceholder(),
    Object? invoiceNumber = const $CopyWithPlaceholder(),
    Object? occurredAt = const $CopyWithPlaceholder(),
    Object? financialYear = const $CopyWithPlaceholder(),
    Object? documentDate = const $CopyWithPlaceholder(),
    Object? priceMode = const $CopyWithPlaceholder(),
    Object? taxInclusive = const $CopyWithPlaceholder(),
    Object? sellerName = const $CopyWithPlaceholder(),
    Object? sellerGstin = const $CopyWithPlaceholder(),
    Object? buyerName = const $CopyWithPlaceholder(),
    Object? buyerGstin = const $CopyWithPlaceholder(),
    Object? placeOfSupply = const $CopyWithPlaceholder(),
    Object? subtotalMinor = const $CopyWithPlaceholder(),
    Object? discountTotalMinor = const $CopyWithPlaceholder(),
    Object? taxableTotalMinor = const $CopyWithPlaceholder(),
    Object? taxTotalMinor = const $CopyWithPlaceholder(),
    Object? grandTotalMinor = const $CopyWithPlaceholder(),
    Object? paidTotalMinor = const $CopyWithPlaceholder(),
    Object? dueTotalMinor = const $CopyWithPlaceholder(),
    Object? negativeStockAcknowledged = const $CopyWithPlaceholder(),
    Object? negativeStockReason = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? postedAt = const $CopyWithPlaceholder(),
    Object? reversalReason = const $CopyWithPlaceholder(),
    Object? reversedAt = const $CopyWithPlaceholder(),
    Object? lines = const $CopyWithPlaceholder(),
  }) {
    return Sale(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as String,
      customer: customer == const $CopyWithPlaceholder()
          ? _value.customer
          // ignore: cast_nullable_to_non_nullable
          : customer as String?,
      customerName: customerName == const $CopyWithPlaceholder()
          ? _value.customerName
          // ignore: cast_nullable_to_non_nullable
          : customerName as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as SaleStatusEnum?,
      number: number == const $CopyWithPlaceholder()
          ? _value.number
          // ignore: cast_nullable_to_non_nullable
          : number as String,
      invoiceNumber: invoiceNumber == const $CopyWithPlaceholder()
          ? _value.invoiceNumber
          // ignore: cast_nullable_to_non_nullable
          : invoiceNumber as String,
      occurredAt: occurredAt == const $CopyWithPlaceholder()
          ? _value.occurredAt
          // ignore: cast_nullable_to_non_nullable
          : occurredAt as DateTime,
      financialYear: financialYear == const $CopyWithPlaceholder()
          ? _value.financialYear
          // ignore: cast_nullable_to_non_nullable
          : financialYear as String,
      documentDate: documentDate == const $CopyWithPlaceholder()
          ? _value.documentDate
          // ignore: cast_nullable_to_non_nullable
          : documentDate as DateTime,
      priceMode: priceMode == const $CopyWithPlaceholder()
          ? _value.priceMode
          // ignore: cast_nullable_to_non_nullable
          : priceMode as SalePriceModeEnum?,
      taxInclusive: taxInclusive == const $CopyWithPlaceholder()
          ? _value.taxInclusive
          // ignore: cast_nullable_to_non_nullable
          : taxInclusive as bool?,
      sellerName: sellerName == const $CopyWithPlaceholder()
          ? _value.sellerName
          // ignore: cast_nullable_to_non_nullable
          : sellerName as String?,
      sellerGstin: sellerGstin == const $CopyWithPlaceholder()
          ? _value.sellerGstin
          // ignore: cast_nullable_to_non_nullable
          : sellerGstin as String?,
      buyerName: buyerName == const $CopyWithPlaceholder()
          ? _value.buyerName
          // ignore: cast_nullable_to_non_nullable
          : buyerName as String?,
      buyerGstin: buyerGstin == const $CopyWithPlaceholder()
          ? _value.buyerGstin
          // ignore: cast_nullable_to_non_nullable
          : buyerGstin as String?,
      placeOfSupply: placeOfSupply == const $CopyWithPlaceholder()
          ? _value.placeOfSupply
          // ignore: cast_nullable_to_non_nullable
          : placeOfSupply as String?,
      subtotalMinor: subtotalMinor == const $CopyWithPlaceholder()
          ? _value.subtotalMinor
          // ignore: cast_nullable_to_non_nullable
          : subtotalMinor as int?,
      discountTotalMinor: discountTotalMinor == const $CopyWithPlaceholder()
          ? _value.discountTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : discountTotalMinor as int?,
      taxableTotalMinor: taxableTotalMinor == const $CopyWithPlaceholder()
          ? _value.taxableTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : taxableTotalMinor as int?,
      taxTotalMinor: taxTotalMinor == const $CopyWithPlaceholder()
          ? _value.taxTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : taxTotalMinor as int?,
      grandTotalMinor: grandTotalMinor == const $CopyWithPlaceholder()
          ? _value.grandTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : grandTotalMinor as int?,
      paidTotalMinor: paidTotalMinor == const $CopyWithPlaceholder()
          ? _value.paidTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : paidTotalMinor as int?,
      dueTotalMinor: dueTotalMinor == const $CopyWithPlaceholder()
          ? _value.dueTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : dueTotalMinor as int?,
      negativeStockAcknowledged:
          negativeStockAcknowledged == const $CopyWithPlaceholder()
          ? _value.negativeStockAcknowledged
          // ignore: cast_nullable_to_non_nullable
          : negativeStockAcknowledged as bool?,
      negativeStockReason: negativeStockReason == const $CopyWithPlaceholder()
          ? _value.negativeStockReason
          // ignore: cast_nullable_to_non_nullable
          : negativeStockReason as String?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as String?,
      postedAt: postedAt == const $CopyWithPlaceholder()
          ? _value.postedAt
          // ignore: cast_nullable_to_non_nullable
          : postedAt as DateTime,
      reversalReason: reversalReason == const $CopyWithPlaceholder()
          ? _value.reversalReason
          // ignore: cast_nullable_to_non_nullable
          : reversalReason as String?,
      reversedAt: reversedAt == const $CopyWithPlaceholder()
          ? _value.reversedAt
          // ignore: cast_nullable_to_non_nullable
          : reversedAt as DateTime?,
      lines: lines == const $CopyWithPlaceholder()
          ? _value.lines
          // ignore: cast_nullable_to_non_nullable
          : lines as List<SaleLine>,
    );
  }
}

extension $SaleCopyWith on Sale {
  /// Returns a callable class that can be used as follows: `instanceOfSale.copyWith(...)` or like so:`instanceOfSale.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaleCWProxy get copyWith => _$SaleCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sale _$SaleFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Sale',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'business',
        'location',
        'customer_name',
        'number',
        'invoice_number',
        'occurred_at',
        'financial_year',
        'document_date',
        'posted_at',
        'lines',
      ],
    );
    final val = Sale(
      id: $checkedConvert('id', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      location: $checkedConvert('location', (v) => v as String),
      customer: $checkedConvert('customer', (v) => v as String?),
      customerName: $checkedConvert('customer_name', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecodeNullable(_$SaleStatusEnumEnumMap, v),
      ),
      number: $checkedConvert('number', (v) => v as String),
      invoiceNumber: $checkedConvert('invoice_number', (v) => v as String),
      occurredAt: $checkedConvert(
        'occurred_at',
        (v) => DateTime.parse(v as String),
      ),
      financialYear: $checkedConvert('financial_year', (v) => v as String),
      documentDate: $checkedConvert(
        'document_date',
        (v) => DateTime.parse(v as String),
      ),
      priceMode: $checkedConvert(
        'price_mode',
        (v) => $enumDecodeNullable(_$SalePriceModeEnumEnumMap, v),
      ),
      taxInclusive: $checkedConvert('tax_inclusive', (v) => v as bool?),
      sellerName: $checkedConvert('seller_name', (v) => v as String?),
      sellerGstin: $checkedConvert('seller_gstin', (v) => v as String?),
      buyerName: $checkedConvert('buyer_name', (v) => v as String?),
      buyerGstin: $checkedConvert('buyer_gstin', (v) => v as String?),
      placeOfSupply: $checkedConvert('place_of_supply', (v) => v as String?),
      subtotalMinor: $checkedConvert(
        'subtotal_minor',
        (v) => (v as num?)?.toInt(),
      ),
      discountTotalMinor: $checkedConvert(
        'discount_total_minor',
        (v) => (v as num?)?.toInt(),
      ),
      taxableTotalMinor: $checkedConvert(
        'taxable_total_minor',
        (v) => (v as num?)?.toInt(),
      ),
      taxTotalMinor: $checkedConvert(
        'tax_total_minor',
        (v) => (v as num?)?.toInt(),
      ),
      grandTotalMinor: $checkedConvert(
        'grand_total_minor',
        (v) => (v as num?)?.toInt(),
      ),
      paidTotalMinor: $checkedConvert(
        'paid_total_minor',
        (v) => (v as num?)?.toInt(),
      ),
      dueTotalMinor: $checkedConvert(
        'due_total_minor',
        (v) => (v as num?)?.toInt(),
      ),
      negativeStockAcknowledged: $checkedConvert(
        'negative_stock_acknowledged',
        (v) => v as bool?,
      ),
      negativeStockReason: $checkedConvert(
        'negative_stock_reason',
        (v) => v as String?,
      ),
      source_: $checkedConvert('source', (v) => v as String?),
      postedAt: $checkedConvert(
        'posted_at',
        (v) => DateTime.parse(v as String),
      ),
      reversalReason: $checkedConvert('reversal_reason', (v) => v as String?),
      reversedAt: $checkedConvert(
        'reversed_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      lines: $checkedConvert(
        'lines',
        (v) => (v as List<dynamic>)
            .map((e) => SaleLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'customerName': 'customer_name',
    'invoiceNumber': 'invoice_number',
    'occurredAt': 'occurred_at',
    'financialYear': 'financial_year',
    'documentDate': 'document_date',
    'priceMode': 'price_mode',
    'taxInclusive': 'tax_inclusive',
    'sellerName': 'seller_name',
    'sellerGstin': 'seller_gstin',
    'buyerName': 'buyer_name',
    'buyerGstin': 'buyer_gstin',
    'placeOfSupply': 'place_of_supply',
    'subtotalMinor': 'subtotal_minor',
    'discountTotalMinor': 'discount_total_minor',
    'taxableTotalMinor': 'taxable_total_minor',
    'taxTotalMinor': 'tax_total_minor',
    'grandTotalMinor': 'grand_total_minor',
    'paidTotalMinor': 'paid_total_minor',
    'dueTotalMinor': 'due_total_minor',
    'negativeStockAcknowledged': 'negative_stock_acknowledged',
    'negativeStockReason': 'negative_stock_reason',
    'source_': 'source',
    'postedAt': 'posted_at',
    'reversalReason': 'reversal_reason',
    'reversedAt': 'reversed_at',
  },
);

Map<String, dynamic> _$SaleToJson(Sale instance) => <String, dynamic>{
  'id': instance.id,
  'business': instance.business,
  'location': instance.location,
  'customer': ?instance.customer,
  'customer_name': instance.customerName,
  'status': ?_$SaleStatusEnumEnumMap[instance.status],
  'number': instance.number,
  'invoice_number': instance.invoiceNumber,
  'occurred_at': instance.occurredAt.toIso8601String(),
  'financial_year': instance.financialYear,
  'document_date': instance.documentDate.toIso8601String(),
  'price_mode': ?_$SalePriceModeEnumEnumMap[instance.priceMode],
  'tax_inclusive': ?instance.taxInclusive,
  'seller_name': ?instance.sellerName,
  'seller_gstin': ?instance.sellerGstin,
  'buyer_name': ?instance.buyerName,
  'buyer_gstin': ?instance.buyerGstin,
  'place_of_supply': ?instance.placeOfSupply,
  'subtotal_minor': ?instance.subtotalMinor,
  'discount_total_minor': ?instance.discountTotalMinor,
  'taxable_total_minor': ?instance.taxableTotalMinor,
  'tax_total_minor': ?instance.taxTotalMinor,
  'grand_total_minor': ?instance.grandTotalMinor,
  'paid_total_minor': ?instance.paidTotalMinor,
  'due_total_minor': ?instance.dueTotalMinor,
  'negative_stock_acknowledged': ?instance.negativeStockAcknowledged,
  'negative_stock_reason': ?instance.negativeStockReason,
  'source': ?instance.source_,
  'posted_at': instance.postedAt.toIso8601String(),
  'reversal_reason': ?instance.reversalReason,
  'reversed_at': ?instance.reversedAt?.toIso8601String(),
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

const _$SaleStatusEnumEnumMap = {
  SaleStatusEnum.DRAFT: 'DRAFT',
  SaleStatusEnum.POSTED: 'POSTED',
  SaleStatusEnum.REVERSED: 'REVERSED',
};

const _$SalePriceModeEnumEnumMap = {
  SalePriceModeEnum.RETAIL: 'RETAIL',
  SalePriceModeEnum.WHOLESALE: 'WHOLESALE',
};
