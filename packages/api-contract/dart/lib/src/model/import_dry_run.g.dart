// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_dry_run.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportDryRunCWProxy {
  ImportDryRun dryRun(bool dryRun);

  ImportDryRun kind(ImportDryRunKindEnum kind);

  ImportDryRun duplicateStrategy(
    ImportDryRunDuplicateStrategyEnum duplicateStrategy,
  );

  ImportDryRun rowCount(int rowCount);

  ImportDryRun validRowCount(int validRowCount);

  ImportDryRun errorCount(int errorCount);

  ImportDryRun errors(Object? errors);

  ImportDryRun createdCount(int createdCount);

  ImportDryRun updatedCount(int updatedCount);

  ImportDryRun skippedCount(int skippedCount);

  ImportDryRun preview(List<ImportDryRunPreview> preview);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportDryRun(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportDryRun(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportDryRun call({
    bool dryRun,
    ImportDryRunKindEnum kind,
    ImportDryRunDuplicateStrategyEnum duplicateStrategy,
    int rowCount,
    int validRowCount,
    int errorCount,
    Object? errors,
    int createdCount,
    int updatedCount,
    int skippedCount,
    List<ImportDryRunPreview> preview,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportDryRun.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportDryRun.copyWith.fieldName(...)`
class _$ImportDryRunCWProxyImpl implements _$ImportDryRunCWProxy {
  const _$ImportDryRunCWProxyImpl(this._value);

  final ImportDryRun _value;

  @override
  ImportDryRun dryRun(bool dryRun) => this(dryRun: dryRun);

  @override
  ImportDryRun kind(ImportDryRunKindEnum kind) => this(kind: kind);

  @override
  ImportDryRun duplicateStrategy(
    ImportDryRunDuplicateStrategyEnum duplicateStrategy,
  ) => this(duplicateStrategy: duplicateStrategy);

  @override
  ImportDryRun rowCount(int rowCount) => this(rowCount: rowCount);

  @override
  ImportDryRun validRowCount(int validRowCount) =>
      this(validRowCount: validRowCount);

  @override
  ImportDryRun errorCount(int errorCount) => this(errorCount: errorCount);

  @override
  ImportDryRun errors(Object? errors) => this(errors: errors);

  @override
  ImportDryRun createdCount(int createdCount) =>
      this(createdCount: createdCount);

  @override
  ImportDryRun updatedCount(int updatedCount) =>
      this(updatedCount: updatedCount);

  @override
  ImportDryRun skippedCount(int skippedCount) =>
      this(skippedCount: skippedCount);

  @override
  ImportDryRun preview(List<ImportDryRunPreview> preview) =>
      this(preview: preview);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportDryRun(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportDryRun(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportDryRun call({
    Object? dryRun = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? duplicateStrategy = const $CopyWithPlaceholder(),
    Object? rowCount = const $CopyWithPlaceholder(),
    Object? validRowCount = const $CopyWithPlaceholder(),
    Object? errorCount = const $CopyWithPlaceholder(),
    Object? errors = const $CopyWithPlaceholder(),
    Object? createdCount = const $CopyWithPlaceholder(),
    Object? updatedCount = const $CopyWithPlaceholder(),
    Object? skippedCount = const $CopyWithPlaceholder(),
    Object? preview = const $CopyWithPlaceholder(),
  }) {
    return ImportDryRun(
      dryRun: dryRun == const $CopyWithPlaceholder()
          ? _value.dryRun
          // ignore: cast_nullable_to_non_nullable
          : dryRun as bool,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as ImportDryRunKindEnum,
      duplicateStrategy: duplicateStrategy == const $CopyWithPlaceholder()
          ? _value.duplicateStrategy
          // ignore: cast_nullable_to_non_nullable
          : duplicateStrategy as ImportDryRunDuplicateStrategyEnum,
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
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as Object?,
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
      preview: preview == const $CopyWithPlaceholder()
          ? _value.preview
          // ignore: cast_nullable_to_non_nullable
          : preview as List<ImportDryRunPreview>,
    );
  }
}

extension $ImportDryRunCopyWith on ImportDryRun {
  /// Returns a callable class that can be used as follows: `instanceOfImportDryRun.copyWith(...)` or like so:`instanceOfImportDryRun.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportDryRunCWProxy get copyWith => _$ImportDryRunCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportDryRun _$ImportDryRunFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ImportDryRun',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'dry_run',
        'kind',
        'duplicate_strategy',
        'row_count',
        'valid_row_count',
        'error_count',
        'errors',
        'created_count',
        'updated_count',
        'skipped_count',
        'preview',
      ],
    );
    final val = ImportDryRun(
      dryRun: $checkedConvert('dry_run', (v) => v as bool),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$ImportDryRunKindEnumEnumMap, v),
      ),
      duplicateStrategy: $checkedConvert(
        'duplicate_strategy',
        (v) => $enumDecode(_$ImportDryRunDuplicateStrategyEnumEnumMap, v),
      ),
      rowCount: $checkedConvert('row_count', (v) => (v as num).toInt()),
      validRowCount: $checkedConvert(
        'valid_row_count',
        (v) => (v as num).toInt(),
      ),
      errorCount: $checkedConvert('error_count', (v) => (v as num).toInt()),
      errors: $checkedConvert('errors', (v) => v),
      createdCount: $checkedConvert('created_count', (v) => (v as num).toInt()),
      updatedCount: $checkedConvert('updated_count', (v) => (v as num).toInt()),
      skippedCount: $checkedConvert('skipped_count', (v) => (v as num).toInt()),
      preview: $checkedConvert(
        'preview',
        (v) => (v as List<dynamic>)
            .map((e) => ImportDryRunPreview.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'dryRun': 'dry_run',
    'duplicateStrategy': 'duplicate_strategy',
    'rowCount': 'row_count',
    'validRowCount': 'valid_row_count',
    'errorCount': 'error_count',
    'createdCount': 'created_count',
    'updatedCount': 'updated_count',
    'skippedCount': 'skipped_count',
  },
);

Map<String, dynamic> _$ImportDryRunToJson(
  ImportDryRun instance,
) => <String, dynamic>{
  'dry_run': instance.dryRun,
  'kind': _$ImportDryRunKindEnumEnumMap[instance.kind]!,
  'duplicate_strategy':
      _$ImportDryRunDuplicateStrategyEnumEnumMap[instance.duplicateStrategy]!,
  'row_count': instance.rowCount,
  'valid_row_count': instance.validRowCount,
  'error_count': instance.errorCount,
  'errors': instance.errors,
  'created_count': instance.createdCount,
  'updated_count': instance.updatedCount,
  'skipped_count': instance.skippedCount,
  'preview': instance.preview.map((e) => e.toJson()).toList(),
};

const _$ImportDryRunKindEnumEnumMap = {
  ImportDryRunKindEnum.PRODUCT: 'PRODUCT',
  ImportDryRunKindEnum.PARTY: 'PARTY',
};

const _$ImportDryRunDuplicateStrategyEnumEnumMap = {
  ImportDryRunDuplicateStrategyEnum.UPDATE: 'UPDATE',
  ImportDryRunDuplicateStrategyEnum.SKIP: 'SKIP',
};
