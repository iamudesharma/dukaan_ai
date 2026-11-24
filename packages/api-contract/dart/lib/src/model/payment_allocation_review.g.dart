// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_allocation_review.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaymentAllocationReviewCWProxy {
  PaymentAllocationReview results(List<Payment> results);

  PaymentAllocationReview totals(PaymentAllocationTotals totals);

  PaymentAllocationReview outstandingDocuments(
    List<OutstandingDocument> outstandingDocuments,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentAllocationReview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentAllocationReview(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentAllocationReview call({
    List<Payment> results,
    PaymentAllocationTotals totals,
    List<OutstandingDocument> outstandingDocuments,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaymentAllocationReview.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaymentAllocationReview.copyWith.fieldName(...)`
class _$PaymentAllocationReviewCWProxyImpl
    implements _$PaymentAllocationReviewCWProxy {
  const _$PaymentAllocationReviewCWProxyImpl(this._value);

  final PaymentAllocationReview _value;

  @override
  PaymentAllocationReview results(List<Payment> results) =>
      this(results: results);

  @override
  PaymentAllocationReview totals(PaymentAllocationTotals totals) =>
      this(totals: totals);

  @override
  PaymentAllocationReview outstandingDocuments(
    List<OutstandingDocument> outstandingDocuments,
  ) => this(outstandingDocuments: outstandingDocuments);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentAllocationReview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentAllocationReview(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentAllocationReview call({
    Object? results = const $CopyWithPlaceholder(),
    Object? totals = const $CopyWithPlaceholder(),
    Object? outstandingDocuments = const $CopyWithPlaceholder(),
  }) {
    return PaymentAllocationReview(
      results: results == const $CopyWithPlaceholder()
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<Payment>,
      totals: totals == const $CopyWithPlaceholder()
          ? _value.totals
          // ignore: cast_nullable_to_non_nullable
          : totals as PaymentAllocationTotals,
      outstandingDocuments: outstandingDocuments == const $CopyWithPlaceholder()
          ? _value.outstandingDocuments
          // ignore: cast_nullable_to_non_nullable
          : outstandingDocuments as List<OutstandingDocument>,
    );
  }
}

extension $PaymentAllocationReviewCopyWith on PaymentAllocationReview {
  /// Returns a callable class that can be used as follows: `instanceOfPaymentAllocationReview.copyWith(...)` or like so:`instanceOfPaymentAllocationReview.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaymentAllocationReviewCWProxy get copyWith =>
      _$PaymentAllocationReviewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentAllocationReview _$PaymentAllocationReviewFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PaymentAllocationReview', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['results', 'totals', 'outstanding_documents'],
  );
  final val = PaymentAllocationReview(
    results: $checkedConvert(
      'results',
      (v) => (v as List<dynamic>)
          .map((e) => Payment.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    totals: $checkedConvert(
      'totals',
      (v) => PaymentAllocationTotals.fromJson(v as Map<String, dynamic>),
    ),
    outstandingDocuments: $checkedConvert(
      'outstanding_documents',
      (v) => (v as List<dynamic>)
          .map((e) => OutstandingDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
}, fieldKeyMap: const {'outstandingDocuments': 'outstanding_documents'});

Map<String, dynamic> _$PaymentAllocationReviewToJson(
  PaymentAllocationReview instance,
) => <String, dynamic>{
  'results': instance.results.map((e) => e.toJson()).toList(),
  'totals': instance.totals.toJson(),
  'outstanding_documents': instance.outstandingDocuments
      .map((e) => e.toJson())
      .toList(),
};
