// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmail_messages.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GmailMessagesCWProxy {
  GmailMessages results(List<GmailMessage> results);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailMessages(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailMessages(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailMessages call({List<GmailMessage> results});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGmailMessages.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGmailMessages.copyWith.fieldName(...)`
class _$GmailMessagesCWProxyImpl implements _$GmailMessagesCWProxy {
  const _$GmailMessagesCWProxyImpl(this._value);

  final GmailMessages _value;

  @override
  GmailMessages results(List<GmailMessage> results) => this(results: results);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailMessages(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailMessages(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailMessages call({Object? results = const $CopyWithPlaceholder()}) {
    return GmailMessages(
      results: results == const $CopyWithPlaceholder()
          ? _value.results
          // ignore: cast_nullable_to_non_nullable
          : results as List<GmailMessage>,
    );
  }
}

extension $GmailMessagesCopyWith on GmailMessages {
  /// Returns a callable class that can be used as follows: `instanceOfGmailMessages.copyWith(...)` or like so:`instanceOfGmailMessages.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GmailMessagesCWProxy get copyWith => _$GmailMessagesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GmailMessages _$GmailMessagesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GmailMessages', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['results']);
      final val = GmailMessages(
        results: $checkedConvert(
          'results',
          (v) => (v as List<dynamic>)
              .map((e) => GmailMessage.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$GmailMessagesToJson(GmailMessages instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
