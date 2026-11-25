// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_change.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PasswordChangeCWProxy {
  PasswordChange oldPassword(String oldPassword);

  PasswordChange newPassword(String newPassword);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PasswordChange(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PasswordChange(...).copyWith(id: 12, name: "My name")
  /// ````
  PasswordChange call({String oldPassword, String newPassword});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPasswordChange.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPasswordChange.copyWith.fieldName(...)`
class _$PasswordChangeCWProxyImpl implements _$PasswordChangeCWProxy {
  const _$PasswordChangeCWProxyImpl(this._value);

  final PasswordChange _value;

  @override
  PasswordChange oldPassword(String oldPassword) =>
      this(oldPassword: oldPassword);

  @override
  PasswordChange newPassword(String newPassword) =>
      this(newPassword: newPassword);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PasswordChange(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PasswordChange(...).copyWith(id: 12, name: "My name")
  /// ````
  PasswordChange call({
    Object? oldPassword = const $CopyWithPlaceholder(),
    Object? newPassword = const $CopyWithPlaceholder(),
  }) {
    return PasswordChange(
      oldPassword: oldPassword == const $CopyWithPlaceholder()
          ? _value.oldPassword
          // ignore: cast_nullable_to_non_nullable
          : oldPassword as String,
      newPassword: newPassword == const $CopyWithPlaceholder()
          ? _value.newPassword
          // ignore: cast_nullable_to_non_nullable
          : newPassword as String,
    );
  }
}

extension $PasswordChangeCopyWith on PasswordChange {
  /// Returns a callable class that can be used as follows: `instanceOfPasswordChange.copyWith(...)` or like so:`instanceOfPasswordChange.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PasswordChangeCWProxy get copyWith => _$PasswordChangeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordChange _$PasswordChangeFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PasswordChange',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['old_password', 'new_password']);
        final val = PasswordChange(
          oldPassword: $checkedConvert('old_password', (v) => v as String),
          newPassword: $checkedConvert('new_password', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'oldPassword': 'old_password',
        'newPassword': 'new_password',
      },
    );

Map<String, dynamic> _$PasswordChangeToJson(PasswordChange instance) =>
    <String, dynamic>{
      'old_password': instance.oldPassword,
      'new_password': instance.newPassword,
    };
