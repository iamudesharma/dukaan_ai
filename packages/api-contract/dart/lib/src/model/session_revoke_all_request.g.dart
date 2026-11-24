// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_revoke_all_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SessionRevokeAllRequestCWProxy {
  SessionRevokeAllRequest password(String? password);

  SessionRevokeAllRequest currentPassword(String? currentPassword);

  SessionRevokeAllRequest otp(String? otp);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionRevokeAllRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionRevokeAllRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionRevokeAllRequest call({
    String? password,
    String? currentPassword,
    String? otp,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSessionRevokeAllRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSessionRevokeAllRequest.copyWith.fieldName(...)`
class _$SessionRevokeAllRequestCWProxyImpl
    implements _$SessionRevokeAllRequestCWProxy {
  const _$SessionRevokeAllRequestCWProxyImpl(this._value);

  final SessionRevokeAllRequest _value;

  @override
  SessionRevokeAllRequest password(String? password) =>
      this(password: password);

  @override
  SessionRevokeAllRequest currentPassword(String? currentPassword) =>
      this(currentPassword: currentPassword);

  @override
  SessionRevokeAllRequest otp(String? otp) => this(otp: otp);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionRevokeAllRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionRevokeAllRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionRevokeAllRequest call({
    Object? password = const $CopyWithPlaceholder(),
    Object? currentPassword = const $CopyWithPlaceholder(),
    Object? otp = const $CopyWithPlaceholder(),
  }) {
    return SessionRevokeAllRequest(
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String?,
      currentPassword: currentPassword == const $CopyWithPlaceholder()
          ? _value.currentPassword
          // ignore: cast_nullable_to_non_nullable
          : currentPassword as String?,
      otp: otp == const $CopyWithPlaceholder()
          ? _value.otp
          // ignore: cast_nullable_to_non_nullable
          : otp as String?,
    );
  }
}

extension $SessionRevokeAllRequestCopyWith on SessionRevokeAllRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSessionRevokeAllRequest.copyWith(...)` or like so:`instanceOfSessionRevokeAllRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SessionRevokeAllRequestCWProxy get copyWith =>
      _$SessionRevokeAllRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionRevokeAllRequest _$SessionRevokeAllRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SessionRevokeAllRequest', json, ($checkedConvert) {
  final val = SessionRevokeAllRequest(
    password: $checkedConvert('password', (v) => v as String?),
    currentPassword: $checkedConvert('current_password', (v) => v as String?),
    otp: $checkedConvert('otp', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'currentPassword': 'current_password'});

Map<String, dynamic> _$SessionRevokeAllRequestToJson(
  SessionRevokeAllRequest instance,
) => <String, dynamic>{
  'password': ?instance.password,
  'current_password': ?instance.currentPassword,
  'otp': ?instance.otp,
};
