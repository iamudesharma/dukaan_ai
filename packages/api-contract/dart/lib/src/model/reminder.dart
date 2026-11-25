//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Reminder {
  /// Returns a new [Reminder] instance.
  Reminder({
    required this.id,

    required this.business,

    required this.location,

    required this.kind,

    required this.title,

    required this.body,

    required this.scheduledAt,

    required this.status,

    required this.dedupeKey,

    required this.data,

    required this.metadata,

    required this.queuedAt,

    required this.sentAt,

    required this.cancelledAt,

    required this.lastError,

    required this.createdAt,

    required this.updatedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'location', required: true, includeIfNull: true)
  final String? location;

  /// * `USER` - User reminder * `DOMAIN` - Domain event
  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final ReminderKindEnum kind;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'body', required: true, includeIfNull: false)
  final String body;

  @JsonKey(name: r'scheduled_at', required: true, includeIfNull: false)
  final DateTime scheduledAt;

  /// * `SCHEDULED` - Scheduled * `QUEUED` - Queued * `SENT` - Sent * `FAILED` - Failed * `CANCELLED` - Cancelled * `SKIPPED` - Skipped
  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final ReminderStatusEnum status;

  @JsonKey(name: r'dedupe_key', required: true, includeIfNull: false)
  final String dedupeKey;

  @JsonKey(name: r'data', required: true, includeIfNull: true)
  final Object? data;

  @JsonKey(name: r'metadata', required: true, includeIfNull: true)
  final Object? metadata;

  @JsonKey(name: r'queued_at', required: true, includeIfNull: true)
  final DateTime? queuedAt;

  @JsonKey(name: r'sent_at', required: true, includeIfNull: true)
  final DateTime? sentAt;

  @JsonKey(name: r'cancelled_at', required: true, includeIfNull: true)
  final DateTime? cancelledAt;

  @JsonKey(name: r'last_error', required: true, includeIfNull: false)
  final String lastError;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'updated_at', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reminder &&
          other.id == id &&
          other.business == business &&
          other.location == location &&
          other.kind == kind &&
          other.title == title &&
          other.body == body &&
          other.scheduledAt == scheduledAt &&
          other.status == status &&
          other.dedupeKey == dedupeKey &&
          other.data == data &&
          other.metadata == metadata &&
          other.queuedAt == queuedAt &&
          other.sentAt == sentAt &&
          other.cancelledAt == cancelledAt &&
          other.lastError == lastError &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      (location == null ? 0 : location.hashCode) +
      kind.hashCode +
      title.hashCode +
      body.hashCode +
      scheduledAt.hashCode +
      status.hashCode +
      dedupeKey.hashCode +
      (data == null ? 0 : data.hashCode) +
      (metadata == null ? 0 : metadata.hashCode) +
      (queuedAt == null ? 0 : queuedAt.hashCode) +
      (sentAt == null ? 0 : sentAt.hashCode) +
      (cancelledAt == null ? 0 : cancelledAt.hashCode) +
      lastError.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `USER` - User reminder * `DOMAIN` - Domain event
enum ReminderKindEnum {
  @JsonValue(r'USER')
  USER(r'USER'),
  @JsonValue(r'DOMAIN')
  DOMAIN(r'DOMAIN');

  const ReminderKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `SCHEDULED` - Scheduled * `QUEUED` - Queued * `SENT` - Sent * `FAILED` - Failed * `CANCELLED` - Cancelled * `SKIPPED` - Skipped
enum ReminderStatusEnum {
  @JsonValue(r'SCHEDULED')
  SCHEDULED(r'SCHEDULED'),
  @JsonValue(r'QUEUED')
  QUEUED(r'QUEUED'),
  @JsonValue(r'SENT')
  SENT(r'SENT'),
  @JsonValue(r'FAILED')
  FAILED(r'FAILED'),
  @JsonValue(r'CANCELLED')
  CANCELLED(r'CANCELLED'),
  @JsonValue(r'SKIPPED')
  SKIPPED(r'SKIPPED');

  const ReminderStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
