// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_device.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NotificationDeviceCWProxy {
  NotificationDevice id(String id);

  NotificationDevice business(String business);

  NotificationDevice location(String? location);

  NotificationDevice platform(NotificationDevicePlatformEnum platform);

  NotificationDevice status(NotificationDeviceStatusEnum status);

  NotificationDevice tokenSuffix(String tokenSuffix);

  NotificationDevice lastSeenAt(DateTime lastSeenAt);

  NotificationDevice unregisteredAt(DateTime? unregisteredAt);

  NotificationDevice metadata(Object? metadata);

  NotificationDevice createdAt(DateTime createdAt);

  NotificationDevice updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationDevice(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationDevice(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationDevice call({
    String id,
    String business,
    String? location,
    NotificationDevicePlatformEnum platform,
    NotificationDeviceStatusEnum status,
    String tokenSuffix,
    DateTime lastSeenAt,
    DateTime? unregisteredAt,
    Object? metadata,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNotificationDevice.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNotificationDevice.copyWith.fieldName(...)`
class _$NotificationDeviceCWProxyImpl implements _$NotificationDeviceCWProxy {
  const _$NotificationDeviceCWProxyImpl(this._value);

  final NotificationDevice _value;

  @override
  NotificationDevice id(String id) => this(id: id);

  @override
  NotificationDevice business(String business) => this(business: business);

  @override
  NotificationDevice location(String? location) => this(location: location);

  @override
  NotificationDevice platform(NotificationDevicePlatformEnum platform) =>
      this(platform: platform);

  @override
  NotificationDevice status(NotificationDeviceStatusEnum status) =>
      this(status: status);

  @override
  NotificationDevice tokenSuffix(String tokenSuffix) =>
      this(tokenSuffix: tokenSuffix);

  @override
  NotificationDevice lastSeenAt(DateTime lastSeenAt) =>
      this(lastSeenAt: lastSeenAt);

  @override
  NotificationDevice unregisteredAt(DateTime? unregisteredAt) =>
      this(unregisteredAt: unregisteredAt);

  @override
  NotificationDevice metadata(Object? metadata) => this(metadata: metadata);

  @override
  NotificationDevice createdAt(DateTime createdAt) =>
      this(createdAt: createdAt);

  @override
  NotificationDevice updatedAt(DateTime updatedAt) =>
      this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationDevice(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationDevice(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationDevice call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? platform = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? tokenSuffix = const $CopyWithPlaceholder(),
    Object? lastSeenAt = const $CopyWithPlaceholder(),
    Object? unregisteredAt = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return NotificationDevice(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as String?,
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as NotificationDevicePlatformEnum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as NotificationDeviceStatusEnum,
      tokenSuffix: tokenSuffix == const $CopyWithPlaceholder()
          ? _value.tokenSuffix
          // ignore: cast_nullable_to_non_nullable
          : tokenSuffix as String,
      lastSeenAt: lastSeenAt == const $CopyWithPlaceholder()
          ? _value.lastSeenAt
          // ignore: cast_nullable_to_non_nullable
          : lastSeenAt as DateTime,
      unregisteredAt: unregisteredAt == const $CopyWithPlaceholder()
          ? _value.unregisteredAt
          // ignore: cast_nullable_to_non_nullable
          : unregisteredAt as DateTime?,
      metadata: metadata == const $CopyWithPlaceholder()
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Object?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $NotificationDeviceCopyWith on NotificationDevice {
  /// Returns a callable class that can be used as follows: `instanceOfNotificationDevice.copyWith(...)` or like so:`instanceOfNotificationDevice.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NotificationDeviceCWProxy get copyWith =>
      _$NotificationDeviceCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDevice _$NotificationDeviceFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'NotificationDevice',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'business',
            'location',
            'platform',
            'status',
            'token_suffix',
            'last_seen_at',
            'unregistered_at',
            'metadata',
            'created_at',
            'updated_at',
          ],
        );
        final val = NotificationDevice(
          id: $checkedConvert('id', (v) => v as String),
          business: $checkedConvert('business', (v) => v as String),
          location: $checkedConvert('location', (v) => v as String?),
          platform: $checkedConvert(
            'platform',
            (v) => $enumDecode(_$NotificationDevicePlatformEnumEnumMap, v),
          ),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$NotificationDeviceStatusEnumEnumMap, v),
          ),
          tokenSuffix: $checkedConvert('token_suffix', (v) => v as String),
          lastSeenAt: $checkedConvert(
            'last_seen_at',
            (v) => DateTime.parse(v as String),
          ),
          unregisteredAt: $checkedConvert(
            'unregistered_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          metadata: $checkedConvert('metadata', (v) => v),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'tokenSuffix': 'token_suffix',
        'lastSeenAt': 'last_seen_at',
        'unregisteredAt': 'unregistered_at',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$NotificationDeviceToJson(NotificationDevice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business': instance.business,
      'location': instance.location,
      'platform': _$NotificationDevicePlatformEnumEnumMap[instance.platform]!,
      'status': _$NotificationDeviceStatusEnumEnumMap[instance.status]!,
      'token_suffix': instance.tokenSuffix,
      'last_seen_at': instance.lastSeenAt.toIso8601String(),
      'unregistered_at': instance.unregisteredAt?.toIso8601String(),
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$NotificationDevicePlatformEnumEnumMap = {
  NotificationDevicePlatformEnum.ANDROID: 'ANDROID',
  NotificationDevicePlatformEnum.IOS: 'IOS',
  NotificationDevicePlatformEnum.WEB: 'WEB',
};

const _$NotificationDeviceStatusEnumEnumMap = {
  NotificationDeviceStatusEnum.ACTIVE: 'ACTIVE',
  NotificationDeviceStatusEnum.DISABLED: 'DISABLED',
};
