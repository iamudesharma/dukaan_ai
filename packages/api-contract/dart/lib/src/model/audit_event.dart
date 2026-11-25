//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'audit_event.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AuditEvent {
  /// Returns a new [AuditEvent] instance.
  AuditEvent({
    required this.id,

    required this.eventType,

    required this.aggregateType,

    required this.aggregateId,

    required this.location,

    required this.actorName,

    required this.source_,

    required this.metadata,

    required this.createdAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'event_type', required: true, includeIfNull: false)
  final String eventType;

  @JsonKey(name: r'aggregate_type', required: true, includeIfNull: false)
  final String aggregateType;

  @JsonKey(name: r'aggregate_id', required: true, includeIfNull: false)
  final String aggregateId;

  @JsonKey(name: r'location', required: true, includeIfNull: true)
  final String? location;

  @JsonKey(name: r'actor_name', required: true, includeIfNull: true)
  final String? actorName;

  @JsonKey(name: r'source', required: true, includeIfNull: false)
  final String source_;

  @JsonKey(name: r'metadata', required: true, includeIfNull: true)
  final Object? metadata;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditEvent &&
          other.id == id &&
          other.eventType == eventType &&
          other.aggregateType == aggregateType &&
          other.aggregateId == aggregateId &&
          other.location == location &&
          other.actorName == actorName &&
          other.source_ == source_ &&
          other.metadata == metadata &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode +
      eventType.hashCode +
      aggregateType.hashCode +
      aggregateId.hashCode +
      (location == null ? 0 : location.hashCode) +
      (actorName == null ? 0 : actorName.hashCode) +
      source_.hashCode +
      (metadata == null ? 0 : metadata.hashCode) +
      createdAt.hashCode;

  factory AuditEvent.fromJson(Map<String, dynamic> json) =>
      _$AuditEventFromJson(json);

  Map<String, dynamic> toJson() => _$AuditEventToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
