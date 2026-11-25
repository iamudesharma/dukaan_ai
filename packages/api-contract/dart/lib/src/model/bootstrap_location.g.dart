// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_location.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BootstrapLocationCWProxy {
  BootstrapLocation id(String id);

  BootstrapLocation name(String name);

  BootstrapLocation code(String code);

  BootstrapLocation stateCode(String stateCode);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BootstrapLocation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BootstrapLocation(...).copyWith(id: 12, name: "My name")
  /// ````
  BootstrapLocation call({
    String id,
    String name,
    String code,
    String stateCode,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBootstrapLocation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBootstrapLocation.copyWith.fieldName(...)`
class _$BootstrapLocationCWProxyImpl implements _$BootstrapLocationCWProxy {
  const _$BootstrapLocationCWProxyImpl(this._value);

  final BootstrapLocation _value;

  @override
  BootstrapLocation id(String id) => this(id: id);

  @override
  BootstrapLocation name(String name) => this(name: name);

  @override
  BootstrapLocation code(String code) => this(code: code);

  @override
  BootstrapLocation stateCode(String stateCode) => this(stateCode: stateCode);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BootstrapLocation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BootstrapLocation(...).copyWith(id: 12, name: "My name")
  /// ````
  BootstrapLocation call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? stateCode = const $CopyWithPlaceholder(),
  }) {
    return BootstrapLocation(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      stateCode: stateCode == const $CopyWithPlaceholder()
          ? _value.stateCode
          // ignore: cast_nullable_to_non_nullable
          : stateCode as String,
    );
  }
}

extension $BootstrapLocationCopyWith on BootstrapLocation {
  /// Returns a callable class that can be used as follows: `instanceOfBootstrapLocation.copyWith(...)` or like so:`instanceOfBootstrapLocation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BootstrapLocationCWProxy get copyWith =>
      _$BootstrapLocationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BootstrapLocation _$BootstrapLocationFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BootstrapLocation', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'name', 'code', 'state_code'],
      );
      final val = BootstrapLocation(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
        stateCode: $checkedConvert('state_code', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'stateCode': 'state_code'});

Map<String, dynamic> _$BootstrapLocationToJson(BootstrapLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'state_code': instance.stateCode,
    };
