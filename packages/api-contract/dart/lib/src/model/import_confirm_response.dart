//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/import_job.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'import_confirm_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ImportConfirmResponse {
  /// Returns a new [ImportConfirmResponse] instance.
  ImportConfirmResponse({required this.job, required this.replayed});

  @JsonKey(name: r'job', required: true, includeIfNull: false)
  final ImportJob job;

  @JsonKey(name: r'replayed', required: true, includeIfNull: false)
  final bool replayed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportConfirmResponse &&
          other.job == job &&
          other.replayed == replayed;

  @override
  int get hashCode => job.hashCode + replayed.hashCode;

  factory ImportConfirmResponse.fromJson(Map<String, dynamic> json) =>
      _$ImportConfirmResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ImportConfirmResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
