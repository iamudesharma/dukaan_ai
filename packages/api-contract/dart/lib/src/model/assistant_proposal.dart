//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'assistant_proposal.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssistantProposal {
  /// Returns a new [AssistantProposal] instance.
  AssistantProposal({
    required this.id,

    required this.business,

    required this.location,

    required this.inputType,

    required this.locale,

    required this.content,

    required this.commandType,

    required this.payload,

    required this.preview,

    required this.previewData,

    required this.warnings,

    required this.blockingQuestions,

    required this.status,

    required this.version,

    required this.expiresAt,

    required this.confirmedAt,

    required this.confirmedResultType,

    required this.confirmedResultId,

    required this.createdAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'location', required: true, includeIfNull: false)
  final String location;

  /// * `TEXT` - Text * `VOICE` - Voice transcript * `IMAGE` - Image OCR text
  @JsonKey(name: r'input_type', required: true, includeIfNull: false)
  final AssistantProposalInputTypeEnum inputType;

  @JsonKey(name: r'locale', required: true, includeIfNull: false)
  final String locale;

  @JsonKey(name: r'content', required: true, includeIfNull: false)
  final String content;

  @JsonKey(name: r'command_type', required: true, includeIfNull: false)
  final String commandType;

  @JsonKey(name: r'payload', required: true, includeIfNull: true)
  final Object? payload;

  @JsonKey(name: r'preview', required: true, includeIfNull: false)
  final String preview;

  @JsonKey(name: r'preview_data', required: true, includeIfNull: true)
  final Object? previewData;

  @JsonKey(name: r'warnings', required: true, includeIfNull: true)
  final Object? warnings;

  @JsonKey(name: r'blocking_questions', required: true, includeIfNull: true)
  final Object? blockingQuestions;

  /// * `DRAFT` - Needs clarification * `READY` - Ready to confirm * `CONFIRMED` - Confirmed * `CANCELLED` - Cancelled * `EXPIRED` - Expired
  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final AssistantProposalStatusEnum status;

  @JsonKey(name: r'version', required: true, includeIfNull: false)
  final int version;

  @JsonKey(name: r'expires_at', required: true, includeIfNull: false)
  final DateTime expiresAt;

  @JsonKey(name: r'confirmed_at', required: true, includeIfNull: true)
  final DateTime? confirmedAt;

  @JsonKey(name: r'confirmed_result_type', required: true, includeIfNull: false)
  final String confirmedResultType;

  @JsonKey(name: r'confirmed_result_id', required: true, includeIfNull: true)
  final String? confirmedResultId;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssistantProposal &&
          other.id == id &&
          other.business == business &&
          other.location == location &&
          other.inputType == inputType &&
          other.locale == locale &&
          other.content == content &&
          other.commandType == commandType &&
          other.payload == payload &&
          other.preview == preview &&
          other.previewData == previewData &&
          other.warnings == warnings &&
          other.blockingQuestions == blockingQuestions &&
          other.status == status &&
          other.version == version &&
          other.expiresAt == expiresAt &&
          other.confirmedAt == confirmedAt &&
          other.confirmedResultType == confirmedResultType &&
          other.confirmedResultId == confirmedResultId &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      location.hashCode +
      inputType.hashCode +
      locale.hashCode +
      content.hashCode +
      commandType.hashCode +
      (payload == null ? 0 : payload.hashCode) +
      preview.hashCode +
      (previewData == null ? 0 : previewData.hashCode) +
      (warnings == null ? 0 : warnings.hashCode) +
      (blockingQuestions == null ? 0 : blockingQuestions.hashCode) +
      status.hashCode +
      version.hashCode +
      expiresAt.hashCode +
      (confirmedAt == null ? 0 : confirmedAt.hashCode) +
      confirmedResultType.hashCode +
      (confirmedResultId == null ? 0 : confirmedResultId.hashCode) +
      createdAt.hashCode;

  factory AssistantProposal.fromJson(Map<String, dynamic> json) =>
      _$AssistantProposalFromJson(json);

  Map<String, dynamic> toJson() => _$AssistantProposalToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `TEXT` - Text * `VOICE` - Voice transcript * `IMAGE` - Image OCR text
enum AssistantProposalInputTypeEnum {
  @JsonValue(r'TEXT')
  TEXT(r'TEXT'),
  @JsonValue(r'VOICE')
  VOICE(r'VOICE'),
  @JsonValue(r'IMAGE')
  IMAGE(r'IMAGE');

  const AssistantProposalInputTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `DRAFT` - Needs clarification * `READY` - Ready to confirm * `CONFIRMED` - Confirmed * `CANCELLED` - Cancelled * `EXPIRED` - Expired
enum AssistantProposalStatusEnum {
  @JsonValue(r'DRAFT')
  DRAFT(r'DRAFT'),
  @JsonValue(r'READY')
  READY(r'READY'),
  @JsonValue(r'CONFIRMED')
  CONFIRMED(r'CONFIRMED'),
  @JsonValue(r'CANCELLED')
  CANCELLED(r'CANCELLED'),
  @JsonValue(r'EXPIRED')
  EXPIRED(r'EXPIRED');

  const AssistantProposalStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
