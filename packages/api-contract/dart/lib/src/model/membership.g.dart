// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MembershipCWProxy {
  Membership id(String id);

  Membership user(String user);

  Membership userName(String userName);

  Membership userPhone(String userPhone);

  Membership business(String business);

  Membership role(MembershipRoleEnum role);

  Membership locations(List<String>? locations);

  Membership isActive(bool? isActive);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Membership(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Membership(...).copyWith(id: 12, name: "My name")
  /// ````
  Membership call({
    String id,
    String user,
    String userName,
    String userPhone,
    String business,
    MembershipRoleEnum role,
    List<String>? locations,
    bool? isActive,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMembership.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMembership.copyWith.fieldName(...)`
class _$MembershipCWProxyImpl implements _$MembershipCWProxy {
  const _$MembershipCWProxyImpl(this._value);

  final Membership _value;

  @override
  Membership id(String id) => this(id: id);

  @override
  Membership user(String user) => this(user: user);

  @override
  Membership userName(String userName) => this(userName: userName);

  @override
  Membership userPhone(String userPhone) => this(userPhone: userPhone);

  @override
  Membership business(String business) => this(business: business);

  @override
  Membership role(MembershipRoleEnum role) => this(role: role);

  @override
  Membership locations(List<String>? locations) => this(locations: locations);

  @override
  Membership isActive(bool? isActive) => this(isActive: isActive);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Membership(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Membership(...).copyWith(id: 12, name: "My name")
  /// ````
  Membership call({
    Object? id = const $CopyWithPlaceholder(),
    Object? user = const $CopyWithPlaceholder(),
    Object? userName = const $CopyWithPlaceholder(),
    Object? userPhone = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? locations = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
  }) {
    return Membership(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as String,
      userName: userName == const $CopyWithPlaceholder()
          ? _value.userName
          // ignore: cast_nullable_to_non_nullable
          : userName as String,
      userPhone: userPhone == const $CopyWithPlaceholder()
          ? _value.userPhone
          // ignore: cast_nullable_to_non_nullable
          : userPhone as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as MembershipRoleEnum,
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

extension $MembershipCopyWith on Membership {
  /// Returns a callable class that can be used as follows: `instanceOfMembership.copyWith(...)` or like so:`instanceOfMembership.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MembershipCWProxy get copyWith => _$MembershipCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Membership _$MembershipFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Membership',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'user',
        'user_name',
        'user_phone',
        'business',
        'role',
      ],
    );
    final val = Membership(
      id: $checkedConvert('id', (v) => v as String),
      user: $checkedConvert('user', (v) => v as String),
      userName: $checkedConvert('user_name', (v) => v as String),
      userPhone: $checkedConvert('user_phone', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      role: $checkedConvert(
        'role',
        (v) => $enumDecode(_$MembershipRoleEnumEnumMap, v),
      ),
      locations: $checkedConvert(
        'locations',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      isActive: $checkedConvert('is_active', (v) => v as bool?),
    );
    return val;
  },
  fieldKeyMap: const {
    'userName': 'user_name',
    'userPhone': 'user_phone',
    'isActive': 'is_active',
  },
);

Map<String, dynamic> _$MembershipToJson(Membership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'user_name': instance.userName,
      'user_phone': instance.userPhone,
      'business': instance.business,
      'role': _$MembershipRoleEnumEnumMap[instance.role]!,
      'locations': ?instance.locations,
      'is_active': ?instance.isActive,
    };

const _$MembershipRoleEnumEnumMap = {
  MembershipRoleEnum.OWNER: 'OWNER',
  MembershipRoleEnum.MANAGER: 'MANAGER',
  MembershipRoleEnum.CASHIER: 'CASHIER',
};
