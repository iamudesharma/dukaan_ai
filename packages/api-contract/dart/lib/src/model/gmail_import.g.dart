// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gmail_import.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GmailImportCWProxy {
  GmailImport messageId(String messageId);

  GmailImport businessId(String businessId);

  GmailImport locationId(String locationId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailImport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailImport(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailImport call({String messageId, String businessId, String locationId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGmailImport.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGmailImport.copyWith.fieldName(...)`
class _$GmailImportCWProxyImpl implements _$GmailImportCWProxy {
  const _$GmailImportCWProxyImpl(this._value);

  final GmailImport _value;

  @override
  GmailImport messageId(String messageId) => this(messageId: messageId);

  @override
  GmailImport businessId(String businessId) => this(businessId: businessId);

  @override
  GmailImport locationId(String locationId) => this(locationId: locationId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GmailImport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GmailImport(...).copyWith(id: 12, name: "My name")
  /// ````
  GmailImport call({
    Object? messageId = const $CopyWithPlaceholder(),
    Object? businessId = const $CopyWithPlaceholder(),
    Object? locationId = const $CopyWithPlaceholder(),
  }) {
    return GmailImport(
      messageId: messageId == const $CopyWithPlaceholder()
          ? _value.messageId
          // ignore: cast_nullable_to_non_nullable
          : messageId as String,
      businessId: businessId == const $CopyWithPlaceholder()
          ? _value.businessId
          // ignore: cast_nullable_to_non_nullable
          : businessId as String,
      locationId: locationId == const $CopyWithPlaceholder()
          ? _value.locationId
          // ignore: cast_nullable_to_non_nullable
          : locationId as String,
    );
  }
}

extension $GmailImportCopyWith on GmailImport {
  /// Returns a callable class that can be used as follows: `instanceOfGmailImport.copyWith(...)` or like so:`instanceOfGmailImport.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GmailImportCWProxy get copyWith => _$GmailImportCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GmailImport _$GmailImportFromJson(Map<String, dynamic> json) => $checkedCreate(
  'GmailImport',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['message_id', 'business_id', 'location_id'],
    );
    final val = GmailImport(
      messageId: $checkedConvert('message_id', (v) => v as String),
      businessId: $checkedConvert('business_id', (v) => v as String),
      locationId: $checkedConvert('location_id', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'messageId': 'message_id',
    'businessId': 'business_id',
    'locationId': 'location_id',
  },
);

Map<String, dynamic> _$GmailImportToJson(GmailImport instance) =>
    <String, dynamic>{
      'message_id': instance.messageId,
      'business_id': instance.businessId,
      'location_id': instance.locationId,
    };
