// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_event.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AuditEventCWProxy {
  AuditEvent id(String id);

  AuditEvent eventType(String eventType);

  AuditEvent aggregateType(String aggregateType);

  AuditEvent aggregateId(String aggregateId);

  AuditEvent location(String? location);

  AuditEvent actorName(String? actorName);

  AuditEvent source_(String source_);

  AuditEvent metadata(Object? metadata);

  AuditEvent createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuditEvent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuditEvent(...).copyWith(id: 12, name: "My name")
  /// ````
  AuditEvent call({
    String id,
    String eventType,
    String aggregateType,
    String aggregateId,
    String? location,
    String? actorName,
    String source_,
    Object? metadata,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAuditEvent.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAuditEvent.copyWith.fieldName(...)`
class _$AuditEventCWProxyImpl implements _$AuditEventCWProxy {
  const _$AuditEventCWProxyImpl(this._value);

  final AuditEvent _value;

  @override
  AuditEvent id(String id) => this(id: id);

  @override
  AuditEvent eventType(String eventType) => this(eventType: eventType);

  @override
  AuditEvent aggregateType(String aggregateType) =>
      this(aggregateType: aggregateType);

  @override
  AuditEvent aggregateId(String aggregateId) => this(aggregateId: aggregateId);

  @override
  AuditEvent location(String? location) => this(location: location);

  @override
  AuditEvent actorName(String? actorName) => this(actorName: actorName);

  @override
  AuditEvent source_(String source_) => this(source_: source_);

  @override
  AuditEvent metadata(Object? metadata) => this(metadata: metadata);

  @override
  AuditEvent createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuditEvent(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuditEvent(...).copyWith(id: 12, name: "My name")
  /// ````
  AuditEvent call({
    Object? id = const $CopyWithPlaceholder(),
    Object? eventType = const $CopyWithPlaceholder(),
    Object? aggregateType = const $CopyWithPlaceholder(),
    Object? aggregateId = const $CopyWithPlaceholder(),
    Object? location = const $CopyWithPlaceholder(),
    Object? actorName = const $CopyWithPlaceholder(),
    Object? source_ = const $CopyWithPlaceholder(),
    Object? metadata = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return AuditEvent(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      eventType: eventType == const $CopyWithPlaceholder()
          ? _value.eventType
          // ignore: cast_nullable_to_non_nullable
          : eventType as String,
      aggregateType: aggregateType == const $CopyWithPlaceholder()
          ? _value.aggregateType
          // ignore: cast_nullable_to_non_nullable
          : aggregateType as String,
      aggregateId: aggregateId == const $CopyWithPlaceholder()
          ? _value.aggregateId
          // ignore: cast_nullable_to_non_nullable
          : aggregateId as String,
      location: location == const $CopyWithPlaceholder()
          ? _value.location
          // ignore: cast_nullable_to_non_nullable
          : location as String?,
      actorName: actorName == const $CopyWithPlaceholder()
          ? _value.actorName
          // ignore: cast_nullable_to_non_nullable
          : actorName as String?,
      source_: source_ == const $CopyWithPlaceholder()
          ? _value.source_
          // ignore: cast_nullable_to_non_nullable
          : source_ as String,
      metadata: metadata == const $CopyWithPlaceholder()
          ? _value.metadata
          // ignore: cast_nullable_to_non_nullable
          : metadata as Object?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $AuditEventCopyWith on AuditEvent {
  /// Returns a callable class that can be used as follows: `instanceOfAuditEvent.copyWith(...)` or like so:`instanceOfAuditEvent.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AuditEventCWProxy get copyWith => _$AuditEventCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditEvent _$AuditEventFromJson(Map<String, dynamic> json) => $checkedCreate(
  'AuditEvent',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'event_type',
        'aggregate_type',
        'aggregate_id',
        'location',
        'actor_name',
        'source',
        'metadata',
        'created_at',
      ],
    );
    final val = AuditEvent(
      id: $checkedConvert('id', (v) => v as String),
      eventType: $checkedConvert('event_type', (v) => v as String),
      aggregateType: $checkedConvert('aggregate_type', (v) => v as String),
      aggregateId: $checkedConvert('aggregate_id', (v) => v as String),
      location: $checkedConvert('location', (v) => v as String?),
      actorName: $checkedConvert('actor_name', (v) => v as String?),
      source_: $checkedConvert('source', (v) => v as String),
      metadata: $checkedConvert('metadata', (v) => v),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'eventType': 'event_type',
    'aggregateType': 'aggregate_type',
    'aggregateId': 'aggregate_id',
    'actorName': 'actor_name',
    'source_': 'source',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$AuditEventToJson(AuditEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_type': instance.eventType,
      'aggregate_type': instance.aggregateType,
      'aggregate_id': instance.aggregateId,
      'location': instance.location,
      'actor_name': instance.actorName,
      'source': instance.source_,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
    };
