// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_allocation_totals.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaymentAllocationTotalsCWProxy {
  PaymentAllocationTotals paymentCount(int paymentCount);

  PaymentAllocationTotals paymentTotalMinor(int paymentTotalMinor);

  PaymentAllocationTotals allocatedTotalMinor(int allocatedTotalMinor);

  PaymentAllocationTotals unallocatedTotalMinor(int unallocatedTotalMinor);

  PaymentAllocationTotals outstandingDocumentCount(
    int outstandingDocumentCount,
  );

  PaymentAllocationTotals outstandingTotalMinor(int outstandingTotalMinor);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentAllocationTotals(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentAllocationTotals(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentAllocationTotals call({
    int paymentCount,
    int paymentTotalMinor,
    int allocatedTotalMinor,
    int unallocatedTotalMinor,
    int outstandingDocumentCount,
    int outstandingTotalMinor,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaymentAllocationTotals.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaymentAllocationTotals.copyWith.fieldName(...)`
class _$PaymentAllocationTotalsCWProxyImpl
    implements _$PaymentAllocationTotalsCWProxy {
  const _$PaymentAllocationTotalsCWProxyImpl(this._value);

  final PaymentAllocationTotals _value;

  @override
  PaymentAllocationTotals paymentCount(int paymentCount) =>
      this(paymentCount: paymentCount);

  @override
  PaymentAllocationTotals paymentTotalMinor(int paymentTotalMinor) =>
      this(paymentTotalMinor: paymentTotalMinor);

  @override
  PaymentAllocationTotals allocatedTotalMinor(int allocatedTotalMinor) =>
      this(allocatedTotalMinor: allocatedTotalMinor);

  @override
  PaymentAllocationTotals unallocatedTotalMinor(int unallocatedTotalMinor) =>
      this(unallocatedTotalMinor: unallocatedTotalMinor);

  @override
  PaymentAllocationTotals outstandingDocumentCount(
    int outstandingDocumentCount,
  ) => this(outstandingDocumentCount: outstandingDocumentCount);

  @override
  PaymentAllocationTotals outstandingTotalMinor(int outstandingTotalMinor) =>
      this(outstandingTotalMinor: outstandingTotalMinor);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentAllocationTotals(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentAllocationTotals(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentAllocationTotals call({
    Object? paymentCount = const $CopyWithPlaceholder(),
    Object? paymentTotalMinor = const $CopyWithPlaceholder(),
    Object? allocatedTotalMinor = const $CopyWithPlaceholder(),
    Object? unallocatedTotalMinor = const $CopyWithPlaceholder(),
    Object? outstandingDocumentCount = const $CopyWithPlaceholder(),
    Object? outstandingTotalMinor = const $CopyWithPlaceholder(),
  }) {
    return PaymentAllocationTotals(
      paymentCount: paymentCount == const $CopyWithPlaceholder()
          ? _value.paymentCount
          // ignore: cast_nullable_to_non_nullable
          : paymentCount as int,
      paymentTotalMinor: paymentTotalMinor == const $CopyWithPlaceholder()
          ? _value.paymentTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : paymentTotalMinor as int,
      allocatedTotalMinor: allocatedTotalMinor == const $CopyWithPlaceholder()
          ? _value.allocatedTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : allocatedTotalMinor as int,
      unallocatedTotalMinor:
          unallocatedTotalMinor == const $CopyWithPlaceholder()
          ? _value.unallocatedTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : unallocatedTotalMinor as int,
      outstandingDocumentCount:
          outstandingDocumentCount == const $CopyWithPlaceholder()
          ? _value.outstandingDocumentCount
          // ignore: cast_nullable_to_non_nullable
          : outstandingDocumentCount as int,
      outstandingTotalMinor:
          outstandingTotalMinor == const $CopyWithPlaceholder()
          ? _value.outstandingTotalMinor
          // ignore: cast_nullable_to_non_nullable
          : outstandingTotalMinor as int,
    );
  }
}

extension $PaymentAllocationTotalsCopyWith on PaymentAllocationTotals {
  /// Returns a callable class that can be used as follows: `instanceOfPaymentAllocationTotals.copyWith(...)` or like so:`instanceOfPaymentAllocationTotals.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaymentAllocationTotalsCWProxy get copyWith =>
      _$PaymentAllocationTotalsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentAllocationTotals _$PaymentAllocationTotalsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PaymentAllocationTotals',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'payment_count',
        'payment_total_minor',
        'allocated_total_minor',
        'unallocated_total_minor',
        'outstanding_document_count',
        'outstanding_total_minor',
      ],
    );
    final val = PaymentAllocationTotals(
      paymentCount: $checkedConvert('payment_count', (v) => (v as num).toInt()),
      paymentTotalMinor: $checkedConvert(
        'payment_total_minor',
        (v) => (v as num).toInt(),
      ),
      allocatedTotalMinor: $checkedConvert(
        'allocated_total_minor',
        (v) => (v as num).toInt(),
      ),
      unallocatedTotalMinor: $checkedConvert(
        'unallocated_total_minor',
        (v) => (v as num).toInt(),
      ),
      outstandingDocumentCount: $checkedConvert(
        'outstanding_document_count',
        (v) => (v as num).toInt(),
      ),
      outstandingTotalMinor: $checkedConvert(
        'outstanding_total_minor',
        (v) => (v as num).toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'paymentCount': 'payment_count',
    'paymentTotalMinor': 'payment_total_minor',
    'allocatedTotalMinor': 'allocated_total_minor',
    'unallocatedTotalMinor': 'unallocated_total_minor',
    'outstandingDocumentCount': 'outstanding_document_count',
    'outstandingTotalMinor': 'outstanding_total_minor',
  },
);

Map<String, dynamic> _$PaymentAllocationTotalsToJson(
  PaymentAllocationTotals instance,
) => <String, dynamic>{
  'payment_count': instance.paymentCount,
  'payment_total_minor': instance.paymentTotalMinor,
  'allocated_total_minor': instance.allocatedTotalMinor,
  'unallocated_total_minor': instance.unallocatedTotalMinor,
  'outstanding_document_count': instance.outstandingDocumentCount,
  'outstanding_total_minor': instance.outstandingTotalMinor,
};
