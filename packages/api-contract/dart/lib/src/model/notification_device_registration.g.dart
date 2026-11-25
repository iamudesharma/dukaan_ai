// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_device_registration.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$NotificationDeviceRegistrationCWProxy {
  NotificationDeviceRegistration businessId(String businessId);

  NotificationDeviceRegistration locationId(String? locationId);

  NotificationDeviceRegistration fcmToken(String fcmToken);

  NotificationDeviceRegistration platform(
    NotificationDeviceRegistrationPlatformEnum? platform,
  );

  NotificationDeviceRegistration metadata(Object? metadata);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationDeviceRegistration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationDeviceRegistration(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationDeviceRegistration call({
    String businessId,
    String? locationId,
    String fcmToken,
    NotificationDeviceRegistrationPlatformEnum? platform,
    Object? metadata,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfNotificationDeviceRegistration.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfNotificationDeviceRegistration.copyWith.fieldName(...)`
class _$NotificationDeviceRegistrationCWProxyImpl
    implements _$NotificationDeviceRegistrationCWProxy {
  const _$NotificationDeviceRegistrationCWProxyImpl(this._value);

  final NotificationDeviceRegistration _value;

  @override
  NotificationDeviceRegistration businessId(String businessId) =>
      this(businessId: businessId);

  @override
  NotificationDeviceRegistration locationId(String? locationId) =>
      this(locationId: locationId);

  @override
  NotificationDeviceRegistration fcmToken(String fcmToken) =>
      this(fcmToken: fcmToken);

  @override
  NotificationDeviceRegistration platform(
    NotificationDeviceRegistrationPlatformEnum? platform,
  ) => this(platform: platform);

  @override
  NotificationDeviceRegistration metadata(Object? metadata) =>
      this(metadata: metadata);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `NotificationDeviceRegistration(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// NotificationDeviceRegistration(...).copyWith(id: 12, name: "My name")
  /// ````
  NotificationDeviceRegistration call({
    Object? businessId = const $CopyWithPlaceholder(),
    Object? locationId = const $CopyWithPlaceholder(),
    Object? fcmToken = const $CopyWithPlaceholder(),
    Object? platform = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
  }) {
    return NotificationDeviceRegistration(
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      locationId: locationId == const $CopyWithPlaceholder()
          ? _value.locationId
          // ignore: cast_nullable_to_non_nullable
          : locationId as String?,
      fcmToken: fcmToken == const $CopyWithPlaceholder()
          ? _value.fcmToken
          // ignore: cast_nullable_to_non_nullable
          : fcmToken as String,
      platform: platform == const $CopyWithPlaceholder()
          ? _value.platform
          // ignore: cast_nullable_to_non_nullable
          : platform as NotificationDeviceRegistrationPlatformEnum?,
      metadata: metadata == const $CopyWithPlaceholder()
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Object?,
    );
  }
}

extension $NotificationDeviceRegistrationCopyWith
    on NotificationDeviceRegistration {
  /// Returns a callable class that can be used as follows: `instanceOfNotificationDeviceRegistration.copyWith(...)` or like so:`instanceOfNotificationDeviceRegistration.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$NotificationDeviceRegistrationCWProxy get copyWith =>
      _$NotificationDeviceRegistrationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDeviceRegistration _$NotificationDeviceRegistrationFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'NotificationDeviceRegistration',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['business_id', 'fcm_token']);
    final val = NotificationDeviceRegistration(
      businessId: $checkedConvert('business_id', (v) => v as String),
      locationId: $checkedConvert('location_id', (v) => v as String?),
      fcmToken: $checkedConvert('fcm_token', (v) => v as String),
      platform: $checkedConvert(
        'platform',
        (v) =>
            $enumDecodeNullable(
              _$NotificationDeviceRegistrationPlatformEnumEnumMap,
              v,
            ) ??
            'ANDROID',
      ),
      metadata: $checkedConvert('metadata', (v) => v),
    );
    return val;
  },
  fieldKeyMap: const {
    'businessId': 'business_id',
    'locationId': 'location_id',
    'fcmToken': 'fcm_token',
  },
);

Map<String, dynamic> _$NotificationDeviceRegistrationToJson(
  NotificationDeviceRegistration instance,
) => <String, dynamic>{
  'business_id': instance.businessId,
  'location_id': ?instance.locationId,
  'fcm_token': instance.fcmToken,
  'platform':
      ?_$NotificationDeviceRegistrationPlatformEnumEnumMap[instance.platform],
  'metadata': ?instance.metadata,
};

const _$NotificationDeviceRegistrationPlatformEnumEnumMap = {
  NotificationDeviceRegistrationPlatformEnum.ANDROID: 'ANDROID',
  NotificationDeviceRegistrationPlatformEnum.IOS: 'IOS',
  NotificationDeviceRegistrationPlatformEnum.WEB: 'WEB',
};
