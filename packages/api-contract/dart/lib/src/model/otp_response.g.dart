// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OtpResponseCWProxy {
  OtpResponse detail(String detail);

  OtpResponse phone(String phone);

  OtpResponse devOtp(String? devOtp);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpResponse call({String detail, String phone, String? devOtp});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOtpResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOtpResponse.copyWith.fieldName(...)`
class _$OtpResponseCWProxyImpl implements _$OtpResponseCWProxy {
  const _$OtpResponseCWProxyImpl(this._value);

  final OtpResponse _value;

  @override
  OtpResponse detail(String detail) => this(detail: detail);

  @override
  OtpResponse phone(String phone) => this(phone: phone);

  @override
  OtpResponse devOtp(String? devOtp) => this(devOtp: devOtp);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpResponse call({
    Object? detail = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? devOtp = const $CopyWithPlaceholder(),
  }) {
    return OtpResponse(
      detail: detail == const $CopyWithPlaceholder()
          ? _value.detail
          // ignore: cast_nullable_to_non_nullable
          : detail as String,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      devOtp: devOtp == const $CopyWithPlaceholder()
          ? _value.devOtp
          // ignore: cast_nullable_to_non_nullable
          : devOtp as String?,
    );
  }
}

extension $OtpResponseCopyWith on OtpResponse {
  /// Returns a callable class that can be used as follows: `instanceOfOtpResponse.copyWith(...)` or like so:`instanceOfOtpResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OtpResponseCWProxy get copyWith => _$OtpResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpResponse _$OtpResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OtpResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['detail', 'phone']);
      final val = OtpResponse(
        detail: $checkedConvert('detail', (v) => v as String),
        phone: $checkedConvert('phone', (v) => v as String),
        devOtp: $checkedConvert('dev_otp', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'devOtp': 'dev_otp'});

Map<String, dynamic> _$OtpResponseToJson(OtpResponse instance) =>
    <String, dynamic>{
      'detail': instance.detail,
      'phone': instance.phone,
      'dev_otp': ?instance.devOtp,
    };
