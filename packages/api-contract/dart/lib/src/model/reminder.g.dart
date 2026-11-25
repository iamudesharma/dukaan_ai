// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReminderCWProxy {
  Reminder id(String id);

  Reminder business(String business);

  Reminder location(String? location);

  Reminder kind(ReminderKindEnum kind);

  Reminder title(String title);

  Reminder body(String body);

  Reminder scheduledAt(DateTime scheduledAt);

  Reminder status(ReminderStatusEnum status);

  Reminder dedupeKey(String dedupeKey);

  Reminder data(Object? data);

  Reminder metadata(Object? metadata);

  Reminder queuedAt(DateTime? queuedAt);

  Reminder sentAt(DateTime? sentAt);

  Reminder cancelledAt(DateTime? cancelledAt);

  Reminder lastError(String lastError);

  Reminder createdAt(DateTime createdAt);

  Reminder updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reminder(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reminder(...).copyWith(id: 12, name: "My name")
  /// ````
  Reminder call({
    String id,
    String business,
    String? location,
    ReminderKindEnum kind,
    String title,
    String body,
    DateTime scheduledAt,
    ReminderStatusEnum status,
    String dedupeKey,
    Object? data,
    Object? metadata,
    DateTime? queuedAt,
    DateTime? sentAt,
    DateTime? cancelledAt,
    String lastError,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReminder.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReminder.copyWith.fieldName(...)`
class _$ReminderCWProxyImpl implements _$ReminderCWProxy {
  const _$ReminderCWProxyImpl(this._value);

  final Reminder _value;

  @override
  Reminder id(String id) => this(id: id);

  @override
  Reminder business(String business) => this(business: business);

  @override
  Reminder location(String? location) => this(location: location);

  @override
  Reminder kind(ReminderKindEnum kind) => this(kind: kind);

  @override
  Reminder title(String title) => this(title: title);

  @override
  Reminder body(String body) => this(body: body);

  @override
  Reminder scheduledAt(DateTime scheduledAt) => this(scheduledAt: scheduledAt);

  @override
  Reminder status(ReminderStatusEnum status) => this(status: status);

  @override
  Reminder dedupeKey(String dedupeKey) => this(dedupeKey: dedupeKey);

  @override
  Reminder data(Object? data) => this(data: data);

  @override
  Reminder metadata(Object? metadata) => this(metadata: metadata);

  @override
  Reminder queuedAt(DateTime? queuedAt) => this(queuedAt: queuedAt);

  @override
  Reminder sentAt(DateTime? sentAt) => this(sentAt: sentAt);

  @override
  Reminder cancelledAt(DateTime? cancelledAt) => this(cancelledAt: cancelledAt);

  @override
  Reminder lastError(String lastError) => this(lastError: lastError);

  @override
  Reminder createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Reminder updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reminder(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reminder(...).copyWith(id: 12, name: "My name")
  /// ````
  Reminder call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? dedupeKey = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
    Object? queuedAt = const $CopyWithPlaceholder(),
    Object? sentAt = const $CopyWithPlaceholder(),
    Object? cancelledAt = const $CopyWithPlaceholder(),
    Object? lastError = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return Reminder(
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
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as ReminderKindEnum,
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
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ReminderStatusEnum,
      dedupeKey: dedupeKey == const $CopyWithPlaceholder()
          ? _value.dedupeKey
          // ignore: cast_nullable_to_non_nullable
          : dedupeKey as String,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as Object?,
      metadata: metadata == const $CopyWithPlaceholder()
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Object?,
      queuedAt: queuedAt == const $CopyWithPlaceholder()
          ? _value.queuedAt
          // ignore: cast_nullable_to_non_nullable
          : queuedAt as DateTime?,
      sentAt: sentAt == const $CopyWithPlaceholder()
          ? _value.sentAt
          // ignore: cast_nullable_to_non_nullable
          : sentAt as DateTime?,
      cancelledAt: cancelledAt == const $CopyWithPlaceholder()
          ? _value.cancelledAt
          // ignore: cast_nullable_to_non_nullable
          : cancelledAt as DateTime?,
      lastError: lastError == const $CopyWithPlaceholder()
          ? _value.lastError
          // ignore: cast_nullable_to_non_nullable
          : lastError as String,
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

extension $ReminderCopyWith on Reminder {
  /// Returns a callable class that can be used as follows: `instanceOfReminder.copyWith(...)` or like so:`instanceOfReminder.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ReminderCWProxy get copyWith => _$ReminderCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reminder _$ReminderFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Reminder',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'business',
        'location',
        'kind',
        'title',
        'body',
        'scheduled_at',
        'status',
        'dedupe_key',
        'data',
        'metadata',
        'queued_at',
        'sent_at',
        'cancelled_at',
        'last_error',
        'created_at',
        'updated_at',
      ],
    );
    final val = Reminder(
      id: $checkedConvert('id', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      location: $checkedConvert('location', (v) => v as String?),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$ReminderKindEnumEnumMap, v),
      ),
      title: $checkedConvert('title', (v) => v as String),
      body: $checkedConvert('body', (v) => v as String),
      scheduledAt: $checkedConvert(
        'scheduled_at',
        (v) => DateTime.parse(v as String),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$ReminderStatusEnumEnumMap, v),
      ),
      dedupeKey: $checkedConvert('dedupe_key', (v) => v as String),
      data: $checkedConvert('data', (v) => v),
      metadata: $checkedConvert('metadata', (v) => v),
      queuedAt: $checkedConvert(
        'queued_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      sentAt: $checkedConvert(
        'sent_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      cancelledAt: $checkedConvert(
        'cancelled_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      lastError: $checkedConvert('last_error', (v) => v as String),
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
    'scheduledAt': 'scheduled_at',
    'dedupeKey': 'dedupe_key',
    'queuedAt': 'queued_at',
    'sentAt': 'sent_at',
    'cancelledAt': 'cancelled_at',
    'lastError': 'last_error',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$ReminderToJson(Reminder instance) => <String, dynamic>{
  'id': instance.id,
  'business': instance.business,
  'location': instance.location,
  'kind': _$ReminderKindEnumEnumMap[instance.kind]!,
  'title': instance.title,
  'body': instance.body,
  'scheduled_at': instance.scheduledAt.toIso8601String(),
  'status': _$ReminderStatusEnumEnumMap[instance.status]!,
  'dedupe_key': instance.dedupeKey,
  'data': instance.data,
  'metadata': instance.metadata,
  'queued_at': instance.queuedAt?.toIso8601String(),
  'sent_at': instance.sentAt?.toIso8601String(),
  'cancelled_at': instance.cancelledAt?.toIso8601String(),
  'last_error': instance.lastError,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$ReminderKindEnumEnumMap = {
  ReminderKindEnum.USER: 'USER',
  ReminderKindEnum.DOMAIN: 'DOMAIN',
};

const _$ReminderStatusEnumEnumMap = {
  ReminderStatusEnum.SCHEDULED: 'SCHEDULED',
  ReminderStatusEnum.QUEUED: 'QUEUED',
  ReminderStatusEnum.SENT: 'SENT',
  ReminderStatusEnum.FAILED: 'FAILED',
  ReminderStatusEnum.CANCELLED: 'CANCELLED',
  ReminderStatusEnum.SKIPPED: 'SKIPPED',
};
