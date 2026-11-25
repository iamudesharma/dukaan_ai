//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dukaanai_api_client/src/model/gmail_message.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gmail_messages.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GmailMessages {
  /// Returns a new [GmailMessages] instance.
  GmailMessages({required this.results});

  @JsonKey(name: r'results', required: true, includeIfNull: false)
  final List<GmailMessage> results;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GmailMessages && other.results == results;

  @override
  int get hashCode => results.hashCode;

  factory GmailMessages.fromJson(Map<String, dynamic> json) =>
      _$GmailMessagesFromJson(json);

  Map<String, dynamic> toJson() => _$GmailMessagesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
