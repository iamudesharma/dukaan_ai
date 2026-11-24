//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_allocation_input.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaymentAllocationInput {
  /// Returns a new [PaymentAllocationInput] instance.
  PaymentAllocationInput({
    required this.amountMinor,

    this.saleId,

    this.purchaseId,

    this.documentType,

    this.documentId,
  });

  // minimum: 1
  @JsonKey(name: r'amount_minor', required: true, includeIfNull: false)
  final int amountMinor;

  @JsonKey(name: r'sale_id', required: false, includeIfNull: false)
  final String? saleId;

  @JsonKey(name: r'purchase_id', required: false, includeIfNull: false)
  final String? purchaseId;

  /// * `SALE` - SALE * `PURCHASE` - PURCHASE
  @JsonKey(name: r'document_type', required: false, includeIfNull: false)
  final PaymentAllocationInputDocumentTypeEnum? documentType;

  @JsonKey(name: r'document_id', required: false, includeIfNull: false)
  final String? documentId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentAllocationInput &&
          other.amountMinor == amountMinor &&
          other.saleId == saleId &&
          other.purchaseId == purchaseId &&
          other.documentType == documentType &&
          other.documentId == documentId;

  @override
  int get hashCode =>
      amountMinor.hashCode +
      (saleId == null ? 0 : saleId.hashCode) +
      (purchaseId == null ? 0 : purchaseId.hashCode) +
      (documentType == null ? 0 : documentType.hashCode) +
      (documentId == null ? 0 : documentId.hashCode);

  factory PaymentAllocationInput.fromJson(Map<String, dynamic> json) =>
      _$PaymentAllocationInputFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAllocationInputToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `SALE` - SALE * `PURCHASE` - PURCHASE
enum PaymentAllocationInputDocumentTypeEnum {
  @JsonValue(r'SALE')
  SALE(r'SALE'),
  @JsonValue(r'PURCHASE')
  PURCHASE(r'PURCHASE');

  const PaymentAllocationInputDocumentTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
