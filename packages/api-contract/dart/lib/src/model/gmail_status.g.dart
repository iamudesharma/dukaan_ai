// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmail_status.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GmailStatusCWProxy {
  GmailStatus connected(bool connected);

  GmailStatus email(String? email);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailStatus call({bool connected, String? email});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGmailStatus.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGmailStatus.copyWith.fieldName(...)`
class _$GmailStatusCWProxyImpl implements _$GmailStatusCWProxy {
  const _$GmailStatusCWProxyImpl(this._value);

  final GmailStatus _value;

  @override
  GmailStatus connected(bool connected) => this(connected: connected);

  @override
  GmailStatus email(String? email) => this(email: email);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailStatus call({
    Object? connected = const $CopyWithPlaceholder(),
    Object? email = const $CopyWithPlaceholder(),
  }) {
    return GmailStatus(
      connected: connected == const $CopyWithPlaceholder()
          ? _value.connected
          // ignore: cast_nullable_to_non_nullable
          : connected as bool,
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
    );
  }
}

extension $GmailStatusCopyWith on GmailStatus {
  /// Returns a callable class that can be used as follows: `instanceOfGmailStatus.copyWith(...)` or like so:`instanceOfGmailStatus.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GmailStatusCWProxy get copyWith => _$GmailStatusCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GmailStatus _$GmailStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GmailStatus', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['connected', 'email']);
      final val = GmailStatus(
        connected: $checkedConvert('connected', (v) => v as bool),
        email: $checkedConvert('email', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$GmailStatusToJson(GmailStatus instance) =>
    <String, dynamic>{'connected': instance.connected, 'email': instance.email};
