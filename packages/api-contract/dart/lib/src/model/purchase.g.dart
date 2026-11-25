// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PurchaseCWProxy {
  Purchase id(String id);

  Purchase business(String business);

  Purchase location(String location);

  Purchase supplier(String supplier);

  Purchase supplierName(String supplierName);

  Purchase status(PurchaseStatusEnum? status);

  Purchase number(String number);

  Purchase invoiceNumber(String invoiceNumber);

  Purchase occurredAt(DateTime occurredAt);

  Purchase financialYear(String financialYear);

  Purchase documentDate(DateTime documentDate);

  Purchase supplierBillNumber(String? supplierBillNumber);

  Purchase taxInclusive(bool? taxInclusive);

  Purchase sellerName(String? sellerName);

  Purchase sellerGstin(String? sellerGstin);

  Purchase buyerName(String? buyerName);

  Purchase buyerGstin(String? buyerGstin);

  Purchase placeOfSupply(String? placeOfSupply);

  Purchase subtotalMinor(int? subtotalMinor);

  Purchase discountTotalMinor(int? discountTotalMinor);

  Purchase taxableTotalMinor(int? taxableTotalMinor);

  Purchase taxTotalMinor(int? taxTotalMinor);

  Purchase grandTotalMinor(int? grandTotalMinor);

  Purchase paidTotalMinor(int? paidTotalMinor);

  Purchase dueTotalMinor(int? dueTotalMinor);

  Purchase source_(String? source_);

  Purchase postedAt(DateTime postedAt);

  Purchase reversalReason(String? reversalReason);

  Purchase reversedAt(DateTime? reversedAt);

  Purchase lines(List<PurchaseLine> lines);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Purchase(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Purchase(...).copyWith(id: 12, name: "My name")
  /// ````
  Purchase call({
    String id,
    String business,
    String location,
    String supplier,
    String supplierName,
    PurchaseStatusEnum? status,
    String number,
    String invoiceNumber,
    DateTime occurredAt,
    String financialYear,
    DateTime documentDate,
    String? supplierBillNumber,
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
    String? source_,
    DateTime postedAt,
    String? reversalReason,
    DateTime? reversedAt,
    List<PurchaseLine> lines,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPurchase.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPurchase.copyWith.fieldName(...)`
class _$PurchaseCWProxyImpl implements _$PurchaseCWProxy {
  const _$PurchaseCWProxyImpl(this._value);

  final Purchase _value;

  @override
  Purchase id(String id) => this(id: id);

  @override
  Purchase business(String business) => this(business: business);

  @override
  Purchase location(String location) => this(location: location);

  @override
  Purchase supplier(String supplier) => this(supplier: supplier);

  @override
  Purchase supplierName(String supplierName) =>
      this(supplierName: supplierName);

  @override
  Purchase status(PurchaseStatusEnum? status) => this(status: status);

  @override
  Purchase number(String number) => this(number: number);

  @override
  Purchase invoiceNumber(String invoiceNumber) =>
      this(invoiceNumber: invoiceNumber);

  @override
  Purchase occurredAt(DateTime occurredAt) => this(occurredAt: occurredAt);

  @override
  Purchase financialYear(String financialYear) =>
      this(financialYear: financialYear);

  @override
  Purchase documentDate(DateTime documentDate) =>
      this(documentDate: documentDate);

  @override
  Purchase supplierBillNumber(String? supplierBillNumber) =>
      this(supplierBillNumber: supplierBillNumber);

  @override
  Purchase taxInclusive(bool? taxInclusive) => this(taxInclusive: taxInclusive);

  @override
  Purchase sellerName(String? sellerName) => this(sellerName: sellerName);

  @override
  Purchase sellerGstin(String? sellerGstin) => this(sellerGstin: sellerGstin);

  @override
  Purchase buyerName(String? buyerName) => this(buyerName: buyerName);

  @override
  Purchase buyerGstin(String? buyerGstin) => this(buyerGstin: buyerGstin);

  @override
  Purchase placeOfSupply(String? placeOfSupply) =>
      this(placeOfSupply: placeOfSupply);

  @override
  Purchase subtotalMinor(int? subtotalMinor) =>
      this(subtotalMinor: subtotalMinor);

  @override
  Purchase discountTotalMinor(int? discountTotalMinor) =>
      this(discountTotalMinor: discountTotalMinor);

  @override
  Purchase taxableTotalMinor(int? taxableTotalMinor) =>
      this(taxableTotalMinor: taxableTotalMinor);

  @override
  Purchase taxTotalMinor(int? taxTotalMinor) =>
      this(taxTotalMinor: taxTotalMinor);

  @override
  Purchase grandTotalMinor(int? grandTotalMinor) =>
      this(grandTotalMinor: grandTotalMinor);

  @override
  Purchase paidTotalMinor(int? paidTotalMinor) =>
      this(paidTotalMinor: paidTotalMinor);

  @override
  Purchase dueTotalMinor(int? dueTotalMinor) =>
      this(dueTotalMinor: dueTotalMinor);

  @override
  Purchase source_(String? source_) => this(source_: source_);

  @override
  Purchase postedAt(DateTime postedAt) => this(postedAt: postedAt);

  @override
  Purchase reversalReason(String? reversalReason) =>
      this(reversalReason: reversalReason);

  @override
  Purchase reversedAt(DateTime? reversedAt) => this(reversedAt: reversedAt);

  @override
  Purchase lines(List<PurchaseLine> lines) => this(lines: lines);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Purchase(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Purchase(...).copyWith(id: 12, name: "My name")
  /// ````
  Purchase call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? supplier = const $CopyWithPlaceholder(),
    Object? supplierName = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? number = const $CopyWithPlaceholder(),
    Object? invoiceNumber = const $CopyWithPlaceholder(),
    Object? occurredAt = const $CopyWithPlaceholder(),
    Object? financialYear = const $CopyWithPlaceholder(),
    Object? documentDate = const $CopyWithPlaceholder(),
    Object? supplierBillNumber = const $CopyWithPlaceholder(),
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
    Object? source_ = const $CopyWithPlaceholder(),
    Object? postedAt = const $CopyWithPlaceholder(),
    Object? reversalReason = const $CopyWithPlaceholder(),
    Object? reversedAt = const $CopyWithPlaceholder(),
    Object? lines = const $CopyWithPlaceholder(),
  }) {
    return Purchase(
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
      supplier: supplier == const $CopyWithPlaceholder()
          ? _value.supplier
          // ignore: cast_nullable_to_non_nullable
          : supplier as String,
      supplierName: supplierName == const $CopyWithPlaceholder()
          ? _value.supplierName
          // ignore: cast_nullable_to_non_nullable
          : supplierName as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as PurchaseStatusEnum?,
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
      supplierBillNumber: supplierBillNumber == const $CopyWithPlaceholder()
          ? _value.supplierBillNumber
          // ignore: cast_nullable_to_non_nullable
          : supplierBillNumber as String?,
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
          : lines as List<PurchaseLine>,
    );
  }
}

extension $PurchaseCopyWith on Purchase {
  /// Returns a callable class that can be used as follows: `instanceOfPurchase.copyWith(...)` or like so:`instanceOfPurchase.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PurchaseCWProxy get copyWith => _$PurchaseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Purchase _$PurchaseFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Purchase',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'business',
        'location',
        'supplier',
        'supplier_name',
        'number',
        'invoice_number',
        'occurred_at',
        'financial_year',
        'document_date',
        'posted_at',
        'lines',
      ],
    );
    final val = Purchase(
      id: $checkedConvert('id', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      location: $checkedConvert('location', (v) => v as String),
      supplier: $checkedConvert('supplier', (v) => v as String),
      supplierName: $checkedConvert('supplier_name', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecodeNullable(_$PurchaseStatusEnumEnumMap, v),
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
      supplierBillNumber: $checkedConvert(
        'supplier_bill_number',
        (v) => v as String?,
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
            .map((e) => PurchaseLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'supplierName': 'supplier_name',
    'invoiceNumber': 'invoice_number',
    'occurredAt': 'occurred_at',
    'financialYear': 'financial_year',
    'documentDate': 'document_date',
    'supplierBillNumber': 'supplier_bill_number',
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
    'source_': 'source',
    'postedAt': 'posted_at',
    'reversalReason': 'reversal_reason',
    'reversedAt': 'reversed_at',
  },
);

Map<String, dynamic> _$PurchaseToJson(Purchase instance) => <String, dynamic>{
  'id': instance.id,
  'business': instance.business,
  'location': instance.location,
  'supplier': instance.supplier,
  'supplier_name': instance.supplierName,
  'status': ?_$PurchaseStatusEnumEnumMap[instance.status],
  'number': instance.number,
  'invoice_number': instance.invoiceNumber,
  'occurred_at': instance.occurredAt.toIso8601String(),
  'financial_year': instance.financialYear,
  'document_date': instance.documentDate.toIso8601String(),
  'supplier_bill_number': ?instance.supplierBillNumber,
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
  'source': ?instance.source_,
  'posted_at': instance.postedAt.toIso8601String(),
  'reversal_reason': ?instance.reversalReason,
  'reversed_at': ?instance.reversedAt?.toIso8601String(),
  'lines': instance.lines.map((e) => e.toJson()).toList(),
};

const _$PurchaseStatusEnumEnumMap = {
  PurchaseStatusEnum.DRAFT: 'DRAFT',
  PurchaseStatusEnum.POSTED: 'POSTED',
  PurchaseStatusEnum.REVERSED: 'REVERSED',
};
