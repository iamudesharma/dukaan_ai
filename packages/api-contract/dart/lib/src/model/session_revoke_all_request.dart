//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_revoke_all_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SessionRevokeAllRequest {
  /// Returns a new [SessionRevokeAllRequest] instance.
  SessionRevokeAllRequest({this.password, this.currentPassword, this.otp});

  @JsonKey(name: r'password', required: false, includeIfNull: false)
  final String? password;

  @JsonKey(name: r'current_password', required: false, includeIfNull: false)
  final String? currentPassword;

  @JsonKey(name: r'otp', required: false, includeIfNull: false)
  final String? otp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionRevokeAllRequest &&
          other.password == password &&
          other.currentPassword == currentPassword &&
          other.otp == otp;

  @override
  int get hashCode =>
      password.hashCode + currentPassword.hashCode + otp.hashCode;

  factory SessionRevokeAllRequest.fromJson(Map<String, dynamic> json) =>
      _$SessionRevokeAllRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SessionRevokeAllRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
