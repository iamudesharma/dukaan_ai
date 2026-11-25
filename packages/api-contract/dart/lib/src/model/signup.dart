//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'signup.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Signup {
  /// Returns a new [Signup] instance.
  Signup({required this.phone, required this.password, this.displayName});

  @JsonKey(name: r'phone', required: true, includeIfNull: false)
  final String phone;

  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @JsonKey(name: r'display_name', required: false, includeIfNull: false)
  final String? displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Signup &&
          other.phone == phone &&
          other.password == password &&
          other.displayName == displayName;

  @override
  int get hashCode => phone.hashCode + password.hashCode + displayName.hashCode;

  factory Signup.fromJson(Map<String, dynamic> json) => _$SignupFromJson(json);

  Map<String, dynamic> toJson() => _$SignupToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
