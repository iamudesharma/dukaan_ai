// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmail_import_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GmailImportResultCWProxy {
  GmailImportResult id(String id);

  GmailImportResult status(GmailImportResultStatusEnum? status);

  GmailImportResult subject(String? subject);

  GmailImportResult receivedAt(DateTime? receivedAt);

  GmailImportResult preview(String? preview);

  GmailImportResult extracted(GmailExtracted extracted);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailImportResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailImportResult(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailImportResult call({
    String id,
    GmailImportResultStatusEnum? status,
    String? subject,
    DateTime? receivedAt,
    String? preview,
    GmailExtracted extracted,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGmailImportResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGmailImportResult.copyWith.fieldName(...)`
class _$GmailImportResultCWProxyImpl implements _$GmailImportResultCWProxy {
  const _$GmailImportResultCWProxyImpl(this._value);

  final GmailImportResult _value;

  @override
  GmailImportResult id(String id) => this(id: id);

  @override
  GmailImportResult status(GmailImportResultStatusEnum? status) =>
      this(status: status);

  @override
  GmailImportResult subject(String? subject) => this(subject: subject);

  @override
  GmailImportResult receivedAt(DateTime? receivedAt) =>
      this(receivedAt: receivedAt);

  @override
  GmailImportResult preview(String? preview) => this(preview: preview);

  @override
  GmailImportResult extracted(GmailExtracted extracted) =>
      this(extracted: extracted);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailImportResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailImportResult(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailImportResult call({
    Object? id = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? subject = const $CopyWithPlaceholder(),
    Object? receivedAt = const $CopyWithPlaceholder(),
    Object? preview = const $CopyWithPlaceholder(),
    Object? extracted = const $CopyWithPlaceholder(),
  }) {
    return GmailImportResult(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as GmailImportResultStatusEnum?,
      subject: subject == const $CopyWithPlaceholder()
          ? _value.subject
          // ignore: cast_nullable_to_non_nullable
          : subject as String?,
      receivedAt: receivedAt == const $CopyWithPlaceholder()
          ? _value.receivedAt
          // ignore: cast_nullable_to_non_nullable
          : receivedAt as DateTime?,
      preview: preview == const $CopyWithPlaceholder()
          ? _value.preview
          // ignore: cast_nullable_to_non_nullable
          : preview as String?,
      extracted: extracted == const $CopyWithPlaceholder()
          ? _value.extracted
          // ignore: cast_nullable_to_non_nullable
          : extracted as GmailExtracted,
    );
  }
}

extension $GmailImportResultCopyWith on GmailImportResult {
  /// Returns a callable class that can be used as follows: `instanceOfGmailImportResult.copyWith(...)` or like so:`instanceOfGmailImportResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GmailImportResultCWProxy get copyWith =>
      _$GmailImportResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GmailImportResult _$GmailImportResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GmailImportResult', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'extracted']);
      final val = GmailImportResult(
        id: $checkedConvert('id', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecodeNullable(_$GmailImportResultStatusEnumEnumMap, v),
        ),
        subject: $checkedConvert('subject', (v) => v as String?),
        receivedAt: $checkedConvert(
          'received_at',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        preview: $checkedConvert('preview', (v) => v as String?),
        extracted: $checkedConvert(
          'extracted',
          (v) => GmailExtracted.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    }, fieldKeyMap: const {'receivedAt': 'received_at'});

Map<String, dynamic> _$GmailImportResultToJson(GmailImportResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': ?_$GmailImportResultStatusEnumEnumMap[instance.status],
      'subject': ?instance.subject,
      'received_at': ?instance.receivedAt?.toIso8601String(),
      'preview': ?instance.preview,
      'extracted': instance.extracted.toJson(),
    };

const _$GmailImportResultStatusEnumEnumMap = {
  GmailImportResultStatusEnum.NEEDS_REVIEW: 'NEEDS_REVIEW',
  GmailImportResultStatusEnum.REVIEWED: 'REVIEWED',
  GmailImportResultStatusEnum.DISMISSED: 'DISMISSED',
};
