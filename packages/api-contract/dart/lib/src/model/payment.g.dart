// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaymentCWProxy {
  Payment id(String id);

  Payment business(String business);

  Payment location(String location);

  Payment party(String? party);

  Payment direction(PaymentDirectionEnum direction);

  Payment method(PaymentMethodEnum method);

  Payment amountMinor(int amountMinor);

  Payment reference(String? reference);

  Payment note(String? note);

  Payment paymentDate(DateTime paymentDate);

  Payment status(PaymentStatusEnum? status);

  Payment source_(String? source_);

  Payment reversalReason(String? reversalReason);

  Payment reversedAt(DateTime? reversedAt);

  Payment allocations(List<PaymentAllocation> allocations);

  Payment allocatedTotalMinor(int allocatedTotalMinor);

  Payment unallocatedTotalMinor(int unallocatedTotalMinor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Payment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Payment(...).copyWith(id: 12, name: "My name")
  /// ````
  Payment call({
    String id,
    String business,
    String location,
    String? party,
    PaymentDirectionEnum direction,
    PaymentMethodEnum method,
    int amountMinor,
    String? reference,
    String? note,
    DateTime paymentDate,
    PaymentStatusEnum? status,
    String? source_,
    String? reversalReason,
    DateTime? reversedAt,
    List<PaymentAllocation> allocations,
    int allocatedTotalMinor,
    int unallocatedTotalMinor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPayment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPayment.copyWith.fieldName(...)`
class _$PaymentCWProxyImpl implements _$PaymentCWProxy {
  const _$PaymentCWProxyImpl(this._value);

  final Payment _value;

  @override
  Payment id(String id) => this(id: id);

  @override
  Payment business(String business) => this(business: business);

  @override
  Payment location(String location) => this(location: location);

  @override
  Payment party(String? party) => this(party: party);

  @override
  Payment direction(PaymentDirectionEnum direction) =>
      this(direction: direction);

  @override
  Payment method(PaymentMethodEnum method) => this(method: method);

  @override
  Payment amountMinor(int amountMinor) => this(amountMinor: amountMinor);

  @override
  Payment reference(String? reference) => this(reference: reference);

  @override
  Payment note(String? note) => this(note: note);

  @override
  Payment paymentDate(DateTime paymentDate) => this(paymentDate: paymentDate);

  @override
  Payment status(PaymentStatusEnum? status) => this(status: status);

  @override
  Payment source_(String? source_) => this(source_: source_);

  @override
  Payment reversalReason(String? reversalReason) =>
      this(reversalReason: reversalReason);

  @override
  Payment reversedAt(DateTime? reversedAt) => this(reversedAt: reversedAt);

  @override
  Payment allocations(List<PaymentAllocation> allocations) =>
      this(allocations: allocations);

  @override
  Payment allocatedTotalMinor(int allocatedTotalMinor) =>
      this(allocatedTotalMinor: allocatedTotalMinor);

  @override
  Payment unallocatedTotalMinor(int unallocatedTotalMinor) =>
      this(unallocatedTotalMinor: unallocatedTotalMinor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Payment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Payment(...).copyWith(id: 12, name: "My name")
  /// ````
  Payment call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? party = const $CopyWithPlaceholder(),
    Object? direction = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
    Object? amountMinor = const $CopyWithPlaceholder(),
    Object? reference = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? paymentDate = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? reversalReason = const $CopyWithPlaceholder(),
    Object? reversedAt = const $CopyWithPlaceholder(),
    Object? allocations = const $CopyWithPlaceholder(),
    Object? allocatedTotalMinor = const $CopyWithPlaceholder(),
    Object? unallocatedTotalMinor = const $CopyWithPlaceholder(),
  }) {
    return Payment(
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
      party: party == const $CopyWithPlaceholder()
          ? _value.party
          // ignore: cast_nullable_to_non_nullable
          : party as String?,
      direction: direction == const $CopyWithPlaceholder()
          ? _value.direction
          // ignore: cast_nullable_to_non_nullable
          : direction as PaymentDirectionEnum,
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as PaymentMethodEnum,
      amountMinor: amountMinor == const $CopyWithPlaceholder()
          ? _value.amountMinor
          // ignore: cast_nullable_to_non_nullable
          : amountMinor as int,
      reference: reference == const $CopyWithPlaceholder()
          ? _value.reference
          // ignore: cast_nullable_to_non_nullable
          : reference as String?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      paymentDate: paymentDate == const $CopyWithPlaceholder()
          ? _value.paymentDate
          // ignore: cast_nullable_to_non_nullable
          : paymentDate as DateTime,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as PaymentStatusEnum?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as String?,
      reversalReason: reversalReason == const $CopyWithPlaceholder()
          ? _value.reversalReason
          // ignore: cast_nullable_to_non_nullable
          : reversalReason as String?,
      reversedAt: reversedAt == const $CopyWithPlaceholder()
          ? _value.reversedAt
          // ignore: cast_nullable_to_non_nullable
          : reversedAt as DateTime?,
      allocations: allocations == const $CopyWithPlaceholder()
          ? _value.allocations
          // ignore: cast_nullable_to_non_nullable
          : allocations as List<PaymentAllocation>,
      allocatedTotalMinor: allocatedTotalMinor == const $CopyWithPlaceholder()
          ? _value.allocatedTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : allocatedTotalMinor as int,
      unallocatedTotalMinor:
          unallocatedTotalMinor == const $CopyWithPlaceholder()
          ? _value.unallocatedTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : unallocatedTotalMinor as int,
    );
  }
}

extension $PaymentCopyWith on Payment {
  /// Returns a callable class that can be used as follows: `instanceOfPayment.copyWith(...)` or like so:`instanceOfPayment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaymentCWProxy get copyWith => _$PaymentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Payment',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'business',
        'location',
        'direction',
        'method',
        'amount_minor',
        'payment_date',
        'allocations',
        'allocated_total_minor',
        'unallocated_total_minor',
      ],
    );
    final val = Payment(
      id: $checkedConvert('id', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      location: $checkedConvert('location', (v) => v as String),
      party: $checkedConvert('party', (v) => v as String?),
      direction: $checkedConvert(
        'direction',
        (v) => $enumDecode(_$PaymentDirectionEnumEnumMap, v),
      ),
      method: $checkedConvert(
        'method',
        (v) => $enumDecode(_$PaymentMethodEnumEnumMap, v),
      ),
      amountMinor: $checkedConvert('amount_minor', (v) => (v as num).toInt()),
      reference: $checkedConvert('reference', (v) => v as String?),
      note: $checkedConvert('note', (v) => v as String?),
      paymentDate: $checkedConvert(
        'payment_date',
        (v) => DateTime.parse(v as String),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecodeNullable(_$PaymentStatusEnumEnumMap, v),
      ),
      source_: $checkedConvert('source', (v) => v as String?),
      reversalReason: $checkedConvert('reversal_reason', (v) => v as String?),
      reversedAt: $checkedConvert(
        'reversed_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      allocations: $checkedConvert(
        'allocations',
        (v) => (v as List<dynamic>)
            .map((e) => PaymentAllocation.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      allocatedTotalMinor: $checkedConvert(
        'allocated_total_minor',
        (v) => (v as num).toInt(),
      ),
      unallocatedTotalMinor: $checkedConvert(
        'unallocated_total_minor',
        (v) => (v as num).toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'amountMinor': 'amount_minor',
    'paymentDate': 'payment_date',
    'source_': 'source',
    'reversalReason': 'reversal_reason',
    'reversedAt': 'reversed_at',
    'allocatedTotalMinor': 'allocated_total_minor',
    'unallocatedTotalMinor': 'unallocated_total_minor',
  },
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'business': instance.business,
  'location': instance.location,
  'party': ?instance.party,
  'direction': _$PaymentDirectionEnumEnumMap[instance.direction]!,
  'method': _$PaymentMethodEnumEnumMap[instance.method]!,
  'amount_minor': instance.amountMinor,
  'reference': ?instance.reference,
  'note': ?instance.note,
  'payment_date': instance.paymentDate.toIso8601String(),
  'status': ?_$PaymentStatusEnumEnumMap[instance.status],
  'source': ?instance.source_,
  'reversal_reason': ?instance.reversalReason,
  'reversed_at': ?instance.reversedAt?.toIso8601String(),
  'allocations': instance.allocations.map((e) => e.toJson()).toList(),
  'allocated_total_minor': instance.allocatedTotalMinor,
  'unallocated_total_minor': instance.unallocatedTotalMinor,
};

const _$PaymentDirectionEnumEnumMap = {
  PaymentDirectionEnum.RECEIPT: 'RECEIPT',
  PaymentDirectionEnum.PAYMENT: 'PAYMENT',
};

const _$PaymentMethodEnumEnumMap = {
  PaymentMethodEnum.CASH: 'CASH',
  PaymentMethodEnum.UPI: 'UPI',
  PaymentMethodEnum.CARD: 'CARD',
  PaymentMethodEnum.BANK: 'BANK',
  PaymentMethodEnum.OTHER: 'OTHER',
};

const _$PaymentStatusEnumEnumMap = {
  PaymentStatusEnum.DRAFT: 'DRAFT',
  PaymentStatusEnum.POSTED: 'POSTED',
  PaymentStatusEnum.REVERSED: 'REVERSED',
};
