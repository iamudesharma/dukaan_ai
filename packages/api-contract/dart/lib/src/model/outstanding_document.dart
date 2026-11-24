//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'outstanding_document.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OutstandingDocument {
  /// Returns a new [OutstandingDocument] instance.
  OutstandingDocument({
    required this.documentType,

    required this.documentId,

    required this.number,

    required this.documentDate,

    required this.partyId,

    required this.partyName,

    required this.grandTotalMinor,

    required this.paidTotalMinor,

    required this.dueTotalMinor,
  });

  /// * `SALE` - SALE * `PURCHASE` - PURCHASE
  @JsonKey(name: r'document_type', required: true, includeIfNull: false)
  final OutstandingDocumentDocumentTypeEnum documentType;

  @JsonKey(name: r'document_id', required: true, includeIfNull: false)
  final String documentId;

  @JsonKey(name: r'number', required: true, includeIfNull: false)
  final String number;

  @JsonKey(name: r'document_date', required: true, includeIfNull: false)
  final DateTime documentDate;

  @JsonKey(name: r'party_id', required: true, includeIfNull: true)
  final String? partyId;

  @JsonKey(name: r'party_name', required: true, includeIfNull: true)
  final String? partyName;

  @JsonKey(name: r'grand_total_minor', required: true, includeIfNull: false)
  final int grandTotalMinor;

  @JsonKey(name: r'paid_total_minor', required: true, includeIfNull: false)
  final int paidTotalMinor;

  @JsonKey(name: r'due_total_minor', required: true, includeIfNull: false)
  final int dueTotalMinor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutstandingDocument &&
          other.documentType == documentType &&
          other.documentId == documentId &&
          other.number == number &&
          other.documentDate == documentDate &&
          other.partyId == partyId &&
          other.partyName == partyName &&
          other.grandTotalMinor == grandTotalMinor &&
          other.paidTotalMinor == paidTotalMinor &&
          other.dueTotalMinor == dueTotalMinor;

  @override
  int get hashCode =>
      documentType.hashCode +
      documentId.hashCode +
      number.hashCode +
      documentDate.hashCode +
      (partyId == null ? 0 : partyId.hashCode) +
      (partyName == null ? 0 : partyName.hashCode) +
      grandTotalMinor.hashCode +
      paidTotalMinor.hashCode +
      dueTotalMinor.hashCode;

  factory OutstandingDocument.fromJson(Map<String, dynamic> json) =>
      _$OutstandingDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$OutstandingDocumentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `SALE` - SALE * `PURCHASE` - PURCHASE
enum OutstandingDocumentDocumentTypeEnum {
  @JsonValue(r'SALE')
  SALE(r'SALE'),
  @JsonValue(r'PURCHASE')
  PURCHASE(r'PURCHASE');

  const OutstandingDocumentDocumentTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
