//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_device_registration.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationDeviceRegistration {
  /// Returns a new [NotificationDeviceRegistration] instance.
  NotificationDeviceRegistration({
    required this.businessId,

    this.locationId,

    required this.fcmToken,

    this.platform = NotificationDeviceRegistrationPlatformEnum.ANDROID,

    this.metadata,
  });

  @JsonKey(name: r'business_id', required: true, includeIfNull: false)
  final String businessId;

  @JsonKey(name: r'location_id', required: false, includeIfNull: false)
  final String? locationId;

  @JsonKey(name: r'fcm_token', required: true, includeIfNull: false)
  final String fcmToken;

  /// * `ANDROID` - Android * `IOS` - iOS * `WEB` - Web
  @JsonKey(
    defaultValue: 'ANDROID',
    name: r'platform',
    required: false,
    includeIfNull: false,
  )
  final NotificationDeviceRegistrationPlatformEnum? platform;

  /// Arbitrary device metadata supplied by the client; must be a JSON object.
  @JsonKey(name: r'metadata', required: false, includeIfNull: false)
  final Object? metadata;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationDeviceRegistration &&
          other.businessId == businessId &&
          other.locationId == locationId &&
          other.fcmToken == fcmToken &&
          other.platform == platform &&
          other.metadata == metadata;

  @override
  int get hashCode =>
      businessId.hashCode +
      (locationId == null ? 0 : locationId.hashCode) +
      fcmToken.hashCode +
      platform.hashCode +
      (metadata == null ? 0 : metadata.hashCode);

  factory NotificationDeviceRegistration.fromJson(Map<String, dynamic> json) =>
      _$NotificationDeviceRegistrationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDeviceRegistrationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `ANDROID` - Android * `IOS` - iOS * `WEB` - Web
enum NotificationDeviceRegistrationPlatformEnum {
  @JsonValue(r'ANDROID')
  ANDROID(r'ANDROID'),
  @JsonValue(r'IOS')
  IOS(r'IOS'),
  @JsonValue(r'WEB')
  WEB(r'WEB');

  const NotificationDeviceRegistrationPlatformEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
