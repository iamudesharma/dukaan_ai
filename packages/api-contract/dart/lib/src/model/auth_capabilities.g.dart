// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_capabilities.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AuthCapabilitiesCWProxy {
  AuthCapabilities password(bool password);

  AuthCapabilities otp(bool otp);

  AuthCapabilities devOtp(bool devOtp);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuthCapabilities(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuthCapabilities(...).copyWith(id: 12, name: "My name")
  /// ````
  AuthCapabilities call({bool password, bool otp, bool devOtp});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAuthCapabilities.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAuthCapabilities.copyWith.fieldName(...)`
class _$AuthCapabilitiesCWProxyImpl implements _$AuthCapabilitiesCWProxy {
  const _$AuthCapabilitiesCWProxyImpl(this._value);

  final AuthCapabilities _value;

  @override
  AuthCapabilities password(bool password) => this(password: password);

  @override
  AuthCapabilities otp(bool otp) => this(otp: otp);

  @override
  AuthCapabilities devOtp(bool devOtp) => this(devOtp: devOtp);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuthCapabilities(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuthCapabilities(...).copyWith(id: 12, name: "My name")
  /// ````
  AuthCapabilities call({
    Object? password = const $CopyWithPlaceholder(),
    Object? otp = const $CopyWithPlaceholder(),
    Object? devOtp = const $CopyWithPlaceholder(),
  }) {
    return AuthCapabilities(
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as bool,
      otp: otp == const $CopyWithPlaceholder()
          ? _value.otp
          // ignore: cast_nullable_to_non_nullable
          : otp as bool,
      devOtp: devOtp == const $CopyWithPlaceholder()
          ? _value.devOtp
          // ignore: cast_nullable_to_non_nullable
          : devOtp as bool,
    );
  }
}

extension $AuthCapabilitiesCopyWith on AuthCapabilities {
  /// Returns a callable class that can be used as follows: `instanceOfAuthCapabilities.copyWith(...)` or like so:`instanceOfAuthCapabilities.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AuthCapabilitiesCWProxy get copyWith => _$AuthCapabilitiesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthCapabilities _$AuthCapabilitiesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AuthCapabilities', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['password', 'otp', 'dev_otp']);
      final val = AuthCapabilities(
        password: $checkedConvert('password', (v) => v as bool),
        otp: $checkedConvert('otp', (v) => v as bool),
        devOtp: $checkedConvert('dev_otp', (v) => v as bool),
      );
      return val;
    }, fieldKeyMap: const {'devOtp': 'dev_otp'});

Map<String, dynamic> _$AuthCapabilitiesToJson(AuthCapabilities instance) =>
    <String, dynamic>{
      'password': instance.password,
      'otp': instance.otp,
      'dev_otp': instance.devOtp,
    };
