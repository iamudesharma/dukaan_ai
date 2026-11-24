// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaleCreateCWProxy {
  SaleCreate businessId(String businessId);

  SaleCreate locationId(String locationId);

  SaleCreate customerId(String? customerId);

  SaleCreate invoiceDate(DateTime? invoiceDate);

  SaleCreate priceMode(SaleCreatePriceModeEnum? priceMode);

  SaleCreate taxInclusive(bool? taxInclusive);

  SaleCreate discountTotalMinor(int? discountTotalMinor);

  SaleCreate lines(List<SaleLineInput> lines);

  SaleCreate paidAmountMinor(int? paidAmountMinor);

  SaleCreate paymentMethod(SaleCreatePaymentMethodEnum? paymentMethod);

  SaleCreate paymentReference(String? paymentReference);

  SaleCreate negativeStockAcknowledged(bool? negativeStockAcknowledged);

  SaleCreate negativeStockReason(String? negativeStockReason);

  SaleCreate idempotencyKey(String idempotencyKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaleCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaleCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  SaleCreate call({
    String businessId,
    String locationId,
    String? customerId,
    DateTime? invoiceDate,
    SaleCreatePriceModeEnum? priceMode,
    bool? taxInclusive,
    int? discountTotalMinor,
    List<SaleLineInput> lines,
    int? paidAmountMinor,
    SaleCreatePaymentMethodEnum? paymentMethod,
    String? paymentReference,
    bool? negativeStockAcknowledged,
    String? negativeStockReason,
    String idempotencyKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSaleCreate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSaleCreate.copyWith.fieldName(...)`
class _$SaleCreateCWProxyImpl implements _$SaleCreateCWProxy {
  const _$SaleCreateCWProxyImpl(this._value);

  final SaleCreate _value;

  @override
  SaleCreate businessId(String businessId) => this(businessId: businessId);

  @override
  SaleCreate locationId(String locationId) => this(locationId: locationId);

  @override
  SaleCreate customerId(String? customerId) => this(customerId: customerId);

  @override
  SaleCreate invoiceDate(DateTime? invoiceDate) =>
      this(invoiceDate: invoiceDate);

  @override
  SaleCreate priceMode(SaleCreatePriceModeEnum? priceMode) =>
      this(priceMode: priceMode);

  @override
  SaleCreate taxInclusive(bool? taxInclusive) =>
      this(taxInclusive: taxInclusive);

  @override
  SaleCreate discountTotalMinor(int? discountTotalMinor) =>
      this(discountTotalMinor: discountTotalMinor);

  @override
  SaleCreate lines(List<SaleLineInput> lines) => this(lines: lines);

  @override
  SaleCreate paidAmountMinor(int? paidAmountMinor) =>
      this(paidAmountMinor: paidAmountMinor);

  @override
  SaleCreate paymentMethod(SaleCreatePaymentMethodEnum? paymentMethod) =>
      this(paymentMethod: paymentMethod);

  @override
  SaleCreate paymentReference(String? paymentReference) =>
      this(paymentReference: paymentReference);

  @override
  SaleCreate negativeStockAcknowledged(bool? negativeStockAcknowledged) =>
      this(negativeStockAcknowledged: negativeStockAcknowledged);

  @override
  SaleCreate negativeStockReason(String? negativeStockReason) =>
      this(negativeStockReason: negativeStockReason);

  @override
  SaleCreate idempotencyKey(String idempotencyKey) =>
      this(idempotencyKey: idempotencyKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaleCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaleCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  SaleCreate call({
    Object? businessId = const $CopyWithPlaceholder(),
    Object? locationId = const $CopyWithPlaceholder(),
    Object? customerId = const $CopyWithPlaceholder(),
    Object? invoiceDate = const $CopyWithPlaceholder(),
    Object? priceMode = const $CopyWithPlaceholder(),
    Object? taxInclusive = const $CopyWithPlaceholder(),
    Object? discountTotalMinor = const $CopyWithPlaceholder(),
    Object? lines = const $CopyWithPlaceholder(),
    Object? paidAmountMinor = const $CopyWithPlaceholder(),
    Object? paymentMethod = const $CopyWithPlaceholder(),
    Object? paymentReference = const $CopyWithPlaceholder(),
    Object? negativeStockAcknowledged = const $CopyWithPlaceholder(),
    Object? negativeStockReason = const $CopyWithPlaceholder(),
    Object? idempotencyKey = const $CopyWithPlaceholder(),
  }) {
    return SaleCreate(
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      locationId: locationId == const $CopyWithPlaceholder()
          ? _value.locationId
          // ignore: cast_nullable_to_non_nullable
          : locationId as String,
      customerId: customerId == const $CopyWithPlaceholder()
          ? _value.customerId
          // ignore: cast_nullable_to_non_nullable
          : customerId as String?,
      invoiceDate: invoiceDate == const $CopyWithPlaceholder()
          ? _value.invoiceDate
          // ignore: cast_nullable_to_non_nullable
          : invoiceDate as DateTime?,
      priceMode: priceMode == const $CopyWithPlaceholder()
          ? _value.priceMode
          // ignore: cast_nullable_to_non_nullable
          : priceMode as SaleCreatePriceModeEnum?,
      taxInclusive: taxInclusive == const $CopyWithPlaceholder()
          ? _value.taxInclusive
          // ignore: cast_nullable_to_non_nullable
          : taxInclusive as bool?,
      discountTotalMinor: discountTotalMinor == const $CopyWithPlaceholder()
          ? _value.discountTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : discountTotalMinor as int?,
      lines: lines == const $CopyWithPlaceholder()
          ? _value.lines
          // ignore: cast_nullable_to_non_nullable
          : lines as List<SaleLineInput>,
      paidAmountMinor: paidAmountMinor == const $CopyWithPlaceholder()
          ? _value.paidAmountMinor
          // ignore: cast_nullable_to_non_nullable
          : paidAmountMinor as int?,
      paymentMethod: paymentMethod == const $CopyWithPlaceholder()
          ? _value.paymentMethod
          // ignore: cast_nullable_to_non_nullable
          : paymentMethod as SaleCreatePaymentMethodEnum?,
      paymentReference: paymentReference == const $CopyWithPlaceholder()
          ? _value.paymentReference
          // ignore: cast_nullable_to_non_nullable
          : paymentReference as String?,
      negativeStockAcknowledged:
          negativeStockAcknowledged == const $CopyWithPlaceholder()
          ? _value.negativeStockAcknowledged
          // ignore: cast_nullable_to_non_nullable
          : negativeStockAcknowledged as bool?,
      negativeStockReason: negativeStockReason == const $CopyWithPlaceholder()
          ? _value.negativeStockReason
          // ignore: cast_nullable_to_non_nullable
          : negativeStockReason as String?,
      idempotencyKey: idempotencyKey == const $CopyWithPlaceholder()
          ? _value.idempotencyKey
          // ignore: cast_nullable_to_non_nullable
          : idempotencyKey as String,
    );
  }
}

extension $SaleCreateCopyWith on SaleCreate {
  /// Returns a callable class that can be used as follows: `instanceOfSaleCreate.copyWith(...)` or like so:`instanceOfSaleCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaleCreateCWProxy get copyWith => _$SaleCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaleCreate _$SaleCreateFromJson(Map<String, dynamic> json) => $checkedCreate(
  'SaleCreate',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'business_id',
        'location_id',
        'lines',
        'idempotency_key',
      ],
    );
    final val = SaleCreate(
      businessId: $checkedConvert('business_id', (v) => v as String),
      locationId: $checkedConvert('location_id', (v) => v as String),
      customerId: $checkedConvert('customer_id', (v) => v as String?),
      invoiceDate: $checkedConvert(
        'invoice_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      priceMode: $checkedConvert(
        'price_mode',
        (v) =>
            $enumDecodeNullable(_$SaleCreatePriceModeEnumEnumMap, v) ??
            'RETAIL',
      ),
      taxInclusive: $checkedConvert(
        'tax_inclusive',
        (v) => v as bool? ?? false,
      ),
      discountTotalMinor: $checkedConvert(
        'discount_total_minor',
        (v) => (v as num?)?.toInt() ?? 0,
      ),
      lines: $checkedConvert(
        'lines',
        (v) => (v as List<dynamic>)
            .map((e) => SaleLineInput.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      paidAmountMinor: $checkedConvert(
        'paid_amount_minor',
        (v) => (v as num?)?.toInt() ?? 0,
      ),
      paymentMethod: $checkedConvert(
        'payment_method',
        (v) =>
            $enumDecodeNullable(_$SaleCreatePaymentMethodEnumEnumMap, v) ??
            'CASH',
      ),
      paymentReference: $checkedConvert(
        'payment_reference',
        (v) => v as String?,
      ),
      negativeStockAcknowledged: $checkedConvert(
        'negative_stock_acknowledged',
        (v) => v as bool? ?? false,
      ),
      negativeStockReason: $checkedConvert(
        'negative_stock_reason',
        (v) => v as String?,
      ),
      idempotencyKey: $checkedConvert('idempotency_key', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'businessId': 'business_id',
    'locationId': 'location_id',
    'customerId': 'customer_id',
    'invoiceDate': 'invoice_date',
    'priceMode': 'price_mode',
    'taxInclusive': 'tax_inclusive',
    'discountTotalMinor': 'discount_total_minor',
    'paidAmountMinor': 'paid_amount_minor',
    'paymentMethod': 'payment_method',
    'paymentReference': 'payment_reference',
    'negativeStockAcknowledged': 'negative_stock_acknowledged',
    'negativeStockReason': 'negative_stock_reason',
    'idempotencyKey': 'idempotency_key',
  },
);

Map<String, dynamic> _$SaleCreateToJson(SaleCreate instance) =>
    <String, dynamic>{
      'business_id': instance.businessId,
      'location_id': instance.locationId,
      'customer_id': ?instance.customerId,
      'invoice_date': ?instance.invoiceDate?.toIso8601String(),
      'price_mode': ?_$SaleCreatePriceModeEnumEnumMap[instance.priceMode],
      'tax_inclusive': ?instance.taxInclusive,
      'discount_total_minor': ?instance.discountTotalMinor,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'paid_amount_minor': ?instance.paidAmountMinor,
      'payment_method':
          ?_$SaleCreatePaymentMethodEnumEnumMap[instance.paymentMethod],
      'payment_reference': ?instance.paymentReference,
      'negative_stock_acknowledged': ?instance.negativeStockAcknowledged,
      'negative_stock_reason': ?instance.negativeStockReason,
      'idempotency_key': instance.idempotencyKey,
    };

const _$SaleCreatePriceModeEnumEnumMap = {
  SaleCreatePriceModeEnum.RETAIL: 'RETAIL',
  SaleCreatePriceModeEnum.WHOLESALE: 'WHOLESALE',
};

const _$SaleCreatePaymentMethodEnumEnumMap = {
  SaleCreatePaymentMethodEnum.CASH: 'CASH',
  SaleCreatePaymentMethodEnum.UPI: 'UPI',
  SaleCreatePaymentMethodEnum.CARD: 'CARD',
  SaleCreatePaymentMethodEnum.BANK: 'BANK',
  SaleCreatePaymentMethodEnum.OTHER: 'OTHER',
};
