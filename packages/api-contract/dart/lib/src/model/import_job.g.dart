// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_job.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportJobCWProxy {
  ImportJob id(String id);

  ImportJob business(String business);

  ImportJob user(String user);

  ImportJob confirmedBy(String? confirmedBy);

  ImportJob kind(ImportJobKindEnum kind);

  ImportJob status(ImportJobStatusEnum status);

  ImportJob duplicateStrategy(ImportJobDuplicateStrategyEnum duplicateStrategy);

  ImportJob rowCount(int rowCount);

  ImportJob validRowCount(int validRowCount);

  ImportJob errorCount(int errorCount);

  ImportJob createdCount(int createdCount);

  ImportJob updatedCount(int updatedCount);

  ImportJob skippedCount(int skippedCount);

  ImportJob errors(Object? errors);

  ImportJob originalFilename(String originalFilename);

  ImportJob fileSha256(String fileSha256);

  ImportJob fileSizeBytes(int fileSizeBytes);

  ImportJob createdAt(DateTime createdAt);

  ImportJob updatedAt(DateTime updatedAt);

  ImportJob confirmedAt(DateTime? confirmedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJob(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJob call({
    String id,
    String business,
    String user,
    String? confirmedBy,
    ImportJobKindEnum kind,
    ImportJobStatusEnum status,
    ImportJobDuplicateStrategyEnum duplicateStrategy,
    int rowCount,
    int validRowCount,
    int errorCount,
    int createdCount,
    int updatedCount,
    int skippedCount,
    Object? errors,
    String originalFilename,
    String fileSha256,
    int fileSizeBytes,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? confirmedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportJob.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportJob.copyWith.fieldName(...)`
class _$ImportJobCWProxyImpl implements _$ImportJobCWProxy {
  const _$ImportJobCWProxyImpl(this._value);

  final ImportJob _value;

  @override
  ImportJob id(String id) => this(id: id);

  @override
  ImportJob business(String business) => this(business: business);

  @override
  ImportJob user(String user) => this(user: user);

  @override
  ImportJob confirmedBy(String? confirmedBy) => this(confirmedBy: confirmedBy);

  @override
  ImportJob kind(ImportJobKindEnum kind) => this(kind: kind);

  @override
  ImportJob status(ImportJobStatusEnum status) => this(status: status);

  @override
  ImportJob duplicateStrategy(
    ImportJobDuplicateStrategyEnum duplicateStrategy,
  ) => this(duplicateStrategy: duplicateStrategy);

  @override
  ImportJob rowCount(int rowCount) => this(rowCount: rowCount);

  @override
  ImportJob validRowCount(int validRowCount) =>
      this(validRowCount: validRowCount);

  @override
  ImportJob errorCount(int errorCount) => this(errorCount: errorCount);

  @override
  ImportJob createdCount(int createdCount) => this(createdCount: createdCount);

  @override
  ImportJob updatedCount(int updatedCount) => this(updatedCount: updatedCount);

  @override
  ImportJob skippedCount(int skippedCount) => this(skippedCount: skippedCount);

  @override
  ImportJob errors(Object? errors) => this(errors: errors);

  @override
  ImportJob originalFilename(String originalFilename) =>
      this(originalFilename: originalFilename);

  @override
  ImportJob fileSha256(String fileSha256) => this(fileSha256: fileSha256);

  @override
  ImportJob fileSizeBytes(int fileSizeBytes) =>
      this(fileSizeBytes: fileSizeBytes);

  @override
  ImportJob createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  ImportJob updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  ImportJob confirmedAt(DateTime? confirmedAt) =>
      this(confirmedAt: confirmedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportJob(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportJob(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportJob call({
    Object? id = const $CopyWithPlaceholder(),
    Object? business = const $CopyWithPlaceholder(),
    Object? user = const $CopyWithPlaceholder(),
    Object? confirmedBy = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? duplicateStrategy = const $CopyWithPlaceholder(),
    Object? rowCount = const $CopyWithPlaceholder(),
    Object? validRowCount = const $CopyWithPlaceholder(),
    Object? errorCount = const $CopyWithPlaceholder(),
    Object? createdCount = const $CopyWithPlaceholder(),
    Object? updatedCount = const $CopyWithPlaceholder(),
    Object? skippedCount = const $CopyWithPlaceholder(),
    Object? errors = const $CopyWithPlaceholder(),
    Object? originalFilename = const $CopyWithPlaceholder(),
    Object? fileSha256 = const $CopyWithPlaceholder(),
    Object? fileSizeBytes = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? confirmedAt = const $CopyWithPlaceholder(),
  }) {
    return ImportJob(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      business: business == const $CopyWithPlaceholder()
          ? _value.business
          // ignore: cast_nullable_to_non_nullable
          : business as String,
      user: user == const $CopyWithPlaceholder()
          ? _value.user
          // ignore: cast_nullable_to_non_nullable
          : user as String,
      confirmedBy: confirmedBy == const $CopyWithPlaceholder()
          ? _value.confirmedBy
          // ignore: cast_nullable_to_non_nullable
          : confirmedBy as String?,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as ImportJobKindEnum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ImportJobStatusEnum,
      duplicateStrategy: duplicateStrategy == const $CopyWithPlaceholder()
          ? _value.duplicateStrategy
          // ignore: cast_nullable_to_non_nullable
          : duplicateStrategy as ImportJobDuplicateStrategyEnum,
      rowCount: rowCount == const $CopyWithPlaceholder()
          ? _value.rowCount
          // ignore: cast_nullable_to_non_nullable
          : rowCount as int,
      validRowCount: validRowCount == const $CopyWithPlaceholder()
          ? _value.validRowCount
          // ignore: cast_nullable_to_non_nullable
          : validRowCount as int,
      errorCount: errorCount == const $CopyWithPlaceholder()
          ? _value.errorCount
          // ignore: cast_nullable_to_non_nullable
          : errorCount as int,
      createdCount: createdCount == const $CopyWithPlaceholder()
          ? _value.createdCount
          // ignore: cast_nullable_to_non_nullable
          : createdCount as int,
      updatedCount: updatedCount == const $CopyWithPlaceholder()
          ? _value.updatedCount
          // ignore: cast_nullable_to_non_nullable
          : updatedCount as int,
      skippedCount: skippedCount == const $CopyWithPlaceholder()
          ? _value.skippedCount
          // ignore: cast_nullable_to_non_nullable
          : skippedCount as int,
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as Object?,
      originalFilename: originalFilename == const $CopyWithPlaceholder()
          ? _value.originalFilename
          // ignore: cast_nullable_to_non_nullable
          : originalFilename as String,
      fileSha256: fileSha256 == const $CopyWithPlaceholder()
          ? _value.fileSha256
          // ignore: cast_nullable_to_non_nullable
          : fileSha256 as String,
      fileSizeBytes: fileSizeBytes == const $CopyWithPlaceholder()
          ? _value.fileSizeBytes
          // ignore: cast_nullable_to_non_nullable
          : fileSizeBytes as int,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
      confirmedAt: confirmedAt == const $CopyWithPlaceholder()
          ? _value.confirmedAt
          // ignore: cast_nullable_to_non_nullable
          : confirmedAt as DateTime?,
    );
  }
}

extension $ImportJobCopyWith on ImportJob {
  /// Returns a callable class that can be used as follows: `instanceOfImportJob.copyWith(...)` or like so:`instanceOfImportJob.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportJobCWProxy get copyWith => _$ImportJobCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportJob _$ImportJobFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ImportJob',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'business',
        'user',
        'confirmed_by',
        'kind',
        'status',
        'duplicate_strategy',
        'row_count',
        'valid_row_count',
        'error_count',
        'created_count',
        'updated_count',
        'skipped_count',
        'errors',
        'original_filename',
        'file_sha256',
        'file_size_bytes',
        'created_at',
        'updated_at',
        'confirmed_at',
      ],
    );
    final val = ImportJob(
      id: $checkedConvert('id', (v) => v as String),
      business: $checkedConvert('business', (v) => v as String),
      user: $checkedConvert('user', (v) => v as String),
      confirmedBy: $checkedConvert('confirmed_by', (v) => v as String?),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$ImportJobKindEnumEnumMap, v),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$ImportJobStatusEnumEnumMap, v),
      ),
      duplicateStrategy: $checkedConvert(
        'duplicate_strategy',
        (v) => $enumDecode(_$ImportJobDuplicateStrategyEnumEnumMap, v),
      ),
      rowCount: $checkedConvert('row_count', (v) => (v as num).toInt()),
      validRowCount: $checkedConvert(
        'valid_row_count',
        (v) => (v as num).toInt(),
      ),
      errorCount: $checkedConvert('error_count', (v) => (v as num).toInt()),
      createdCount: $checkedConvert('created_count', (v) => (v as num).toInt()),
      updatedCount: $checkedConvert('updated_count', (v) => (v as num).toInt()),
      skippedCount: $checkedConvert('skipped_count', (v) => (v as num).toInt()),
      errors: $checkedConvert('errors', (v) => v),
      originalFilename: $checkedConvert(
        'original_filename',
        (v) => v as String,
      ),
      fileSha256: $checkedConvert('file_sha256', (v) => v as String),
      fileSizeBytes: $checkedConvert(
        'file_size_bytes',
        (v) => (v as num).toInt(),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => DateTime.parse(v as String),
      ),
      confirmedAt: $checkedConvert(
        'confirmed_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'confirmedBy': 'confirmed_by',
    'duplicateStrategy': 'duplicate_strategy',
    'rowCount': 'row_count',
    'validRowCount': 'valid_row_count',
    'errorCount': 'error_count',
    'createdCount': 'created_count',
    'updatedCount': 'updated_count',
    'skippedCount': 'skipped_count',
    'originalFilename': 'original_filename',
    'fileSha256': 'file_sha256',
    'fileSizeBytes': 'file_size_bytes',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'confirmedAt': 'confirmed_at',
  },
);

