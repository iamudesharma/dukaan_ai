//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/import_dry_run_preview.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_dry_run.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportDryRun {
  /// Returns a new [ImportDryRun] instance.
  ImportDryRun({
    required this.dryRun,

    required this.kind,

    required this.duplicateStrategy,

    required this.rowCount,

    required this.validRowCount,

    required this.errorCount,

    required this.errors,

    required this.createdCount,

    required this.updatedCount,

    required this.skippedCount,

    required this.preview,
  });

  @JsonKey(name: r'dry_run', required: true, includeIfNull: false)
  final bool dryRun;

  /// * `PRODUCT` - Product * `PARTY` - Party
  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final ImportDryRunKindEnum kind;

  /// * `UPDATE` - Update existing rows * `SKIP` - Skip existing rows
  @JsonKey(name: r'duplicate_strategy', required: true, includeIfNull: false)
  final ImportDryRunDuplicateStrategyEnum duplicateStrategy;

  @JsonKey(name: r'row_count', required: true, includeIfNull: false)
  final int rowCount;

  @JsonKey(name: r'valid_row_count', required: true, includeIfNull: false)
  final int validRowCount;

  @JsonKey(name: r'error_count', required: true, includeIfNull: false)
  final int errorCount;

  /// Per-row validation errors; keys depend on the imported product or party columns.
  @JsonKey(name: r'errors', required: true, includeIfNull: true)
  final Object? errors;

  @JsonKey(name: r'created_count', required: true, includeIfNull: false)
  final int createdCount;

  @JsonKey(name: r'updated_count', required: true, includeIfNull: false)
  final int updatedCount;

  @JsonKey(name: r'skipped_count', required: true, includeIfNull: false)
  final int skippedCount;

  @JsonKey(name: r'preview', required: true, includeIfNull: false)
  final List<ImportDryRunPreview> preview;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportDryRun &&
          other.dryRun == dryRun &&
          other.kind == kind &&
          other.duplicateStrategy == duplicateStrategy &&
          other.rowCount == rowCount &&
          other.validRowCount == validRowCount &&
          other.errorCount == errorCount &&
          other.errors == errors &&
          other.createdCount == createdCount &&
          other.updatedCount == updatedCount &&
          other.skippedCount == skippedCount &&
          other.preview == preview;

  @override
  int get hashCode =>
      dryRun.hashCode +
      kind.hashCode +
      duplicateStrategy.hashCode +
      rowCount.hashCode +
      validRowCount.hashCode +
      errorCount.hashCode +
      (errors == null ? 0 : errors.hashCode) +
      createdCount.hashCode +
      updatedCount.hashCode +
      skippedCount.hashCode +
      preview.hashCode;

  factory ImportDryRun.fromJson(Map<String, dynamic> json) =>
      _$ImportDryRunFromJson(json);

  Map<String, dynamic> toJson() => _$ImportDryRunToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `PRODUCT` - Product * `PARTY` - Party
enum ImportDryRunKindEnum {
  @JsonValue(r'PRODUCT')
  PRODUCT(r'PRODUCT'),
  @JsonValue(r'PARTY')
  PARTY(r'PARTY');

  const ImportDryRunKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `UPDATE` - Update existing rows * `SKIP` - Skip existing rows
enum ImportDryRunDuplicateStrategyEnum {
  @JsonValue(r'UPDATE')
  UPDATE(r'UPDATE'),
  @JsonValue(r'SKIP')
  SKIP(r'SKIP');

  const ImportDryRunDuplicateStrategyEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
