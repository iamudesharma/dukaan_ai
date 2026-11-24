// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verify.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OtpVerifyCWProxy {
  OtpVerify phone(String phone);

  OtpVerify otp(String otp);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpVerify(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpVerify(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpVerify call({String phone, String otp});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOtpVerify.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOtpVerify.copyWith.fieldName(...)`
class _$OtpVerifyCWProxyImpl implements _$OtpVerifyCWProxy {
  const _$OtpVerifyCWProxyImpl(this._value);

  final OtpVerify _value;

  @override
  OtpVerify phone(String phone) => this(phone: phone);

  @override
  OtpVerify otp(String otp) => this(otp: otp);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpVerify(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpVerify(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpVerify call({
    Object? phone = const $CopyWithPlaceholder(),
    Object? otp = const $CopyWithPlaceholder(),
  }) {
    return OtpVerify(
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      otp: otp == const $CopyWithPlaceholder()
          ? _value.otp
          // ignore: cast_nullable_to_non_nullable
          : otp as String,
    );
  }
}

extension $OtpVerifyCopyWith on OtpVerify {
  /// Returns a callable class that can be used as follows: `instanceOfOtpVerify.copyWith(...)` or like so:`instanceOfOtpVerify.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OtpVerifyCWProxy get copyWith => _$OtpVerifyCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpVerify _$OtpVerifyFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OtpVerify', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['phone', 'otp']);
      final val = OtpVerify(
        phone: $checkedConvert('phone', (v) => v as String),
        otp: $checkedConvert('otp', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$OtpVerifyToJson(OtpVerify instance) => <String, dynamic>{
  'phone': instance.phone,
  'otp': instance.otp,
};
