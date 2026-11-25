//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MessageResponse {
  /// Returns a new [MessageResponse] instance.
  MessageResponse({required this.detail});

  @JsonKey(name: r'detail', required: true, includeIfNull: false)
  final String detail;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageResponse && other.detail == detail;

  @override
  int get hashCode => detail.hashCode;

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
