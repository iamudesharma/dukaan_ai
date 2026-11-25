// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reverse.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReverseCWProxy {
  Reverse reason(String reason);

  Reverse idempotencyKey(String idempotencyKey);

  Reverse negativeStockAcknowledged(bool? negativeStockAcknowledged);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reverse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reverse(...).copyWith(id: 12, name: "My name")
  /// ````
  Reverse call({
    String reason,
    String idempotencyKey,
    bool? negativeStockAcknowledged,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReverse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReverse.copyWith.fieldName(...)`
class _$ReverseCWProxyImpl implements _$ReverseCWProxy {
  const _$ReverseCWProxyImpl(this._value);

  final Reverse _value;

  @override
  Reverse reason(String reason) => this(reason: reason);

  @override
  Reverse idempotencyKey(String idempotencyKey) =>
      this(idempotencyKey: idempotencyKey);

  @override
  Reverse negativeStockAcknowledged(bool? negativeStockAcknowledged) =>
      this(negativeStockAcknowledged: negativeStockAcknowledged);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reverse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reverse(...).copyWith(id: 12, name: "My name")
  /// ````
  Reverse call({
    Object? reason = const $CopyWithPlaceholder(),
    Object? idempotencyKey = const $CopyWithPlaceholder(),
    Object? negativeStockAcknowledged = const $CopyWithPlaceholder(),
  }) {
    return Reverse(
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      idempotencyKey: idempotencyKey == const $CopyWithPlaceholder()
          ? _value.idempotencyKey
          // ignore: cast_nullable_to_non_nullable
          : idempotencyKey as String,
      negativeStockAcknowledged:
          negativeStockAcknowledged == const $CopyWithPlaceholder()
          ? _value.negativeStockAcknowledged
          // ignore: cast_nullable_to_non_nullable
          : negativeStockAcknowledged as bool?,
    );
  }
}

extension $ReverseCopyWith on Reverse {
  /// Returns a callable class that can be used as follows: `instanceOfReverse.copyWith(...)` or like so:`instanceOfReverse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReverseCWProxy get copyWith => _$ReverseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reverse _$ReverseFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Reverse',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['reason', 'idempotency_key']);
    final val = Reverse(
      reason: $checkedConvert('reason', (v) => v as String),
      idempotencyKey: $checkedConvert('idempotency_key', (v) => v as String),
      negativeStockAcknowledged: $checkedConvert(
        'negative_stock_acknowledged',
        (v) => v as bool? ?? false,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'idempotencyKey': 'idempotency_key',
    'negativeStockAcknowledged': 'negative_stock_acknowledged',
  },
);

Map<String, dynamic> _$ReverseToJson(Reverse instance) => <String, dynamic>{
  'reason': instance.reason,
  'idempotency_key': instance.idempotencyKey,
  'negative_stock_acknowledged': ?instance.negativeStockAcknowledged,
};
