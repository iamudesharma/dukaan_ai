//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'refresh_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RefreshResponse {
  /// Returns a new [RefreshResponse] instance.
  RefreshResponse({required this.access});

  @JsonKey(name: r'access', required: true, includeIfNull: false)
  final String access;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefreshResponse && other.access == access;

  @override
  int get hashCode => access.hashCode;

  factory RefreshResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
