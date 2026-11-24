//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'password_change.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PasswordChange {
  /// Returns a new [PasswordChange] instance.
  PasswordChange({required this.oldPassword, required this.newPassword});

  @JsonKey(name: r'old_password', required: true, includeIfNull: false)
  final String oldPassword;

  @JsonKey(name: r'new_password', required: true, includeIfNull: false)
  final String newPassword;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordChange &&
          other.oldPassword == oldPassword &&
          other.newPassword == newPassword;

  @override
  int get hashCode => oldPassword.hashCode + newPassword.hashCode;

  factory PasswordChange.fromJson(Map<String, dynamic> json) =>
      _$PasswordChangeFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordChangeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
