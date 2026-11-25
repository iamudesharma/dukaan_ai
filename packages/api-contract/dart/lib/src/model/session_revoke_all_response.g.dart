// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_revoke_all_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SessionRevokeAllResponseCWProxy {
  SessionRevokeAllResponse detail(String detail);

  SessionRevokeAllResponse tokenVersion(int tokenVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionRevokeAllResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionRevokeAllResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionRevokeAllResponse call({String detail, int tokenVersion});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSessionRevokeAllResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSessionRevokeAllResponse.copyWith.fieldName(...)`
class _$SessionRevokeAllResponseCWProxyImpl
    implements _$SessionRevokeAllResponseCWProxy {
  const _$SessionRevokeAllResponseCWProxyImpl(this._value);

  final SessionRevokeAllResponse _value;

  @override
  SessionRevokeAllResponse detail(String detail) => this(detail: detail);

  @override
  SessionRevokeAllResponse tokenVersion(int tokenVersion) =>
      this(tokenVersion: tokenVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SessionRevokeAllResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SessionRevokeAllResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  SessionRevokeAllResponse call({
    Object? detail = const $CopyWithPlaceholder(),
    Object? tokenVersion = const $CopyWithPlaceholder(),
  }) {
    return SessionRevokeAllResponse(
      detail: detail == const $CopyWithPlaceholder()
          ? _value.detail
          // ignore: cast_nullable_to_non_nullable
          : detail as String,
      tokenVersion: tokenVersion == const $CopyWithPlaceholder()
          ? _value.tokenVersion
          // ignore: cast_nullable_to_non_nullable
          : tokenVersion as int,
    );
  }
}

extension $SessionRevokeAllResponseCopyWith on SessionRevokeAllResponse {
  /// Returns a callable class that can be used as follows: `instanceOfSessionRevokeAllResponse.copyWith(...)` or like so:`instanceOfSessionRevokeAllResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SessionRevokeAllResponseCWProxy get copyWith =>
      _$SessionRevokeAllResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionRevokeAllResponse _$SessionRevokeAllResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SessionRevokeAllResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['detail', 'token_version']);
  final val = SessionRevokeAllResponse(
    detail: $checkedConvert('detail', (v) => v as String),
    tokenVersion: $checkedConvert('token_version', (v) => (v as num).toInt()),
  );
  return val;
}, fieldKeyMap: const {'tokenVersion': 'token_version'});

Map<String, dynamic> _$SessionRevokeAllResponseToJson(
  SessionRevokeAllResponse instance,
) => <String, dynamic>{
  'detail': instance.detail,
  'token_version': instance.tokenVersion,
};
