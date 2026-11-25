//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'otp_send.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OtpSend {
  /// Returns a new [OtpSend] instance.
  OtpSend({required this.phone});

  @JsonKey(name: r'phone', required: true, includeIfNull: false)
  final String phone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OtpSend && other.phone == phone;

  @override
  int get hashCode => phone.hashCode;

  factory OtpSend.fromJson(Map<String, dynamic> json) =>
      _$OtpSendFromJson(json);

  Map<String, dynamic> toJson() => _$OtpSendToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
