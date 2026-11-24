//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_job.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportJob {
  /// Returns a new [ImportJob] instance.
  ImportJob({
    required this.id,

    required this.business,

    required this.user,

    required this.confirmedBy,

    required this.kind,

    required this.status,

    required this.duplicateStrategy,

    required this.rowCount,

    required this.validRowCount,

    required this.errorCount,

    required this.createdCount,

    required this.updatedCount,

    required this.skippedCount,

    required this.errors,

    required this.originalFilename,

    required this.fileSha256,

    required this.fileSizeBytes,

    required this.createdAt,

    required this.updatedAt,

    required this.confirmedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'business', required: true, includeIfNull: false)
  final String business;

  @JsonKey(name: r'user', required: true, includeIfNull: false)
  final String user;

  @JsonKey(name: r'confirmed_by', required: true, includeIfNull: true)
  final String? confirmedBy;

  /// * `PRODUCT` - Product * `PARTY` - Party
  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final ImportJobKindEnum kind;

  /// * `READY` - Ready to confirm * `INVALID` - Contains invalid rows * `COMPLETED` - Completed * `FAILED` - Failed
  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final ImportJobStatusEnum status;

  /// * `UPDATE` - Update existing rows * `SKIP` - Skip existing rows
  @JsonKey(name: r'duplicate_strategy', required: true, includeIfNull: false)
  final ImportJobDuplicateStrategyEnum duplicateStrategy;

  @JsonKey(name: r'row_count', required: true, includeIfNull: false)
  final int rowCount;

  @JsonKey(name: r'valid_row_count', required: true, includeIfNull: false)
  final int validRowCount;

  @JsonKey(name: r'error_count', required: true, includeIfNull: false)
  final int errorCount;

  @JsonKey(name: r'created_count', required: true, includeIfNull: false)
  final int createdCount;

  @JsonKey(name: r'updated_count', required: true, includeIfNull: false)
  final int updatedCount;

  @JsonKey(name: r'skipped_count', required: true, includeIfNull: false)
  final int skippedCount;

  @JsonKey(name: r'errors', required: true, includeIfNull: true)
  final Object? errors;

  @JsonKey(name: r'original_filename', required: true, includeIfNull: false)
  final String originalFilename;

  @JsonKey(name: r'file_sha256', required: true, includeIfNull: false)
  final String fileSha256;

  @JsonKey(name: r'file_size_bytes', required: true, includeIfNull: false)
  final int fileSizeBytes;

  @JsonKey(name: r'created_at', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'updated_at', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @JsonKey(name: r'confirmed_at', required: true, includeIfNull: true)
  final DateTime? confirmedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportJob &&
          other.id == id &&
          other.business == business &&
          other.user == user &&
          other.confirmedBy == confirmedBy &&
          other.kind == kind &&
          other.status == status &&
          other.duplicateStrategy == duplicateStrategy &&
          other.rowCount == rowCount &&
          other.validRowCount == validRowCount &&
          other.errorCount == errorCount &&
          other.createdCount == createdCount &&
          other.updatedCount == updatedCount &&
          other.skippedCount == skippedCount &&
          other.errors == errors &&
          other.originalFilename == originalFilename &&
          other.fileSha256 == fileSha256 &&
          other.fileSizeBytes == fileSizeBytes &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt &&
          other.confirmedAt == confirmedAt;

  @override
  int get hashCode =>
      id.hashCode +
      business.hashCode +
      user.hashCode +
      (confirmedBy == null ? 0 : confirmedBy.hashCode) +
      kind.hashCode +
      status.hashCode +
      duplicateStrategy.hashCode +
      rowCount.hashCode +
      validRowCount.hashCode +
      errorCount.hashCode +
      createdCount.hashCode +
      updatedCount.hashCode +
      skippedCount.hashCode +
      (errors == null ? 0 : errors.hashCode) +
      originalFilename.hashCode +
      fileSha256.hashCode +
      fileSizeBytes.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode +
      (confirmedAt == null ? 0 : confirmedAt.hashCode);

  factory ImportJob.fromJson(Map<String, dynamic> json) =>
      _$ImportJobFromJson(json);

  Map<String, dynamic> toJson() => _$ImportJobToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `PRODUCT` - Product * `PARTY` - Party
enum ImportJobKindEnum {
  @JsonValue(r'PRODUCT')
  PRODUCT(r'PRODUCT'),
  @JsonValue(r'PARTY')
  PARTY(r'PARTY');

  const ImportJobKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `READY` - Ready to confirm * `INVALID` - Contains invalid rows * `COMPLETED` - Completed * `FAILED` - Failed
enum ImportJobStatusEnum {
  @JsonValue(r'READY')
  READY(r'READY'),
  @JsonValue(r'INVALID')
  INVALID(r'INVALID'),
  @JsonValue(r'COMPLETED')
  COMPLETED(r'COMPLETED'),
  @JsonValue(r'FAILED')
  FAILED(r'FAILED');

  const ImportJobStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

/// * `UPDATE` - Update existing rows * `SKIP` - Skip existing rows
enum ImportJobDuplicateStrategyEnum {
  @JsonValue(r'UPDATE')
  UPDATE(r'UPDATE'),
  @JsonValue(r'SKIP')
  SKIP(r'SKIP');

  const ImportJobDuplicateStrategyEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
