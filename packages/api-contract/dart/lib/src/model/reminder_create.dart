//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_create.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderCreate {
  /// Returns a new [ReminderCreate] instance.
  ReminderCreate({
    required this.businessId,

    this.locationId,

    required this.title,

    required this.body,

    required this.scheduledAt,

    this.dedupeKey,

    this.data,
  });

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'location_id', required: false, includeIfNull: false)
  final String? locationId;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'body', required: true, includeIfNull: false)
  final String body;

  @JsonKey(name: r'scheduled_at', required: true, includeIfNull: false)
  final DateTime scheduledAt;

  @JsonKey(name: r'dedupe_key', required: false, includeIfNull: false)
  final String? dedupeKey;

  /// Arbitrary notification payload fields; must be a JSON object.
  @JsonKey(name: r'data', required: false, includeIfNull: false)
  final Object? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderCreate &&
          other.businessId == businessId &&
          other.locationId == locationId &&
          other.title == title &&
          other.body == body &&
          other.scheduledAt == scheduledAt &&
          other.dedupeKey == dedupeKey &&
          other.data == data;

  @override
  int get hashCode =>
      businessId.hashCode +
      (locationId == null ? 0 : locationId.hashCode) +
      title.hashCode +
      body.hashCode +
      scheduledAt.hashCode +
      dedupeKey.hashCode +
      (data == null ? 0 : data.hashCode);

  factory ReminderCreate.fromJson(Map<String, dynamic> json) =>
      _$ReminderCreateFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderCreateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
