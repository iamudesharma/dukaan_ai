//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/membership_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'me.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Me {
  /// Returns a new [Me] instance.
  Me({
    required this.id,

    required this.phone,

    required this.displayName,

    required this.memberships,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'phone', required: true, includeIfNull: false)
  final String phone;

  @JsonKey(name: r'display_name', required: true, includeIfNull: false)
  final String displayName;

  @JsonKey(name: r'memberships', required: true, includeIfNull: false)
  final List<MembershipSummary> memberships;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Me &&
          other.id == id &&
          other.phone == phone &&
          other.displayName == displayName &&
          other.memberships == memberships;

  @override
  int get hashCode =>
      id.hashCode +
      phone.hashCode +
      displayName.hashCode +
      memberships.hashCode;

  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);

  Map<String, dynamic> toJson() => _$MeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
