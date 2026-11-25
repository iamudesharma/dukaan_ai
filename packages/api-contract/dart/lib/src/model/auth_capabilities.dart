//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_capabilities.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AuthCapabilities {
  /// Returns a new [AuthCapabilities] instance.
  AuthCapabilities({
    required this.password,

    required this.otp,

    required this.devOtp,
  });

  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final bool password;

  @JsonKey(name: r'otp', required: true, includeIfNull: false)
  final bool otp;

  @JsonKey(name: r'dev_otp', required: true, includeIfNull: false)
  final bool devOtp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthCapabilities &&
          other.password == password &&
          other.otp == otp &&
          other.devOtp == devOtp;

  @override
  int get hashCode => password.hashCode + otp.hashCode + devOtp.hashCode;

  factory AuthCapabilities.fromJson(Map<String, dynamic> json) =>
      _$AuthCapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$AuthCapabilitiesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
