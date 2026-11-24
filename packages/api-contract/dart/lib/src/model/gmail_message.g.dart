// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmail_message.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GmailMessageCWProxy {
  GmailMessage id(String id);

  GmailMessage subject(String subject);

  GmailMessage snippet(String snippet);

  GmailMessage receivedAt(DateTime? receivedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailMessage call({
    String id,
    String subject,
    String snippet,
    DateTime? receivedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGmailMessage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGmailMessage.copyWith.fieldName(...)`
class _$GmailMessageCWProxyImpl implements _$GmailMessageCWProxy {
  const _$GmailMessageCWProxyImpl(this._value);

  final GmailMessage _value;

  @override
  GmailMessage id(String id) => this(id: id);

  @override
  GmailMessage subject(String subject) => this(subject: subject);

  @override
  GmailMessage snippet(String snippet) => this(snippet: snippet);

  @override
  GmailMessage receivedAt(DateTime? receivedAt) => this(receivedAt: receivedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailMessage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailMessage(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailMessage call({
    Object? id = const $CopyWithPlaceholder(),
    Object? subject = const $CopyWithPlaceholder(),
    Object? snippet = const $CopyWithPlaceholder(),
    Object? receivedAt = const $CopyWithPlaceholder(),
  }) {
    return GmailMessage(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      subject: subject == const $CopyWithPlaceholder()
          ? _value.subject
          // ignore: cast_nullable_to_non_nullable
          : subject as String,
      snippet: snippet == const $CopyWithPlaceholder()
          ? _value.snippet
          // ignore: cast_nullable_to_non_nullable
          : snippet as String,
      receivedAt: receivedAt == const $CopyWithPlaceholder()
          ? _value.receivedAt
          // ignore: cast_nullable_to_non_nullable
          : receivedAt as DateTime?,
    );
  }
}

extension $GmailMessageCopyWith on GmailMessage {
  /// Returns a callable class that can be used as follows: `instanceOfGmailMessage.copyWith(...)` or like so:`instanceOfGmailMessage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GmailMessageCWProxy get copyWith => _$GmailMessageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GmailMessage _$GmailMessageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GmailMessage', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'subject', 'snippet', 'received_at'],
      );
      final val = GmailMessage(
        id: $checkedConvert('id', (v) => v as String),
        subject: $checkedConvert('subject', (v) => v as String),
        snippet: $checkedConvert('snippet', (v) => v as String),
        receivedAt: $checkedConvert(
          'received_at',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'receivedAt': 'received_at'});

Map<String, dynamic> _$GmailMessageToJson(GmailMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'snippet': instance.snippet,
      'received_at': instance.receivedAt?.toIso8601String(),
    };
