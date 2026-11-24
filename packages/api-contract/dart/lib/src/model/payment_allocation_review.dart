//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/payment_allocation_totals.dart';
import 'package:dukaanai_api_client/src/model/payment.dart';
import 'package:dukaanai_api_client/src/model/outstanding_document.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_allocation_review.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaymentAllocationReview {
  /// Returns a new [PaymentAllocationReview] instance.
  PaymentAllocationReview({
    required this.results,

    required this.totals,

    required this.outstandingDocuments,
  });

  @JsonKey(name: r'results', required: true, includeIfNull: false)
  final List<Payment> results;

  @JsonKey(name: r'totals', required: true, includeIfNull: false)
  final PaymentAllocationTotals totals;

  @JsonKey(name: r'outstanding_documents', required: true, includeIfNull: false)
  final List<OutstandingDocument> outstandingDocuments;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentAllocationReview &&
          other.results == results &&
          other.totals == totals &&
          other.outstandingDocuments == outstandingDocuments;

  @override
  int get hashCode =>
      results.hashCode + totals.hashCode + outstandingDocuments.hashCode;

  factory PaymentAllocationReview.fromJson(Map<String, dynamic> json) =>
      _$PaymentAllocationReviewFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAllocationReviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
