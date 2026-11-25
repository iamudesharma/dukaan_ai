//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gmail_status.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GmailStatus {
  /// Returns a new [GmailStatus] instance.
  GmailStatus({required this.connected, required this.email});

  @JsonKey(name: r'connected', required: true, includeIfNull: false)
  final bool connected;

  @JsonKey(name: r'email', required: true, includeIfNull: true)
  final String? email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GmailStatus &&
          other.connected == connected &&
          other.email == email;

  @override
  int get hashCode => connected.hashCode + (email == null ? 0 : email.hashCode);

  factory GmailStatus.fromJson(Map<String, dynamic> json) =>
      _$GmailStatusFromJson(json);

  Map<String, dynamic> toJson() => _$GmailStatusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
