// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmail_connect.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GmailConnectCWProxy {
  GmailConnect authorizationUrl(String authorizationUrl);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailConnect(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailConnect(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailConnect call({String authorizationUrl});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGmailConnect.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGmailConnect.copyWith.fieldName(...)`
class _$GmailConnectCWProxyImpl implements _$GmailConnectCWProxy {
  const _$GmailConnectCWProxyImpl(this._value);

  final GmailConnect _value;

  @override
  GmailConnect authorizationUrl(String authorizationUrl) =>
      this(authorizationUrl: authorizationUrl);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailConnect(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailConnect(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailConnect call({Object? authorizationUrl = const $CopyWithPlaceholder()}) {
    return GmailConnect(
      authorizationUrl: authorizationUrl == const $CopyWithPlaceholder()
          ? _value.authorizationUrl
          // ignore: cast_nullable_to_non_nullable
          : authorizationUrl as String,
    );
  }
}

extension $GmailConnectCopyWith on GmailConnect {
  /// Returns a callable class that can be used as follows: `instanceOfGmailConnect.copyWith(...)` or like so:`instanceOfGmailConnect.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GmailConnectCWProxy get copyWith => _$GmailConnectCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GmailConnect _$GmailConnectFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GmailConnect', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['authorization_url']);
      final val = GmailConnect(
        authorizationUrl: $checkedConvert(
          'authorization_url',
          (v) => v as String,
        ),
      );
      return val;
    }, fieldKeyMap: const {'authorizationUrl': 'authorization_url'});

Map<String, dynamic> _$GmailConnectToJson(GmailConnect instance) =>
    <String, dynamic>{'authorization_url': instance.authorizationUrl};
