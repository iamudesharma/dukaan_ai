// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_send.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OtpSendCWProxy {
  OtpSend phone(String phone);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpSend(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpSend(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpSend call({String phone});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOtpSend.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOtpSend.copyWith.fieldName(...)`
class _$OtpSendCWProxyImpl implements _$OtpSendCWProxy {
  const _$OtpSendCWProxyImpl(this._value);

  final OtpSend _value;

  @override
  OtpSend phone(String phone) => this(phone: phone);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OtpSend(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OtpSend(...).copyWith(id: 12, name: "My name")
  /// ````
  OtpSend call({Object? phone = const $CopyWithPlaceholder()}) {
    return OtpSend(
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
    );
  }
}

extension $OtpSendCopyWith on OtpSend {
  /// Returns a callable class that can be used as follows: `instanceOfOtpSend.copyWith(...)` or like so:`instanceOfOtpSend.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OtpSendCWProxy get copyWith => _$OtpSendCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpSend _$OtpSendFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OtpSend', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['phone']);
      final val = OtpSend(phone: $checkedConvert('phone', (v) => v as String));
      return val;
    });

Map<String, dynamic> _$OtpSendToJson(OtpSend instance) => <String, dynamic>{
  'phone': instance.phone,
};
