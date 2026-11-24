// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MessageResponseCWProxy {
  MessageResponse detail(String detail);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MessageResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MessageResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MessageResponse call({String detail});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMessageResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMessageResponse.copyWith.fieldName(...)`
class _$MessageResponseCWProxyImpl implements _$MessageResponseCWProxy {
  const _$MessageResponseCWProxyImpl(this._value);

  final MessageResponse _value;

  @override
  MessageResponse detail(String detail) => this(detail: detail);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MessageResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MessageResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  MessageResponse call({Object? detail = const $CopyWithPlaceholder()}) {
    return MessageResponse(
      detail: detail == const $CopyWithPlaceholder()
          ? _value.detail
          // ignore: cast_nullable_to_non_nullable
          : detail as String,
    );
  }
}

extension $MessageResponseCopyWith on MessageResponse {
  /// Returns a callable class that can be used as follows: `instanceOfMessageResponse.copyWith(...)` or like so:`instanceOfMessageResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MessageResponseCWProxy get copyWith => _$MessageResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MessageResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['detail']);
      final val = MessageResponse(
        detail: $checkedConvert('detail', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{'detail': instance.detail};
