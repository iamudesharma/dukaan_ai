//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/import_job.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_job_list.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportJobList {
  /// Returns a new [ImportJobList] instance.
  ImportJobList({
    required this.count,

    required this.next,

    required this.previous,

    required this.results,
  });

  @JsonKey(name: r'count', required: true, includeIfNull: false)
  final int count;

  @JsonKey(name: r'next', required: true, includeIfNull: true)
  final String? next;

  @JsonKey(name: r'previous', required: true, includeIfNull: true)
  final String? previous;

  @JsonKey(name: r'results', required: true, includeIfNull: false)
  final List<ImportJob> results;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportJobList &&
          other.count == count &&
          other.next == next &&
          other.previous == previous &&
          other.results == results;

  @override
  int get hashCode =>
      count.hashCode +
      (next == null ? 0 : next.hashCode) +
      (previous == null ? 0 : previous.hashCode) +
      results.hashCode;

  factory ImportJobList.fromJson(Map<String, dynamic> json) =>
      _$ImportJobListFromJson(json);

  Map<String, dynamic> toJson() => _$ImportJobListToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
