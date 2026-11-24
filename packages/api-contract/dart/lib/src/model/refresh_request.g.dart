// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RefreshRequestCWProxy {
  RefreshRequest refresh(String refresh);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RefreshRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RefreshRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RefreshRequest call({String refresh});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRefreshRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRefreshRequest.copyWith.fieldName(...)`
class _$RefreshRequestCWProxyImpl implements _$RefreshRequestCWProxy {
  const _$RefreshRequestCWProxyImpl(this._value);

  final RefreshRequest _value;

  @override
  RefreshRequest refresh(String refresh) => this(refresh: refresh);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RefreshRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RefreshRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RefreshRequest call({Object? refresh = const $CopyWithPlaceholder()}) {
    return RefreshRequest(
      refresh: refresh == const $CopyWithPlaceholder()
          ? _value.refresh
          // ignore: cast_nullable_to_non_nullable
          : refresh as String,
    );
  }
}

extension $RefreshRequestCopyWith on RefreshRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRefreshRequest.copyWith(...)` or like so:`instanceOfRefreshRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RefreshRequestCWProxy get copyWith => _$RefreshRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefreshRequest _$RefreshRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RefreshRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['refresh']);
      final val = RefreshRequest(
        refresh: $checkedConvert('refresh', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RefreshRequestToJson(RefreshRequest instance) =>
    <String, dynamic>{'refresh': instance.refresh};
