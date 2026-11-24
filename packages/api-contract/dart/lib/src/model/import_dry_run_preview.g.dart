// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_dry_run_preview.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportDryRunPreviewCWProxy {
  ImportDryRunPreview row(int row);

  ImportDryRunPreview action(ImportDryRunPreviewActionEnum action);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportDryRunPreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportDryRunPreview(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportDryRunPreview call({int row, ImportDryRunPreviewActionEnum action});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportDryRunPreview.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportDryRunPreview.copyWith.fieldName(...)`
class _$ImportDryRunPreviewCWProxyImpl implements _$ImportDryRunPreviewCWProxy {
  const _$ImportDryRunPreviewCWProxyImpl(this._value);

  final ImportDryRunPreview _value;

  @override
  ImportDryRunPreview row(int row) => this(row: row);

  @override
  ImportDryRunPreview action(ImportDryRunPreviewActionEnum action) =>
      this(action: action);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportDryRunPreview(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportDryRunPreview(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportDryRunPreview call({
    Object? row = const $CopyWithPlaceholder(),
    Object? action = const $CopyWithPlaceholder(),
  }) {
    return ImportDryRunPreview(
      row: row == const $CopyWithPlaceholder()
          ? _value.row
          // ignore: cast_nullable_to_non_nullable
          : row as int,
      action: action == const $CopyWithPlaceholder()
          ? _value.action
          // ignore: cast_nullable_to_non_nullable
          : action as ImportDryRunPreviewActionEnum,
    );
  }
}

extension $ImportDryRunPreviewCopyWith on ImportDryRunPreview {
  /// Returns a callable class that can be used as follows: `instanceOfImportDryRunPreview.copyWith(...)` or like so:`instanceOfImportDryRunPreview.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportDryRunPreviewCWProxy get copyWith =>
      _$ImportDryRunPreviewCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportDryRunPreview _$ImportDryRunPreviewFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ImportDryRunPreview', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['row', 'action']);
      final val = ImportDryRunPreview(
        row: $checkedConvert('row', (v) => (v as num).toInt()),
        action: $checkedConvert(
          'action',
          (v) => $enumDecode(_$ImportDryRunPreviewActionEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ImportDryRunPreviewToJson(
  ImportDryRunPreview instance,
) => <String, dynamic>{
  'row': instance.row,
  'action': _$ImportDryRunPreviewActionEnumEnumMap[instance.action]!,
};

const _$ImportDryRunPreviewActionEnumEnumMap = {
  ImportDryRunPreviewActionEnum.CREATE: 'CREATE',
  ImportDryRunPreviewActionEnum.UPDATE: 'UPDATE',
  ImportDryRunPreviewActionEnum.SKIP: 'SKIP',
};
