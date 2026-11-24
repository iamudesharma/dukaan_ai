// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LoginCWProxy {
  Login phone(String phone);

  Login password(String password);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Login(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Login(...).copyWith(id: 12, name: "My name")
  /// ````
  Login call({String phone, String password});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLogin.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLogin.copyWith.fieldName(...)`
class _$LoginCWProxyImpl implements _$LoginCWProxy {
  const _$LoginCWProxyImpl(this._value);

  final Login _value;

  @override
  Login phone(String phone) => this(phone: phone);

  @override
  Login password(String password) => this(password: password);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Login(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Login(...).copyWith(id: 12, name: "My name")
  /// ````
  Login call({
    Object? phone = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
  }) {
    return Login(
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
    );
  }
}

extension $LoginCopyWith on Login {
  /// Returns a callable class that can be used as follows: `instanceOfLogin.copyWith(...)` or like so:`instanceOfLogin.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LoginCWProxy get copyWith => _$LoginCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Login _$LoginFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Login', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['phone', 'password']);
      final val = Login(
        phone: $checkedConvert('phone', (v) => v as String),
        password: $checkedConvert('password', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LoginToJson(Login instance) => <String, dynamic>{
  'phone': instance.phone,
  'password': instance.password,
};
