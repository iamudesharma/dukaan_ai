//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gmail_connect.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GmailConnect {
  /// Returns a new [GmailConnect] instance.
  GmailConnect({required this.authorizationUrl});

  @JsonKey(name: r'authorization_url', required: true, includeIfNull: false)
  final String authorizationUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GmailConnect && other.authorizationUrl == authorizationUrl;

  @override
  int get hashCode => authorizationUrl.hashCode;

  factory GmailConnect.fromJson(Map<String, dynamic> json) =>
      _$GmailConnectFromJson(json);

  Map<String, dynamic> toJson() => _$GmailConnectToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
