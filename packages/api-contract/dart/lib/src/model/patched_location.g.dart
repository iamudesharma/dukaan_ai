// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patched_location.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PatchedLocationCWProxy {
  PatchedLocation id(String? id);

  PatchedLocation business(String? business);

  PatchedLocation gstRegistration(String? gstRegistration);

  PatchedLocation code(String? code);

  PatchedLocation name(String? name);

  PatchedLocation address(String? address);

  PatchedLocation stateCode(String? stateCode);

  PatchedLocation isPrimary(bool? isPrimary);

  PatchedLocation isActive(bool? isActive);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchedLocation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchedLocation(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchedLocation call({
    String? id,
    String? business,
    String? gstRegistration,
    String? code,
    String? name,
    String? address,
    String? stateCode,
    bool? isPrimary,
    bool? isActive,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPatchedLocation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPatchedLocation.copyWith.fieldName(...)`
class _$PatchedLocationCWProxyImpl implements _$PatchedLocationCWProxy {
  const _$PatchedLocationCWProxyImpl(this._value);

  final PatchedLocation _value;

  @override
  PatchedLocation id(String? id) => this(id: id);

  @override
  PatchedLocation business(String? business) => this(business: business);

  @override
  PatchedLocation gstRegistration(String? gstRegistration) =>
      this(gstRegistration: gstRegistration);

  @override
  PatchedLocation code(String? code) => this(code: code);

  @override
  PatchedLocation name(String? name) => this(name: name);

  @override
  PatchedLocation address(String? address) => this(address: address);

  @override
  PatchedLocation stateCode(String? stateCode) => this(stateCode: stateCode);

  @override
  PatchedLocation isPrimary(bool? isPrimary) => this(isPrimary: isPrimary);

  @override
  PatchedLocation isActive(bool? isActive) => this(isActive: isActive);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchedLocation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchedLocation(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchedLocation call({
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
    return PatchedLocation(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String?,
      gstRegistration: gstRegistration == const $CopyWithPlaceholder()
          ? _value.gstRegistration
          // ignore: cast_nullable_to_non_nullable
          : gstRegistration as String?,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String?,
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
          : isPrimary as bool?,
      isActive: isActive == const $CopyWithPlaceholder()
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool?,
    );
  }
}

extension $PatchedLocationCopyWith on PatchedLocation {
  /// Returns a callable class that can be used as follows: `instanceOfPatchedLocation.copyWith(...)` or like so:`instanceOfPatchedLocation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PatchedLocationCWProxy get copyWith => _$PatchedLocationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchedLocation _$PatchedLocationFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PatchedLocation',
      json,
      ($checkedConvert) {
        final val = PatchedLocation(
          id: $checkedConvert('id', (v) => v as String?),
          business: $checkedConvert('business', (v) => v as String?),
          gstRegistration: $checkedConvert(
            'gst_registration',
            (v) => v as String?,
          ),
          code: $checkedConvert('code', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String?),
          address: $checkedConvert('address', (v) => v as String?),
          stateCode: $checkedConvert('state_code', (v) => v as String?),
          isPrimary: $checkedConvert('is_primary', (v) => v as bool?),
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

Map<String, dynamic> _$PatchedLocationToJson(PatchedLocation instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'business': ?instance.business,
      'gst_registration': ?instance.gstRegistration,
      'code': ?instance.code,
      'name': ?instance.name,
      'address': ?instance.address,
      'state_code': ?instance.stateCode,
      'is_primary': ?instance.isPrimary,
      'is_active': ?instance.isActive,
    };
