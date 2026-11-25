//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/gmail_extracted.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gmail_import_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GmailImportResult {
  /// Returns a new [GmailImportResult] instance.
  GmailImportResult({
    required this.id,

    this.status,

    this.subject,

    this.receivedAt,

    this.preview,

    required this.extracted,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// * `NEEDS_REVIEW` - Needs review * `REVIEWED` - Reviewed * `DISMISSED` - Dismissed
  @JsonKey(name: r'status', required: false, includeIfNull: false)
  final GmailImportResultStatusEnum? status;

  @JsonKey(name: r'subject', required: false, includeIfNull: false)
  final String? subject;

  @JsonKey(name: r'received_at', required: false, includeIfNull: false)
  final DateTime? receivedAt;

  @JsonKey(name: r'preview', required: false, includeIfNull: false)
  final String? preview;

  @JsonKey(name: r'extracted', required: true, includeIfNull: false)
  final GmailExtracted extracted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GmailImportResult &&
          other.id == id &&
          other.status == status &&
          other.subject == subject &&
          other.receivedAt == receivedAt &&
          other.preview == preview &&
          other.extracted == extracted;

  @override
  int get hashCode =>
      id.hashCode +
      status.hashCode +
      subject.hashCode +
      (receivedAt == null ? 0 : receivedAt.hashCode) +
      preview.hashCode +
      extracted.hashCode;

  factory GmailImportResult.fromJson(Map<String, dynamic> json) =>
      _$GmailImportResultFromJson(json);

  Map<String, dynamic> toJson() => _$GmailImportResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `NEEDS_REVIEW` - Needs review * `REVIEWED` - Reviewed * `DISMISSED` - Dismissed
enum GmailImportResultStatusEnum {
  @JsonValue(r'NEEDS_REVIEW')
  NEEDS_REVIEW(r'NEEDS_REVIEW'),
  @JsonValue(r'REVIEWED')
  REVIEWED(r'REVIEWED'),
  @JsonValue(r'DISMISSED')
  DISMISSED(r'DISMISSED');

  const GmailImportResultStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
