// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_user.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BootstrapUserCWProxy {
  BootstrapUser id(String id);

  BootstrapUser name(String name);

  BootstrapUser phone(String phone);

  BootstrapUser role(BootstrapUserRoleEnum role);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BootstrapUser(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BootstrapUser(...).copyWith(id: 12, name: "My name")
  /// ````
  BootstrapUser call({
    String id,
    String name,
    String phone,
    BootstrapUserRoleEnum role,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBootstrapUser.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBootstrapUser.copyWith.fieldName(...)`
class _$BootstrapUserCWProxyImpl implements _$BootstrapUserCWProxy {
  const _$BootstrapUserCWProxyImpl(this._value);

  final BootstrapUser _value;

  @override
  BootstrapUser id(String id) => this(id: id);

  @override
  BootstrapUser name(String name) => this(name: name);

  @override
  BootstrapUser phone(String phone) => this(phone: phone);

  @override
  BootstrapUser role(BootstrapUserRoleEnum role) => this(role: role);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BootstrapUser(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BootstrapUser(...).copyWith(id: 12, name: "My name")
  /// ````
  BootstrapUser call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
  }) {
    return BootstrapUser(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as BootstrapUserRoleEnum,
    );
  }
}

extension $BootstrapUserCopyWith on BootstrapUser {
  /// Returns a callable class that can be used as follows: `instanceOfBootstrapUser.copyWith(...)` or like so:`instanceOfBootstrapUser.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BootstrapUserCWProxy get copyWith => _$BootstrapUserCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BootstrapUser _$BootstrapUserFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BootstrapUser', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name', 'phone', 'role']);
      final val = BootstrapUser(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        phone: $checkedConvert('phone', (v) => v as String),
        role: $checkedConvert(
          'role',
          (v) => $enumDecode(_$BootstrapUserRoleEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BootstrapUserToJson(BootstrapUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'role': _$BootstrapUserRoleEnumEnumMap[instance.role]!,
    };

const _$BootstrapUserRoleEnumEnumMap = {
  BootstrapUserRoleEnum.OWNER: 'OWNER',
  BootstrapUserRoleEnum.MANAGER: 'MANAGER',
  BootstrapUserRoleEnum.CASHIER: 'CASHIER',
};
