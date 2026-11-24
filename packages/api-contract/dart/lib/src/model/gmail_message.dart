//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gmail_message.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GmailMessage {
  /// Returns a new [GmailMessage] instance.
  GmailMessage({
    required this.id,

    required this.subject,

    required this.snippet,

    required this.receivedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'subject', required: true, includeIfNull: false)
  final String subject;

  @JsonKey(name: r'snippet', required: true, includeIfNull: false)
  final String snippet;

  @JsonKey(name: r'received_at', required: true, includeIfNull: true)
  final DateTime? receivedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GmailMessage &&
          other.id == id &&
          other.subject == subject &&
          other.snippet == snippet &&
          other.receivedAt == receivedAt;

  @override
  int get hashCode =>
      id.hashCode +
      subject.hashCode +
      snippet.hashCode +
      (receivedAt == null ? 0 : receivedAt.hashCode);

  factory GmailMessage.fromJson(Map<String, dynamic> json) =>
      _$GmailMessageFromJson(json);

  Map<String, dynamic> toJson() => _$GmailMessageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
