// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RefreshResponseCWProxy {
  RefreshResponse access(String access);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RefreshResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RefreshResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  RefreshResponse call({String access});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRefreshResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRefreshResponse.copyWith.fieldName(...)`
class _$RefreshResponseCWProxyImpl implements _$RefreshResponseCWProxy {
  const _$RefreshResponseCWProxyImpl(this._value);

  final RefreshResponse _value;

  @override
  RefreshResponse access(String access) => this(access: access);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RefreshResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RefreshResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  RefreshResponse call({Object? access = const $CopyWithPlaceholder()}) {
    return RefreshResponse(
      access: access == const $CopyWithPlaceholder()
          ? _value.access
          // ignore: cast_nullable_to_non_nullable
          : access as String,
    );
  }
}

extension $RefreshResponseCopyWith on RefreshResponse {
  /// Returns a callable class that can be used as follows: `instanceOfRefreshResponse.copyWith(...)` or like so:`instanceOfRefreshResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RefreshResponseCWProxy get copyWith => _$RefreshResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshResponse _$RefreshResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RefreshResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['access']);
      final val = RefreshResponse(
        access: $checkedConvert('access', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RefreshResponseToJson(RefreshResponse instance) =>
    <String, dynamic>{'access': instance.access};
