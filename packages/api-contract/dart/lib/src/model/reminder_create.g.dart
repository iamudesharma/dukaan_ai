// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_create.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReminderCreateCWProxy {
  ReminderCreate businessId(String businessId);

  ReminderCreate locationId(String? locationId);

  ReminderCreate title(String title);

  ReminderCreate body(String body);

  ReminderCreate scheduledAt(DateTime scheduledAt);

  ReminderCreate dedupeKey(String? dedupeKey);

  ReminderCreate data(Object? data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReminderCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReminderCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  ReminderCreate call({
    String businessId,
    String? locationId,
    String title,
    String body,
    DateTime scheduledAt,
    String? dedupeKey,
    Object? data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReminderCreate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReminderCreate.copyWith.fieldName(...)`
class _$ReminderCreateCWProxyImpl implements _$ReminderCreateCWProxy {
  const _$ReminderCreateCWProxyImpl(this._value);

  final ReminderCreate _value;

  @override
  ReminderCreate businessId(String businessId) => this(businessId: businessId);

  @override
  ReminderCreate locationId(String? locationId) => this(locationId: locationId);

  @override
  ReminderCreate title(String title) => this(title: title);

  @override
  ReminderCreate body(String body) => this(body: body);

  @override
  ReminderCreate scheduledAt(DateTime scheduledAt) =>
      this(scheduledAt: scheduledAt);

  @override
  ReminderCreate dedupeKey(String? dedupeKey) => this(dedupeKey: dedupeKey);

  @override
  ReminderCreate data(Object? data) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ReminderCreate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ReminderCreate(...).copyWith(id: 12, name: "My name")
  /// ````
  ReminderCreate call({
    Object? businessId = const $CopyWithPlaceholder(),
    Object? locationId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
    Object? dedupeKey = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return ReminderCreate(
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      locationId: locationId == const $CopyWithPlaceholder()
          ? _value.locationId
          // ignore: cast_nullable_to_non_nullable
          : locationId as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      scheduledAt: scheduledAt == const $CopyWithPlaceholder()
          ? _value.scheduledAt
          // ignore: cast_nullable_to_non_nullable
          : scheduledAt as DateTime,
      dedupeKey: dedupeKey == const $CopyWithPlaceholder()
          ? _value.dedupeKey
          // ignore: cast_nullable_to_non_nullable
          : dedupeKey as String?,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Object?,
    );
  }
}

extension $ReminderCreateCopyWith on ReminderCreate {
  /// Returns a callable class that can be used as follows: `instanceOfReminderCreate.copyWith(...)` or like so:`instanceOfReminderCreate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReminderCreateCWProxy get copyWith => _$ReminderCreateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReminderCreate _$ReminderCreateFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ReminderCreate',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['business_id', 'title', 'body', 'scheduled_at'],
        );
        final val = ReminderCreate(
          businessId: $checkedConvert('business_id', (v) => v as String),
          locationId: $checkedConvert('location_id', (v) => v as String?),
          title: $checkedConvert('title', (v) => v as String),
          body: $checkedConvert('body', (v) => v as String),
          scheduledAt: $checkedConvert(
            'scheduled_at',
            (v) => DateTime.parse(v as String),
          ),
          dedupeKey: $checkedConvert('dedupe_key', (v) => v as String?),
          data: $checkedConvert('data', (v) => v),
        );
        return val;
      },
      fieldKeyMap: const {
        'businessId': 'business_id',
        'locationId': 'location_id',
        'scheduledAt': 'scheduled_at',
        'dedupeKey': 'dedupe_key',
      },
    );

Map<String, dynamic> _$ReminderCreateToJson(ReminderCreate instance) =>
    <String, dynamic>{
      'business_id': instance.businessId,
      'location_id': ?instance.locationId,
      'title': instance.title,
      'body': instance.body,
      'scheduled_at': instance.scheduledAt.toIso8601String(),
      'dedupe_key': ?instance.dedupeKey,
      'data': ?instance.data,
    };
