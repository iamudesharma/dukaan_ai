//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_device.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationDevice {
  /// Returns a new [NotificationDevice] instance.
  NotificationDevice({
    required this.id,

    required this.business,

    required this.location,

    required this.platform,

    required this.status,

    required this.tokenSuffix,

    required this.lastSeenAt,

    required this.unregisteredAt,

    required this.metadata,

    required this.createdAt,

    required this.updatedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'location', required: true, includeIfNull: true)
  final String? location;

  /// * `ANDROID` - Android * `IOS` - iOS * `WEB` - Web
  @JsonKey(name: r'platform', required: true, includeIfNull: false)
  final NotificationDevicePlatformEnum platform;

  /// * `ACTIVE` - Active * `DISABLED` - Disabled
  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final NotificationDeviceStatusEnum status;

  @JsonKey(name: r'token_suffix', required: true, includeIfNull: false)
  final String tokenSuffix;

  @JsonKey(name: r'last_seen_at', required: true, includeIfNull: false)
  final DateTime lastSeenAt;

  @JsonKey(name: r'unregistered_at', required: true, includeIfNull: true)
  final DateTime? unregisteredAt;

  @JsonKey(name: r'metadata', required: true, includeIfNull: true)
  final Object? metadata;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'updated_at', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationDevice &&
          other.id == id &&
          other.business == business &&
          other.location == location &&
          other.platform == platform &&
          other.status == status &&
          other.tokenSuffix == tokenSuffix &&
          other.lastSeenAt == lastSeenAt &&
          other.unregisteredAt == unregisteredAt &&
          other.metadata == metadata &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      (location == null ? 0 : location.hashCode) +
      platform.hashCode +
      status.hashCode +
      tokenSuffix.hashCode +
      lastSeenAt.hashCode +
      (unregisteredAt == null ? 0 : unregisteredAt.hashCode) +
      (metadata == null ? 0 : metadata.hashCode) +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory NotificationDevice.fromJson(Map<String, dynamic> json) =>
      _$NotificationDeviceFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDeviceToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `ANDROID` - Android * `IOS` - iOS * `WEB` - Web
enum NotificationDevicePlatformEnum {
  @JsonValue(r'ANDROID')
  ANDROID(r'ANDROID'),
  @JsonValue(r'IOS')
  IOS(r'IOS'),
  @JsonValue(r'WEB')
  WEB(r'WEB');

  const NotificationDevicePlatformEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `ACTIVE` - Active * `DISABLED` - Disabled
enum NotificationDeviceStatusEnum {
  @JsonValue(r'ACTIVE')
  ACTIVE(r'ACTIVE'),
  @JsonValue(r'DISABLED')
  DISABLED(r'DISABLED');

  const NotificationDeviceStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
