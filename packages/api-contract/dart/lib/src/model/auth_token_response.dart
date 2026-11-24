//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/auth_user.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_token_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AuthTokenResponse {
  /// Returns a new [AuthTokenResponse] instance.
  AuthTokenResponse({
    required this.user,

    required this.onboardingRequired,

    required this.access,

    required this.refresh,
  });

  @JsonKey(name: r'user', required: true, includeIfNull: false)
  final AuthUser user;

  @JsonKey(name: r'onboarding_required', required: true, includeIfNull: false)
  final bool onboardingRequired;

  @JsonKey(name: r'access', required: true, includeIfNull: false)
  final String access;

  @JsonKey(name: r'refresh', required: true, includeIfNull: false)
  final String refresh;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthTokenResponse &&
          other.user == user &&
          other.onboardingRequired == onboardingRequired &&
          other.access == access &&
          other.refresh == refresh;

  @override
  int get hashCode =>
      user.hashCode +
      onboardingRequired.hashCode +
      access.hashCode +
      refresh.hashCode;

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
