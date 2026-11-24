//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_allocation_totals.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaymentAllocationTotals {
  /// Returns a new [PaymentAllocationTotals] instance.
  PaymentAllocationTotals({
    required this.paymentCount,

    required this.paymentTotalMinor,

    required this.allocatedTotalMinor,

    required this.unallocatedTotalMinor,

    required this.outstandingDocumentCount,

    required this.outstandingTotalMinor,
  });

  @JsonKey(name: r'payment_count', required: true, includeIfNull: false)
  final int paymentCount;

  @JsonKey(name: r'payment_total_minor', required: true, includeIfNull: false)
  final int paymentTotalMinor;

  @JsonKey(name: r'allocated_total_minor', required: true, includeIfNull: false)
  final int allocatedTotalMinor;

  @JsonKey(
    name: r'unallocated_total_minor',
    required: true,
    includeIfNull: false,
  )
  final int unallocatedTotalMinor;

  @JsonKey(
    name: r'outstanding_document_count',
    required: true,
    includeIfNull: false,
  )
  final int outstandingDocumentCount;

  @JsonKey(
    name: r'outstanding_total_minor',
    required: true,
    includeIfNull: false,
  )
  final int outstandingTotalMinor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentAllocationTotals &&
          other.paymentCount == paymentCount &&
          other.paymentTotalMinor == paymentTotalMinor &&
          other.allocatedTotalMinor == allocatedTotalMinor &&
          other.unallocatedTotalMinor == unallocatedTotalMinor &&
          other.outstandingDocumentCount == outstandingDocumentCount &&
          other.outstandingTotalMinor == outstandingTotalMinor;

  @override
  int get hashCode =>
      paymentCount.hashCode +
      paymentTotalMinor.hashCode +
      allocatedTotalMinor.hashCode +
      unallocatedTotalMinor.hashCode +
      outstandingDocumentCount.hashCode +
      outstandingTotalMinor.hashCode;

  factory PaymentAllocationTotals.fromJson(Map<String, dynamic> json) =>
      _$PaymentAllocationTotalsFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAllocationTotalsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
