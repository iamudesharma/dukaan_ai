// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SignupCWProxy {
  Signup phone(String phone);

  Signup password(String password);

  Signup displayName(String? displayName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Signup(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Signup(...).copyWith(id: 12, name: "My name")
  /// ````
  Signup call({String phone, String password, String? displayName});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSignup.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSignup.copyWith.fieldName(...)`
class _$SignupCWProxyImpl implements _$SignupCWProxy {
  const _$SignupCWProxyImpl(this._value);

  final Signup _value;

  @override
  Signup phone(String phone) => this(phone: phone);

  @override
  Signup password(String password) => this(password: password);

  @override
  Signup displayName(String? displayName) => this(displayName: displayName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Signup(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Signup(...).copyWith(id: 12, name: "My name")
  /// ````
  Signup call({
    Object? phone = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
    Object? displayName = const $CopyWithPlaceholder(),
  }) {
    return Signup(
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
      displayName: displayName == const $CopyWithPlaceholder()
          ? _value.displayName
          // ignore: cast_nullable_to_non_nullable
          : displayName as String?,
    );
  }
}

extension $SignupCopyWith on Signup {
  /// Returns a callable class that can be used as follows: `instanceOfSignup.copyWith(...)` or like so:`instanceOfSignup.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SignupCWProxy get copyWith => _$SignupCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Signup _$SignupFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Signup', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['phone', 'password']);
      final val = Signup(
        phone: $checkedConvert('phone', (v) => v as String),
        password: $checkedConvert('password', (v) => v as String),
        displayName: $checkedConvert('display_name', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'displayName': 'display_name'});

Map<String, dynamic> _$SignupToJson(Signup instance) => <String, dynamic>{
  'phone': instance.phone,
  'password': instance.password,
  'display_name': ?instance.displayName,
};
