// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patched_reminder_update.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PatchedReminderUpdateCWProxy {
  PatchedReminderUpdate title(String? title);

  PatchedReminderUpdate body(String? body);

  PatchedReminderUpdate scheduledAt(DateTime? scheduledAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchedReminderUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchedReminderUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchedReminderUpdate call({
    String? title,
    String? body,
    DateTime? scheduledAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPatchedReminderUpdate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPatchedReminderUpdate.copyWith.fieldName(...)`
class _$PatchedReminderUpdateCWProxyImpl
    implements _$PatchedReminderUpdateCWProxy {
  const _$PatchedReminderUpdateCWProxyImpl(this._value);

  final PatchedReminderUpdate _value;

  @override
  PatchedReminderUpdate title(String? title) => this(title: title);

  @override
  PatchedReminderUpdate body(String? body) => this(body: body);

  @override
  PatchedReminderUpdate scheduledAt(DateTime? scheduledAt) =>
      this(scheduledAt: scheduledAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PatchedReminderUpdate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PatchedReminderUpdate(...).copyWith(id: 12, name: "My name")
  /// ````
  PatchedReminderUpdate call({
    Object? title = const $CopyWithPlaceholder(),
    Object? body = const $CopyWithPlaceholder(),
    Object? scheduledAt = const $CopyWithPlaceholder(),
  }) {
    return PatchedReminderUpdate(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      body: body == const $CopyWithPlaceholder()
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String?,
      scheduledAt: scheduledAt == const $CopyWithPlaceholder()
          ? _value.scheduledAt
          // ignore: cast_nullable_to_non_nullable
          : scheduledAt as DateTime?,
    );
  }
}

extension $PatchedReminderUpdateCopyWith on PatchedReminderUpdate {
  /// Returns a callable class that can be used as follows: `instanceOfPatchedReminderUpdate.copyWith(...)` or like so:`instanceOfPatchedReminderUpdate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PatchedReminderUpdateCWProxy get copyWith =>
      _$PatchedReminderUpdateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatchedReminderUpdate _$PatchedReminderUpdateFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PatchedReminderUpdate', json, ($checkedConvert) {
  final val = PatchedReminderUpdate(
    title: $checkedConvert('title', (v) => v as String?),
    body: $checkedConvert('body', (v) => v as String?),
    scheduledAt: $checkedConvert(
      'scheduled_at',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
}, fieldKeyMap: const {'scheduledAt': 'scheduled_at'});

Map<String, dynamic> _$PatchedReminderUpdateToJson(
  PatchedReminderUpdate instance,
) => <String, dynamic>{
  'title': ?instance.title,
  'body': ?instance.body,
  'scheduled_at': ?instance.scheduledAt?.toIso8601String(),
};
