// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaymentCreateCWProxy {
  PaymentCreate businessId(String businessId);

  PaymentCreate locationId(String locationId);

  PaymentCreate partyId(String partyId);

  PaymentCreate direction(PaymentCreateDirectionEnum direction);

  PaymentCreate method(PaymentCreateMethodEnum method);

  PaymentCreate amountMinor(int amountMinor);

  PaymentCreate saleId(String? saleId);

  PaymentCreate purchaseId(String? purchaseId);

  PaymentCreate paymentDate(DateTime? paymentDate);

  PaymentCreate reference(String? reference);

  PaymentCreate note(String? note);

  PaymentCreate idempotencyKey(String idempotencyKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentCreate call({
    String businessId,
    String locationId,
    String partyId,
    PaymentCreateDirectionEnum direction,
    PaymentCreateMethodEnum method,
    int amountMinor,
    String? saleId,
    String? purchaseId,
    DateTime? paymentDate,
    String? reference,
    String? note,
    String idempotencyKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaymentCreate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaymentCreate.copyWith.fieldName(...)`
class _$PaymentCreateCWProxyImpl implements _$PaymentCreateCWProxy {
  const _$PaymentCreateCWProxyImpl(this._value);

  final PaymentCreate _value;

  @override
  PaymentCreate businessId(String businessId) => this(businessId: businessId);

  @override
  PaymentCreate locationId(String locationId) => this(locationId: locationId);

  @override
  PaymentCreate partyId(String partyId) => this(partyId: partyId);

  @override
  PaymentCreate direction(PaymentCreateDirectionEnum direction) =>
      this(direction: direction);

  @override
  PaymentCreate method(PaymentCreateMethodEnum method) => this(method: method);

  @override
  PaymentCreate amountMinor(int amountMinor) => this(amountMinor: amountMinor);

  @override
  PaymentCreate saleId(String? saleId) => this(saleId: saleId);

  @override
  PaymentCreate purchaseId(String? purchaseId) => this(purchaseId: purchaseId);

  @override
  PaymentCreate paymentDate(DateTime? paymentDate) =>
      this(paymentDate: paymentDate);

  @override
  PaymentCreate reference(String? reference) => this(reference: reference);

  @override
  PaymentCreate note(String? note) => this(note: note);

  @override
  PaymentCreate idempotencyKey(String idempotencyKey) =>
      this(idempotencyKey: idempotencyKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentCreate call({
    Object? businessId = const $CopyWithPlaceholder(),
    Object? locationId = const $CopyWithPlaceholder(),
    Object? partyId = const $CopyWithPlaceholder(),
    Object? direction = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
    Object? amountMinor = const $CopyWithPlaceholder(),
    Object? saleId = const $CopyWithPlaceholder(),
    Object? purchaseId = const $CopyWithPlaceholder(),
    Object? paymentDate = const $CopyWithPlaceholder(),
    Object? reference = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? idempotencyKey = const $CopyWithPlaceholder(),
  }) {
    return PaymentCreate(
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      locationId: locationId == const $CopyWithPlaceholder()
          ? _value.locationId
          // ignore: cast_nullable_to_non_nullable
          : locationId as String,
      partyId: partyId == const $CopyWithPlaceholder()
          ? _value.partyId
          // ignore: cast_nullable_to_non_nullable
          : partyId as String,
      direction: direction == const $CopyWithPlaceholder()
          ? _value.direction
          // ignore: cast_nullable_to_non_nullable
          : direction as PaymentCreateDirectionEnum,
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as PaymentCreateMethodEnum,
      amountMinor: amountMinor == const $CopyWithPlaceholder()
          ? _value.amountMinor
          // ignore: cast_nullable_to_non_nullable
          : amountMinor as int,
      saleId: saleId == const $CopyWithPlaceholder()
          ? _value.saleId
          // ignore: cast_nullable_to_non_nullable
          : saleId as String?,
      purchaseId: purchaseId == const $CopyWithPlaceholder()
          ? _value.purchaseId
          // ignore: cast_nullable_to_non_nullable
          : purchaseId as String?,
      paymentDate: paymentDate == const $CopyWithPlaceholder()
          ? _value.paymentDate
          // ignore: cast_nullable_to_non_nullable
          : paymentDate as DateTime?,
      reference: reference == const $CopyWithPlaceholder()
          ? _value.reference
          // ignore: cast_nullable_to_non_nullable
          : reference as String?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      idempotencyKey: idempotencyKey == const $CopyWithPlaceholder()
          ? _value.idempotencyKey
          // ignore: cast_nullable_to_non_nullable
          : idempotencyKey as String,
    );
  }
}

extension $PaymentCreateCopyWith on PaymentCreate {
  /// Returns a callable class that can be used as follows: `instanceOfPaymentCreate.copyWith(...)` or like so:`instanceOfPaymentCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaymentCreateCWProxy get copyWith => _$PaymentCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentCreate _$PaymentCreateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PaymentCreate',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'business_id',
        'location_id',
        'party_id',
        'direction',
        'method',
        'amount_minor',
        'idempotency_key',
      ],
    );
    final val = PaymentCreate(
      businessId: $checkedConvert('business_id', (v) => v as String),
      locationId: $checkedConvert('location_id', (v) => v as String),
      partyId: $checkedConvert('party_id', (v) => v as String),
      direction: $checkedConvert(
        'direction',
        (v) => $enumDecode(_$PaymentCreateDirectionEnumEnumMap, v),
      ),
      method: $checkedConvert(
        'method',
        (v) => $enumDecode(_$PaymentCreateMethodEnumEnumMap, v),
      ),
      amountMinor: $checkedConvert('amount_minor', (v) => (v as num).toInt()),
      saleId: $checkedConvert('sale_id', (v) => v as String?),
      purchaseId: $checkedConvert('purchase_id', (v) => v as String?),
      paymentDate: $checkedConvert(
        'payment_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      reference: $checkedConvert('reference', (v) => v as String?),
      note: $checkedConvert('note', (v) => v as String?),
      idempotencyKey: $checkedConvert('idempotency_key', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'businessId': 'business_id',
    'locationId': 'location_id',
    'partyId': 'party_id',
    'amountMinor': 'amount_minor',
    'saleId': 'sale_id',
    'purchaseId': 'purchase_id',
    'paymentDate': 'payment_date',
    'idempotencyKey': 'idempotency_key',
  },
);

Map<String, dynamic> _$PaymentCreateToJson(PaymentCreate instance) =>
    <String, dynamic>{
      'business_id': instance.businessId,
      'location_id': instance.locationId,
      'party_id': instance.partyId,
      'direction': _$PaymentCreateDirectionEnumEnumMap[instance.direction]!,
      'method': _$PaymentCreateMethodEnumEnumMap[instance.method]!,
      'amount_minor': instance.amountMinor,
      'sale_id': ?instance.saleId,
      'purchase_id': ?instance.purchaseId,
      'payment_date': ?instance.paymentDate?.toIso8601String(),
      'reference': ?instance.reference,
      'note': ?instance.note,
      'idempotency_key': instance.idempotencyKey,
    };

const _$PaymentCreateDirectionEnumEnumMap = {
  PaymentCreateDirectionEnum.RECEIPT: 'RECEIPT',
  PaymentCreateDirectionEnum.PAYMENT: 'PAYMENT',
};

const _$PaymentCreateMethodEnumEnumMap = {
  PaymentCreateMethodEnum.CASH: 'CASH',
  PaymentCreateMethodEnum.UPI: 'UPI',
  PaymentCreateMethodEnum.CARD: 'CARD',
  PaymentCreateMethodEnum.BANK: 'BANK',
  PaymentCreateMethodEnum.OTHER: 'OTHER',
};
