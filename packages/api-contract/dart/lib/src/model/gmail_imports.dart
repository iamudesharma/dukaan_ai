//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/gmail_import_result.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gmail_imports.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GmailImports {
  /// Returns a new [GmailImports] instance.
  GmailImports({required this.results});

  @JsonKey(name: r'results', required: true, includeIfNull: false)
  final List<GmailImportResult> results;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GmailImports && other.results == results;

  @override
  int get hashCode => results.hashCode;

  factory GmailImports.fromJson(Map<String, dynamic> json) =>
      _$GmailImportsFromJson(json);

  Map<String, dynamic> toJson() => _$GmailImportsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
