// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BootstrapCWProxy {
  Bootstrap user(BootstrapUser user);

  Bootstrap business(BootstrapBusiness business);

  Bootstrap locations(List<BootstrapLocation> locations);

  Bootstrap permissions(List<String> permissions);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Bootstrap(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Bootstrap(...).copyWith(id: 12, name: "My name")
  /// ````
  Bootstrap call({
    BootstrapUser user,
    BootstrapBusiness business,
    List<BootstrapLocation> locations,
    List<String> permissions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBootstrap.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBootstrap.copyWith.fieldName(...)`
class _$BootstrapCWProxyImpl implements _$BootstrapCWProxy {
  const _$BootstrapCWProxyImpl(this._value);

  final Bootstrap _value;

  @override
  Bootstrap user(BootstrapUser user) => this(user: user);

  @override
  Bootstrap business(BootstrapBusiness business) => this(business: business);

  @override
  Bootstrap locations(List<BootstrapLocation> locations) =>
      this(locations: locations);

  @override
  Bootstrap permissions(List<String> permissions) =>
      this(permissions: permissions);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Bootstrap(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Bootstrap(...).copyWith(id: 12, name: "My name")
  /// ````
  Bootstrap call({
    Object? user = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? locations = const $CopyWithPlaceholder(),
    Object? permissions = const $CopyWithPlaceholder(),
  }) {
    return Bootstrap(
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as BootstrapUser,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as BootstrapBusiness,
      locations: locations == const $CopyWithPlaceholder()
          ? _value.locations
          // ignore: cast_nullable_to_non_nullable
          : locations as List<BootstrapLocation>,
      permissions: permissions == const $CopyWithPlaceholder()
          ? _value.permissions
          // ignore: cast_nullable_to_non_nullable
          : permissions as List<String>,
    );
  }
}

extension $BootstrapCopyWith on Bootstrap {
  /// Returns a callable class that can be used as follows: `instanceOfBootstrap.copyWith(...)` or like so:`instanceOfBootstrap.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BootstrapCWProxy get copyWith => _$BootstrapCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bootstrap _$BootstrapFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Bootstrap', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['user', 'business', 'locations', 'permissions'],
      );
      final val = Bootstrap(
        user: $checkedConvert(
          'user',
          (v) => BootstrapUser.fromJson(v as Map<String, dynamic>),
        ),
        business: $checkedConvert(
          'business',
          (v) => BootstrapBusiness.fromJson(v as Map<String, dynamic>),
        ),
        locations: $checkedConvert(
          'locations',
          (v) => (v as List<dynamic>)
              .map((e) => BootstrapLocation.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        permissions: $checkedConvert(
          'permissions',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BootstrapToJson(Bootstrap instance) => <String, dynamic>{
  'user': instance.user.toJson(),
  'business': instance.business.toJson(),
  'locations': instance.locations.map((e) => e.toJson()).toList(),
  'permissions': instance.permissions,
};
