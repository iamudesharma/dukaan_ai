// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PasswordResetRequestCWProxy {
  PasswordResetRequest phone(String phone);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PasswordResetRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PasswordResetRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PasswordResetRequest call({String phone});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPasswordResetRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPasswordResetRequest.copyWith.fieldName(...)`
class _$PasswordResetRequestCWProxyImpl
    implements _$PasswordResetRequestCWProxy {
  const _$PasswordResetRequestCWProxyImpl(this._value);

  final PasswordResetRequest _value;

  @override
  PasswordResetRequest phone(String phone) => this(phone: phone);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PasswordResetRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PasswordResetRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PasswordResetRequest call({Object? phone = const $CopyWithPlaceholder()}) {
    return PasswordResetRequest(
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
    );
  }
}

extension $PasswordResetRequestCopyWith on PasswordResetRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPasswordResetRequest.copyWith(...)` or like so:`instanceOfPasswordResetRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PasswordResetRequestCWProxy get copyWith =>
      _$PasswordResetRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordResetRequest _$PasswordResetRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PasswordResetRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['phone']);
  final val = PasswordResetRequest(
    phone: $checkedConvert('phone', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$PasswordResetRequestToJson(
  PasswordResetRequest instance,
) => <String, dynamic>{'phone': instance.phone};
