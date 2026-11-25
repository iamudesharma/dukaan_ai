// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_reallocation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaymentReallocationCWProxy {
  PaymentReallocation allocations(List<PaymentAllocationInput> allocations);

  PaymentReallocation reason(String reason);

  PaymentReallocation idempotencyKey(String idempotencyKey);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentReallocation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentReallocation(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentReallocation call({
    List<PaymentAllocationInput> allocations,
    String reason,
    String idempotencyKey,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaymentReallocation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaymentReallocation.copyWith.fieldName(...)`
class _$PaymentReallocationCWProxyImpl implements _$PaymentReallocationCWProxy {
  const _$PaymentReallocationCWProxyImpl(this._value);

  final PaymentReallocation _value;

  @override
  PaymentReallocation allocations(List<PaymentAllocationInput> allocations) =>
      this(allocations: allocations);

  @override
  PaymentReallocation reason(String reason) => this(reason: reason);

  @override
  PaymentReallocation idempotencyKey(String idempotencyKey) =>
      this(idempotencyKey: idempotencyKey);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentReallocation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentReallocation(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentReallocation call({
    Object? allocations = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? idempotencyKey = const $CopyWithPlaceholder(),
  }) {
    return PaymentReallocation(
      allocations: allocations == const $CopyWithPlaceholder()
          ? _value.allocations
          // ignore: cast_nullable_to_non_nullable
          : allocations as List<PaymentAllocationInput>,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      idempotencyKey: idempotencyKey == const $CopyWithPlaceholder()
          ? _value.idempotencyKey
          // ignore: cast_nullable_to_non_nullable
          : idempotencyKey as String,
    );
  }
}

extension $PaymentReallocationCopyWith on PaymentReallocation {
  /// Returns a callable class that can be used as follows: `instanceOfPaymentReallocation.copyWith(...)` or like so:`instanceOfPaymentReallocation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaymentReallocationCWProxy get copyWith =>
      _$PaymentReallocationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentReallocation _$PaymentReallocationFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PaymentReallocation', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['allocations', 'reason', 'idempotency_key'],
      );
      final val = PaymentReallocation(
        allocations: $checkedConvert(
          'allocations',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    PaymentAllocationInput.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
        reason: $checkedConvert('reason', (v) => v as String),
        idempotencyKey: $checkedConvert('idempotency_key', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'idempotencyKey': 'idempotency_key'});

Map<String, dynamic> _$PaymentReallocationToJson(
  PaymentReallocation instance,
) => <String, dynamic>{
  'allocations': instance.allocations.map((e) => e.toJson()).toList(),
  'reason': instance.reason,
  'idempotency_key': instance.idempotencyKey,
};
