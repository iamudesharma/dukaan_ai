// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_token_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AuthTokenResponseCWProxy {
  AuthTokenResponse user(AuthUser user);

  AuthTokenResponse onboardingRequired(bool onboardingRequired);

  AuthTokenResponse access(String access);

  AuthTokenResponse refresh(String refresh);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuthTokenResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuthTokenResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AuthTokenResponse call({
    AuthUser user,
    bool onboardingRequired,
    String access,
    String refresh,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAuthTokenResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAuthTokenResponse.copyWith.fieldName(...)`
class _$AuthTokenResponseCWProxyImpl implements _$AuthTokenResponseCWProxy {
  const _$AuthTokenResponseCWProxyImpl(this._value);

  final AuthTokenResponse _value;

  @override
  AuthTokenResponse user(AuthUser user) => this(user: user);

  @override
  AuthTokenResponse onboardingRequired(bool onboardingRequired) =>
      this(onboardingRequired: onboardingRequired);

  @override
  AuthTokenResponse access(String access) => this(access: access);

  @override
  AuthTokenResponse refresh(String refresh) => this(refresh: refresh);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuthTokenResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuthTokenResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AuthTokenResponse call({
    Object? user = const $CopyWithPlaceholder(),
    Object? onboardingRequired = const $CopyWithPlaceholder(),
    Object? access = const $CopyWithPlaceholder(),
    Object? refresh = const $CopyWithPlaceholder(),
  }) {
    return AuthTokenResponse(
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as AuthUser,
      onboardingRequired: onboardingRequired == const $CopyWithPlaceholder()
          ? _value.onboardingRequired
          // ignore: cast_nullable_to_non_nullable
          : onboardingRequired as bool,
      access: access == const $CopyWithPlaceholder()
          ? _value.access
          // ignore: cast_nullable_to_non_nullable
          : access as String,
      refresh: refresh == const $CopyWithPlaceholder()
          ? _value.refresh
          // ignore: cast_nullable_to_non_nullable
          : refresh as String,
    );
  }
}

extension $AuthTokenResponseCopyWith on AuthTokenResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAuthTokenResponse.copyWith(...)` or like so:`instanceOfAuthTokenResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AuthTokenResponseCWProxy get copyWith =>
      _$AuthTokenResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthTokenResponse _$AuthTokenResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AuthTokenResponse', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'user',
          'onboarding_required',
          'access',
          'refresh',
        ],
      );
      final val = AuthTokenResponse(
        user: $checkedConvert(
          'user',
          (v) => AuthUser.fromJson(v as Map<String, dynamic>),
        ),
        onboardingRequired: $checkedConvert(
          'onboarding_required',
          (v) => v as bool,
        ),
        access: $checkedConvert('access', (v) => v as String),
        refresh: $checkedConvert('refresh', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'onboardingRequired': 'onboarding_required'});

Map<String, dynamic> _$AuthTokenResponseToJson(AuthTokenResponse instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'onboarding_required': instance.onboardingRequired,
      'access': instance.access,
      'refresh': instance.refresh,
    };
