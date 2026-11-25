//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attachment.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Attachment {
  /// Returns a new [Attachment] instance.
  Attachment({
    required this.id,

    required this.business,

    required this.kind,

    required this.mime,

    required this.sizeBytes,

    required this.status,

    required this.proposal,

    required this.createdAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  /// * `VOICE` - Voice recording * `IMAGE` - Image or scan
  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final AttachmentKindEnum kind;

  @JsonKey(name: r'mime', required: true, includeIfNull: false)
  final String mime;

  @JsonKey(name: r'size_bytes', required: true, includeIfNull: false)
  final int sizeBytes;

  /// * `PENDING` - Awaiting upload * `READY` - Uploaded * `FAILED` - Rejected
  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final AttachmentStatusEnum status;

  @JsonKey(name: r'proposal', required: true, includeIfNull: true)
  final String? proposal;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Attachment &&
          other.id == id &&
          other.business == business &&
          other.kind == kind &&
          other.mime == mime &&
          other.sizeBytes == sizeBytes &&
          other.status == status &&
          other.proposal == proposal &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      kind.hashCode +
      mime.hashCode +
      sizeBytes.hashCode +
      status.hashCode +
      (proposal == null ? 0 : proposal.hashCode) +
      createdAt.hashCode;

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      _$AttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$AttachmentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `VOICE` - Voice recording * `IMAGE` - Image or scan
enum AttachmentKindEnum {
  @JsonValue(r'VOICE')
  VOICE(r'VOICE'),
  @JsonValue(r'IMAGE')
  IMAGE(r'IMAGE');

  const AttachmentKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `PENDING` - Awaiting upload * `READY` - Uploaded * `FAILED` - Rejected
enum AttachmentStatusEnum {
  @JsonValue(r'PENDING')
  PENDING(r'PENDING'),
  @JsonValue(r'READY')
  READY(r'READY'),
  @JsonValue(r'FAILED')
  FAILED(r'FAILED');

  const AttachmentStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
