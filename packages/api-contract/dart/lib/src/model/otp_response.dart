//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'otp_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OtpResponse {
  /// Returns a new [OtpResponse] instance.
  OtpResponse({required this.detail, required this.phone, this.devOtp});

  @JsonKey(name: r'detail', required: true, includeIfNull: false)
  final String detail;

  @JsonKey(name: r'phone', required: true, includeIfNull: false)
  final String phone;

  /// Local-development code only.
  @JsonKey(name: r'dev_otp', required: false, includeIfNull: false)
  final String? devOtp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpResponse &&
          other.detail == detail &&
          other.phone == phone &&
          other.devOtp == devOtp;

  @override
  int get hashCode => detail.hashCode + phone.hashCode + devOtp.hashCode;

  factory OtpResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OtpResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
