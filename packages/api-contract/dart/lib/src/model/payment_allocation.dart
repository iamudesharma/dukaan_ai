//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_allocation.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaymentAllocation {
  /// Returns a new [PaymentAllocation] instance.
  PaymentAllocation({
    required this.id,

    this.sale,

    this.purchase,

    required this.amountMinor,

    required this.documentType,

    required this.documentId,

    required this.documentNumber,

    required this.documentTotalMinor,

    required this.documentPaidTotalMinor,

    required this.documentDueTotalMinor,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'sale', required: false, includeIfNull: false)
  final String? sale;

  @JsonKey(name: r'purchase', required: false, includeIfNull: false)
  final String? purchase;

  // minimum: -9223372036854775808
  // maximum: 9223372036854775807
  @JsonKey(name: r'amount_minor', required: true, includeIfNull: false)
  final int amountMinor;

  @JsonKey(name: r'document_type', required: true, includeIfNull: false)
  final PaymentAllocationDocumentTypeEnum documentType;

  @JsonKey(name: r'document_id', required: true, includeIfNull: true)
  final String? documentId;

  @JsonKey(name: r'document_number', required: true, includeIfNull: true)
  final String? documentNumber;

  @JsonKey(name: r'document_total_minor', required: true, includeIfNull: true)
  final int? documentTotalMinor;

  @JsonKey(
    name: r'document_paid_total_minor',
    required: true,
    includeIfNull: true,
  )
  final int? documentPaidTotalMinor;

  @JsonKey(
    name: r'document_due_total_minor',
    required: true,
    includeIfNull: true,
  )
  final int? documentDueTotalMinor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentAllocation &&
          other.id == id &&
          other.sale == sale &&
          other.purchase == purchase &&
          other.amountMinor == amountMinor &&
          other.documentType == documentType &&
          other.documentId == documentId &&
          other.documentNumber == documentNumber &&
          other.documentTotalMinor == documentTotalMinor &&
          other.documentPaidTotalMinor == documentPaidTotalMinor &&
          other.documentDueTotalMinor == documentDueTotalMinor;

  @override
  int get hashCode =>
      id.hashCode +
      (sale == null ? 0 : sale.hashCode) +
      (purchase == null ? 0 : purchase.hashCode) +
      amountMinor.hashCode +
      documentType.hashCode +
      (documentId == null ? 0 : documentId.hashCode) +
      (documentNumber == null ? 0 : documentNumber.hashCode) +
      (documentTotalMinor == null ? 0 : documentTotalMinor.hashCode) +
      (documentPaidTotalMinor == null ? 0 : documentPaidTotalMinor.hashCode) +
      (documentDueTotalMinor == null ? 0 : documentDueTotalMinor.hashCode);

  factory PaymentAllocation.fromJson(Map<String, dynamic> json) =>
      _$PaymentAllocationFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAllocationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum PaymentAllocationDocumentTypeEnum {
  @JsonValue(r'SALE')
  SALE(r'SALE'),
  @JsonValue(r'PURCHASE')
  PURCHASE(r'PURCHASE');

  const PaymentAllocationDocumentTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
