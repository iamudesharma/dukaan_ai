//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'otp_verify.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OtpVerify {
  /// Returns a new [OtpVerify] instance.
  OtpVerify({required this.phone, required this.otp});

  @JsonKey(name: r'phone', required: true, includeIfNull: false)
  final String phone;

  @JsonKey(name: r'otp', required: true, includeIfNull: false)
  final String otp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpVerify && other.phone == phone && other.otp == otp;

  @override
  int get hashCode => phone.hashCode + otp.hashCode;

  factory OtpVerify.fromJson(Map<String, dynamic> json) =>
      _$OtpVerifyFromJson(json);

  Map<String, dynamic> toJson() => _$OtpVerifyToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
