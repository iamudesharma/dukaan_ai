//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'patched_reminder_update.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PatchedReminderUpdate {
  /// Returns a new [PatchedReminderUpdate] instance.
  PatchedReminderUpdate({this.title, this.body, this.scheduledAt});

  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  @JsonKey(name: r'body', required: false, includeIfNull: false)
  final String? body;

  @JsonKey(name: r'scheduled_at', required: false, includeIfNull: false)
  final DateTime? scheduledAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatchedReminderUpdate &&
          other.title == title &&
          other.body == body &&
          other.scheduledAt == scheduledAt;

  @override
  int get hashCode => title.hashCode + body.hashCode + scheduledAt.hashCode;

  factory PatchedReminderUpdate.fromJson(Map<String, dynamic> json) =>
      _$PatchedReminderUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$PatchedReminderUpdateToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