Map<String, dynamic> _$ImportJobToJson(ImportJob instance) => <String, dynamic>{
  'id': instance.id,
  'business': instance.business,
  'user': instance.user,
  'confirmed_by': instance.confirmedBy,
  'kind': _$ImportJobKindEnumEnumMap[instance.kind]!,
  'status': _$ImportJobStatusEnumEnumMap[instance.status]!,
  'duplicate_strategy':
      _$ImportJobDuplicateStrategyEnumEnumMap[instance.duplicateStrategy]!,
  'row_count': instance.rowCount,
  'valid_row_count': instance.validRowCount,
  'error_count': instance.errorCount,
  'created_count': instance.createdCount,
  'updated_count': instance.updatedCount,
  'skipped_count': instance.skippedCount,
  'errors': instance.errors,
  'original_filename': instance.originalFilename,
  'file_sha256': instance.fileSha256,
  'file_size_bytes': instance.fileSizeBytes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'confirmed_at': instance.confirmedAt?.toIso8601String(),
};

const _$ImportJobKindEnumEnumMap = {
  ImportJobKindEnum.PRODUCT: 'PRODUCT',
  ImportJobKindEnum.PARTY: 'PARTY',
};

const _$ImportJobStatusEnumEnumMap = {
  ImportJobStatusEnum.READY: 'READY',
  ImportJobStatusEnum.INVALID: 'INVALID',
  ImportJobStatusEnum.COMPLETED: 'COMPLETED',
  ImportJobStatusEnum.FAILED: 'FAILED',
};

const _$ImportJobDuplicateStrategyEnumEnumMap = {
  ImportJobDuplicateStrategyEnum.UPDATE: 'UPDATE',
  ImportJobDuplicateStrategyEnum.SKIP: 'SKIP',
};
