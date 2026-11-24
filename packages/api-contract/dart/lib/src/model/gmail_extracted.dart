//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gmail_extracted.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GmailExtracted {
  /// Returns a new [GmailExtracted] instance.
  GmailExtracted({
    required this.kind,

    required this.direction,

    required this.partyName,

    required this.amountMinor,

    required this.reference,

    required this.confidence,
  });

  /// * `PAYMENT` - PAYMENT * `RECEIPT` - RECEIPT * `EXPENSE` - EXPENSE * `UNKNOWN` - UNKNOWN
  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final GmailExtractedKindEnum kind;

  /// * `RECEIPT` - RECEIPT * `PAYMENT` - PAYMENT
  @JsonKey(name: r'direction', required: true, includeIfNull: false)
  final GmailExtractedDirectionEnum direction;

  @JsonKey(name: r'party_name', required: true, includeIfNull: false)
  final String partyName;

  @JsonKey(name: r'amount_minor', required: true, includeIfNull: true)
  final int? amountMinor;

  @JsonKey(name: r'reference', required: true, includeIfNull: false)
  final String reference;

  @JsonKey(name: r'confidence', required: true, includeIfNull: true)
  final double? confidence;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GmailExtracted &&
          other.kind == kind &&
          other.direction == direction &&
          other.partyName == partyName &&
          other.amountMinor == amountMinor &&
          other.reference == reference &&
          other.confidence == confidence;

  @override
  int get hashCode =>
      kind.hashCode +
      direction.hashCode +
      partyName.hashCode +
      (amountMinor == null ? 0 : amountMinor.hashCode) +
      reference.hashCode +
      (confidence == null ? 0 : confidence.hashCode);

  factory GmailExtracted.fromJson(Map<String, dynamic> json) =>
      _$GmailExtractedFromJson(json);

  Map<String, dynamic> toJson() => _$GmailExtractedToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `PAYMENT` - PAYMENT * `RECEIPT` - RECEIPT * `EXPENSE` - EXPENSE * `UNKNOWN` - UNKNOWN
enum GmailExtractedKindEnum {
  @JsonValue(r'PAYMENT')
  PAYMENT(r'PAYMENT'),
  @JsonValue(r'RECEIPT')
  RECEIPT(r'RECEIPT'),
  @JsonValue(r'EXPENSE')
  EXPENSE(r'EXPENSE'),
  @JsonValue(r'UNKNOWN')
  UNKNOWN(r'UNKNOWN');

  const GmailExtractedKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `RECEIPT` - RECEIPT * `PAYMENT` - PAYMENT
enum GmailExtractedDirectionEnum {
  @JsonValue(r'RECEIPT')
  RECEIPT(r'RECEIPT'),
  @JsonValue(r'PAYMENT')
  PAYMENT(r'PAYMENT'),
  @JsonValue(r'')
  empty(r'');

  const GmailExtractedDirectionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
