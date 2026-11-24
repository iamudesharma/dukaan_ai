// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patched_membership.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PatchedMembershipCWProxy {
  PatchedMembership id(String? id);

  PatchedMembership user(String? user);

  PatchedMembership business(String? business);

  PatchedMembership role(PatchedMembershipRoleEnum? role);

  PatchedMembership locations(List<String>? locations);

  PatchedMembership isActive(bool? isActive);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchedMembership(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchedMembership(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchedMembership call({
    String? id,
    String? user,
    String? business,
    PatchedMembershipRoleEnum? role,
    List<String>? locations,
    bool? isActive,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPatchedMembership.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPatchedMembership.copyWith.fieldName(...)`
class _$PatchedMembershipCWProxyImpl implements _$PatchedMembershipCWProxy {
  const _$PatchedMembershipCWProxyImpl(this._value);

  final PatchedMembership _value;

  @override
  PatchedMembership id(String? id) => this(id: id);

  @override
  PatchedMembership user(String? user) => this(user: user);

  @override
  PatchedMembership business(String? business) => this(business: business);

  @override
  PatchedMembership role(PatchedMembershipRoleEnum? role) => this(role: role);

  @override
  PatchedMembership locations(List<String>? locations) =>
      this(locations: locations);

  @override
  PatchedMembership isActive(bool? isActive) => this(isActive: isActive);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchedMembership(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchedMembership(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchedMembership call({
    Object? id = const $CopyWithPlaceholder(),
    Object? user = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? locations = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
  }) {
    return PatchedMembership(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as String?,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String?,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as PatchedMembershipRoleEnum?,
      locations: locations == const $CopyWithPlaceholder()
          ? _value.locations
          // ignore: cast_nullable_to_non_nullable
          : locations as List<String>?,
      isActive: isActive == const $CopyWithPlaceholder()
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool?,
    );
  }
}

extension $PatchedMembershipCopyWith on PatchedMembership {
  /// Returns a callable class that can be used as follows: `instanceOfPatchedMembership.copyWith(...)` or like so:`instanceOfPatchedMembership.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PatchedMembershipCWProxy get copyWith =>
      _$PatchedMembershipCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchedMembership _$PatchedMembershipFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PatchedMembership', json, ($checkedConvert) {
      final val = PatchedMembership(
        id: $checkedConvert('id', (v) => v as String?),
        user: $checkedConvert('user', (v) => v as String?),
        business: $checkedConvert('business', (v) => v as String?),
        role: $checkedConvert(
          'role',
          (v) => $enumDecodeNullable(_$PatchedMembershipRoleEnumEnumMap, v),
        ),
        locations: $checkedConvert(
          'locations',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        isActive: $checkedConvert('is_active', (v) => v as bool?),
      );
      return val;
    }, fieldKeyMap: const {'isActive': 'is_active'});

Map<String, dynamic> _$PatchedMembershipToJson(PatchedMembership instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'user': ?instance.user,
      'business': ?instance.business,
      'role': ?_$PatchedMembershipRoleEnumEnumMap[instance.role],
      'locations': ?instance.locations,
      'is_active': ?instance.isActive,
    };

const _$PatchedMembershipRoleEnumEnumMap = {
  PatchedMembershipRoleEnum.OWNER: 'OWNER',
  PatchedMembershipRoleEnum.MANAGER: 'MANAGER',
  PatchedMembershipRoleEnum.CASHIER: 'CASHIER',
};
