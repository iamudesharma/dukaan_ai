//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_dry_run_preview.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportDryRunPreview {
  /// Returns a new [ImportDryRunPreview] instance.
  ImportDryRunPreview({required this.row, required this.action});

  /// One-based CSV row number, including the header.
  @JsonKey(name: r'row', required: true, includeIfNull: false)
  final int row;

  /// * `CREATE` - CREATE * `UPDATE` - UPDATE * `SKIP` - SKIP
  @JsonKey(name: r'action', required: true, includeIfNull: false)
  final ImportDryRunPreviewActionEnum action;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportDryRunPreview &&
          other.row == row &&
          other.action == action;

  @override
  int get hashCode => row.hashCode + action.hashCode;

  factory ImportDryRunPreview.fromJson(Map<String, dynamic> json) =>
      _$ImportDryRunPreviewFromJson(json);

  Map<String, dynamic> toJson() => _$ImportDryRunPreviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// * `CREATE` - CREATE * `UPDATE` - UPDATE * `SKIP` - SKIP
enum ImportDryRunPreviewActionEnum {
  @JsonValue(r'CREATE')
  CREATE(r'CREATE'),
  @JsonValue(r'UPDATE')
  UPDATE(r'UPDATE'),
  @JsonValue(r'SKIP')
  SKIP(r'SKIP');

  const ImportDryRunPreviewActionEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
