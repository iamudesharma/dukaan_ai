// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PurchaseCreateCWProxy {
  PurchaseCreate businessId(String businessId);

  PurchaseCreate locationId(String locationId);

  PurchaseCreate supplierId(String supplierId);

  PurchaseCreate purchaseDate(DateTime? purchaseDate);

  PurchaseCreate supplierBillNumber(String? supplierBillNumber);

  PurchaseCreate taxInclusive(bool? taxInclusive);

  PurchaseCreate discountTotalMinor(int? discountTotalMinor);

  PurchaseCreate lines(List<PurchaseLineInput> lines);

  PurchaseCreate paidAmountMinor(int? paidAmountMinor);

  PurchaseCreate paymentMethod(PurchaseCreatePaymentMethodEnum? paymentMethod);

  PurchaseCreate paymentReference(String? paymentReference);

  PurchaseCreate idempotencyKey(String idempotencyKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PurchaseCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PurchaseCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  PurchaseCreate call({
    String businessId,
    String locationId,
    String supplierId,
    DateTime? purchaseDate,
    String? supplierBillNumber,
    bool? taxInclusive,
    int? discountTotalMinor,
    List<PurchaseLineInput> lines,
    int? paidAmountMinor,
    PurchaseCreatePaymentMethodEnum? paymentMethod,
    String? paymentReference,
    String idempotencyKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPurchaseCreate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPurchaseCreate.copyWith.fieldName(...)`
class _$PurchaseCreateCWProxyImpl implements _$PurchaseCreateCWProxy {
  const _$PurchaseCreateCWProxyImpl(this._value);

  final PurchaseCreate _value;

  @override
  PurchaseCreate businessId(String businessId) => this(businessId: businessId);

  @override
  PurchaseCreate locationId(String locationId) => this(locationId: locationId);

  @override
  PurchaseCreate supplierId(String supplierId) => this(supplierId: supplierId);

  @override
  PurchaseCreate purchaseDate(DateTime? purchaseDate) =>
      this(purchaseDate: purchaseDate);

  @override
  PurchaseCreate supplierBillNumber(String? supplierBillNumber) =>
      this(supplierBillNumber: supplierBillNumber);

  @override
  PurchaseCreate taxInclusive(bool? taxInclusive) =>
      this(taxInclusive: taxInclusive);

  @override
  PurchaseCreate discountTotalMinor(int? discountTotalMinor) =>
      this(discountTotalMinor: discountTotalMinor);

  @override
  PurchaseCreate lines(List<PurchaseLineInput> lines) => this(lines: lines);

  @override
  PurchaseCreate paidAmountMinor(int? paidAmountMinor) =>
      this(paidAmountMinor: paidAmountMinor);

  @override
  PurchaseCreate paymentMethod(
    PurchaseCreatePaymentMethodEnum? paymentMethod,
  ) => this(paymentMethod: paymentMethod);

  @override
  PurchaseCreate paymentReference(String? paymentReference) =>
      this(paymentReference: paymentReference);

  @override
  PurchaseCreate idempotencyKey(String idempotencyKey) =>
      this(idempotencyKey: idempotencyKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PurchaseCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PurchaseCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  PurchaseCreate call({
    Object? businessId = const $CopyWithPlaceholder(),
    Object? locationId = const $CopyWithPlaceholder(),
    Object? supplierId = const $CopyWithPlaceholder(),
    Object? purchaseDate = const $CopyWithPlaceholder(),
    Object? supplierBillNumber = const $CopyWithPlaceholder(),
    Object? taxInclusive = const $CopyWithPlaceholder(),
    Object? discountTotalMinor = const $CopyWithPlaceholder(),
    Object? lines = const $CopyWithPlaceholder(),
    Object? paidAmountMinor = const $CopyWithPlaceholder(),
    Object? paymentMethod = const $CopyWithPlaceholder(),
    Object? paymentReference = const $CopyWithPlaceholder(),
    Object? idempotencyKey = const $CopyWithPlaceholder(),
  }) {
    return PurchaseCreate(
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      locationId: locationId == const $CopyWithPlaceholder()
          ? _value.locationId
          // ignore: cast_nullable_to_non_nullable
          : locationId as String,
      supplierId: supplierId == const $CopyWithPlaceholder()
          ? _value.supplierId
          // ignore: cast_nullable_to_non_nullable
          : supplierId as String,
      purchaseDate: purchaseDate == const $CopyWithPlaceholder()
          ? _value.purchaseDate
          // ignore: cast_nullable_to_non_nullable
          : purchaseDate as DateTime?,
      supplierBillNumber: supplierBillNumber == const $CopyWithPlaceholder()
          ? _value.supplierBillNumber
          // ignore: cast_nullable_to_non_nullable
          : supplierBillNumber as String?,
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
          : lines as List<PurchaseLineInput>,
      paidAmountMinor: paidAmountMinor == const $CopyWithPlaceholder()
          ? _value.paidAmountMinor
          // ignore: cast_nullable_to_non_nullable
          : paidAmountMinor as int?,
      paymentMethod: paymentMethod == const $CopyWithPlaceholder()
          ? _value.paymentMethod
          // ignore: cast_nullable_to_non_nullable
          : paymentMethod as PurchaseCreatePaymentMethodEnum?,
      paymentReference: paymentReference == const $CopyWithPlaceholder()
          ? _value.paymentReference
          // ignore: cast_nullable_to_non_nullable
          : paymentReference as String?,
      idempotencyKey: idempotencyKey == const $CopyWithPlaceholder()
          ? _value.idempotencyKey
          // ignore: cast_nullable_to_non_nullable
          : idempotencyKey as String,
    );
  }
}

extension $PurchaseCreateCopyWith on PurchaseCreate {
  /// Returns a callable class that can be used as follows: `instanceOfPurchaseCreate.copyWith(...)` or like so:`instanceOfPurchaseCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PurchaseCreateCWProxy get copyWith => _$PurchaseCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseCreate _$PurchaseCreateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PurchaseCreate',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'business_id',
        'location_id',
        'supplier_id',
        'lines',
        'idempotency_key',
      ],
    );
    final val = PurchaseCreate(
      businessId: $checkedConvert('business_id', (v) => v as String),
      locationId: $checkedConvert('location_id', (v) => v as String),
      supplierId: $checkedConvert('supplier_id', (v) => v as String),
      purchaseDate: $checkedConvert(
        'purchase_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      supplierBillNumber: $checkedConvert(
        'supplier_bill_number',
        (v) => v as String?,
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
            .map((e) => PurchaseLineInput.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      paidAmountMinor: $checkedConvert(
        'paid_amount_minor',
        (v) => (v as num?)?.toInt() ?? 0,
      ),
      paymentMethod: $checkedConvert(
        'payment_method',
        (v) =>
            $enumDecodeNullable(_$PurchaseCreatePaymentMethodEnumEnumMap, v) ??
            'CASH',
      ),
      paymentReference: $checkedConvert(
        'payment_reference',
        (v) => v as String?,
      ),
      idempotencyKey: $checkedConvert('idempotency_key', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'businessId': 'business_id',
    'locationId': 'location_id',
    'supplierId': 'supplier_id',
    'purchaseDate': 'purchase_date',
    'supplierBillNumber': 'supplier_bill_number',
    'taxInclusive': 'tax_inclusive',
    'discountTotalMinor': 'discount_total_minor',
    'paidAmountMinor': 'paid_amount_minor',
    'paymentMethod': 'payment_method',
    'paymentReference': 'payment_reference',
    'idempotencyKey': 'idempotency_key',
  },
);

Map<String, dynamic> _$PurchaseCreateToJson(PurchaseCreate instance) =>
    <String, dynamic>{
      'business_id': instance.businessId,
      'location_id': instance.locationId,
      'supplier_id': instance.supplierId,
      'purchase_date': ?instance.purchaseDate?.toIso8601String(),
      'supplier_bill_number': ?instance.supplierBillNumber,
      'tax_inclusive': ?instance.taxInclusive,
      'discount_total_minor': ?instance.discountTotalMinor,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'paid_amount_minor': ?instance.paidAmountMinor,
      'payment_method':
          ?_$PurchaseCreatePaymentMethodEnumEnumMap[instance.paymentMethod],
      'payment_reference': ?instance.paymentReference,
      'idempotency_key': instance.idempotencyKey,
    };

const _$PurchaseCreatePaymentMethodEnumEnumMap = {
  PurchaseCreatePaymentMethodEnum.CASH: 'CASH',
  PurchaseCreatePaymentMethodEnum.UPI: 'UPI',
  PurchaseCreatePaymentMethodEnum.CARD: 'CARD',
  PurchaseCreatePaymentMethodEnum.BANK: 'BANK',
  PurchaseCreatePaymentMethodEnum.OTHER: 'OTHER',
};
