//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_revoke_all_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionRevokeAllResponse {
  /// Returns a new [SessionRevokeAllResponse] instance.
  SessionRevokeAllResponse({required this.detail, required this.tokenVersion});

  @JsonKey(name: r'detail', required: true, includeIfNull: false)
  final String detail;

  @JsonKey(name: r'token_version', required: true, includeIfNull: false)
  final int tokenVersion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionRevokeAllResponse &&
          other.detail == detail &&
          other.tokenVersion == tokenVersion;

  @override
  int get hashCode => detail.hashCode + tokenVersion.hashCode;

  factory SessionRevokeAllResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionRevokeAllResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SessionRevokeAllResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
