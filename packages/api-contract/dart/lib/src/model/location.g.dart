// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LocationCWProxy {
  Location id(String id);

  Location business(String business);

  Location gstRegistration(String? gstRegistration);

  Location code(String code);

  Location name(String name);

  Location address(String? address);

  Location stateCode(String? stateCode);

  Location isPrimary(bool isPrimary);

  Location isActive(bool? isActive);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Location(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Location(...).copyWith(id: 12, name: "My name")
  /// ````
  Location call({
    String id,
    String business,
    String? gstRegistration,
    String code,
    String name,
    String? address,
    String? stateCode,
    bool isPrimary,
    bool? isActive,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLocation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLocation.copyWith.fieldName(...)`
class _$LocationCWProxyImpl implements _$LocationCWProxy {
  const _$LocationCWProxyImpl(this._value);

  final Location _value;

  @override
  Location id(String id) => this(id: id);

  @override
  Location business(String business) => this(business: business);

  @override
  Location gstRegistration(String? gstRegistration) =>
      this(gstRegistration: gstRegistration);

  @override
  Location code(String code) => this(code: code);

  @override
  Location name(String name) => this(name: name);

  @override
  Location address(String? address) => this(address: address);

  @override
  Location stateCode(String? stateCode) => this(stateCode: stateCode);

  @override
  Location isPrimary(bool isPrimary) => this(isPrimary: isPrimary);

  @override
  Location isActive(bool? isActive) => this(isActive: isActive);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Location(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Location(...).copyWith(id: 12, name: "My name")
  /// ````
  Location call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? gstRegistration = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? address = const $CopyWithPlaceholder(),
    Object? stateCode = const $CopyWithPlaceholder(),
    Object? isPrimary = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
  }) {
    return Location(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      gstRegistration: gstRegistration == const $CopyWithPlaceholder()
          ? _value.gstRegistration
          // ignore: cast_nullable_to_non_nullable
          : gstRegistration as String?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      address: address == const $CopyWithPlaceholder()
          ? _value.address
          // ignore: cast_nullable_to_non_nullable
          : address as String?,
      stateCode: stateCode == const $CopyWithPlaceholder()
          ? _value.stateCode
          // ignore: cast_nullable_to_non_nullable
          : stateCode as String?,
      isPrimary: isPrimary == const $CopyWithPlaceholder()
          ? _value.isPrimary
          // ignore: cast_nullable_to_non_nullable
          : isPrimary as bool,
      isActive: isActive == const $CopyWithPlaceholder()
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool?,
    );
  }
}

extension $LocationCopyWith on Location {
  /// Returns a callable class that can be used as follows: `instanceOfLocation.copyWith(...)` or like so:`instanceOfLocation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LocationCWProxy get copyWith => _$LocationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Location',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['id', 'business', 'code', 'name', 'is_primary'],
    );
    final val = Location(
      id: $checkedConvert('id', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      gstRegistration: $checkedConvert('gst_registration', (v) => v as String?),
      code: $checkedConvert('code', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      address: $checkedConvert('address', (v) => v as String?),
      stateCode: $checkedConvert('state_code', (v) => v as String?),
      isPrimary: $checkedConvert('is_primary', (v) => v as bool),
      isActive: $checkedConvert('is_active', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'gstRegistration': 'gst_registration',
    'stateCode': 'state_code',
    'isPrimary': 'is_primary',
    'isActive': 'is_active',
  },
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'id': instance.id,
  'business': instance.business,
  'gst_registration': ?instance.gstRegistration,
  'code': instance.code,
  'name': instance.name,
  'address': ?instance.address,
  'state_code': ?instance.stateCode,
  'is_primary': instance.isPrimary,
  'is_active': ?instance.isActive,
};
