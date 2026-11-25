//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gmail_import.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GmailImport {
  /// Returns a new [GmailImport] instance.
  GmailImport({
    required this.messageId,

    required this.businessId,

    required this.locationId,
  });

  @JsonKey(name: r'message_id', required: true, includeIfNull: false)
  final String messageId;

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'location_id', required: true, includeIfNull: false)
  final String locationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GmailImport &&
          other.messageId == messageId &&
          other.businessId == businessId &&
          other.locationId == locationId;

  @override
  int get hashCode =>
      messageId.hashCode + businessId.hashCode + locationId.hashCode;

  factory GmailImport.fromJson(Map<String, dynamic> json) =>
      _$GmailImportFromJson(json);

  Map<String, dynamic> toJson() => _$GmailImportToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
