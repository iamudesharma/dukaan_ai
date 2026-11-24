// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AttachmentCWProxy {
  Attachment id(String id);

  Attachment business(String business);

  Attachment kind(AttachmentKindEnum kind);

  Attachment mime(String mime);

  Attachment sizeBytes(int sizeBytes);

  Attachment status(AttachmentStatusEnum status);

  Attachment proposal(String? proposal);

  Attachment createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Attachment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Attachment(...).copyWith(id: 12, name: "My name")
  /// ````
  Attachment call({
    String id,
    String business,
    AttachmentKindEnum kind,
    String mime,
    int sizeBytes,
    AttachmentStatusEnum status,
    String? proposal,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAttachment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAttachment.copyWith.fieldName(...)`
class _$AttachmentCWProxyImpl implements _$AttachmentCWProxy {
  const _$AttachmentCWProxyImpl(this._value);

  final Attachment _value;

  @override
  Attachment id(String id) => this(id: id);

  @override
  Attachment business(String business) => this(business: business);

  @override
  Attachment kind(AttachmentKindEnum kind) => this(kind: kind);

  @override
  Attachment mime(String mime) => this(mime: mime);

  @override
  Attachment sizeBytes(int sizeBytes) => this(sizeBytes: sizeBytes);

  @override
  Attachment status(AttachmentStatusEnum status) => this(status: status);

  @override
  Attachment proposal(String? proposal) => this(proposal: proposal);

  @override
  Attachment createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Attachment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Attachment(...).copyWith(id: 12, name: "My name")
  /// ````
  Attachment call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? mime = const $CopyWithPlaceholder(),
    Object? sizeBytes = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? proposal = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return Attachment(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as AttachmentKindEnum,
      mime: mime == const $CopyWithPlaceholder()
          ? _value.mime
          // ignore: cast_nullable_to_non_nullable
          : mime as String,
      sizeBytes: sizeBytes == const $CopyWithPlaceholder()
          ? _value.sizeBytes
          // ignore: cast_nullable_to_non_nullable
          : sizeBytes as int,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as AttachmentStatusEnum,
      proposal: proposal == const $CopyWithPlaceholder()
          ? _value.proposal
          // ignore: cast_nullable_to_non_nullable
          : proposal as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $AttachmentCopyWith on Attachment {
  /// Returns a callable class that can be used as follows: `instanceOfAttachment.copyWith(...)` or like so:`instanceOfAttachment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AttachmentCWProxy get copyWith => _$AttachmentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Attachment _$AttachmentFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Attachment',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'business',
        'kind',
        'mime',
        'size_bytes',
        'status',
        'proposal',
        'created_at',
      ],
    );
    final val = Attachment(
      id: $checkedConvert('id', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$AttachmentKindEnumEnumMap, v),
      ),
      mime: $checkedConvert('mime', (v) => v as String),
      sizeBytes: $checkedConvert('size_bytes', (v) => (v as num).toInt()),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$AttachmentStatusEnumEnumMap, v),
      ),
      proposal: $checkedConvert('proposal', (v) => v as String?),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'sizeBytes': 'size_bytes', 'createdAt': 'created_at'},
);

Map<String, dynamic> _$AttachmentToJson(Attachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'business': instance.business,
      'kind': _$AttachmentKindEnumEnumMap[instance.kind]!,
      'mime': instance.mime,
      'size_bytes': instance.sizeBytes,
      'status': _$AttachmentStatusEnumEnumMap[instance.status]!,
      'proposal': instance.proposal,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$AttachmentKindEnumEnumMap = {
  AttachmentKindEnum.VOICE: 'VOICE',
  AttachmentKindEnum.IMAGE: 'IMAGE',
};

const _$AttachmentStatusEnumEnumMap = {
  AttachmentStatusEnum.PENDING: 'PENDING',
  AttachmentStatusEnum.READY: 'READY',
  AttachmentStatusEnum.FAILED: 'FAILED',
};
