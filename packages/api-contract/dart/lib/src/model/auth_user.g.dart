// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AuthUserCWProxy {
  AuthUser id(String id);

  AuthUser phone(String phone);

  AuthUser displayName(String displayName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuthUser(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuthUser(...).copyWith(id: 12, name: "My name")
  /// ````
  AuthUser call({String id, String phone, String displayName});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAuthUser.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAuthUser.copyWith.fieldName(...)`
class _$AuthUserCWProxyImpl implements _$AuthUserCWProxy {
  const _$AuthUserCWProxyImpl(this._value);

  final AuthUser _value;

  @override
  AuthUser id(String id) => this(id: id);

  @override
  AuthUser phone(String phone) => this(phone: phone);

  @override
  AuthUser displayName(String displayName) => this(displayName: displayName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuthUser(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuthUser(...).copyWith(id: 12, name: "My name")
  /// ````
  AuthUser call({
    Object? id = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
  }) {
    return AuthUser(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String,
    );
  }
}

extension $AuthUserCopyWith on AuthUser {
  /// Returns a callable class that can be used as follows: `instanceOfAuthUser.copyWith(...)` or like so:`instanceOfAuthUser.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AuthUserCWProxy get copyWith => _$AuthUserCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AuthUser', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'phone', 'display_name']);
      final val = AuthUser(
        id: $checkedConvert('id', (v) => v as String),
        phone: $checkedConvert('phone', (v) => v as String),
        displayName: $checkedConvert('display_name', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'displayName': 'display_name'});

Map<String, dynamic> _$AuthUserToJson(AuthUser instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'display_name': instance.displayName,
};
