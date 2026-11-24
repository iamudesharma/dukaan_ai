// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap_business.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BootstrapBusinessCWProxy {
  BootstrapBusiness id(String id);

  BootstrapBusiness name(String name);

  BootstrapBusiness legalName(String legalName);

  BootstrapBusiness currency(String currency);

  BootstrapBusiness timezone(String timezone);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BootstrapBusiness(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BootstrapBusiness(...).copyWith(id: 12, name: "My name")
  /// ````
  BootstrapBusiness call({
    String id,
    String name,
    String legalName,
    String currency,
    String timezone,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBootstrapBusiness.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBootstrapBusiness.copyWith.fieldName(...)`
class _$BootstrapBusinessCWProxyImpl implements _$BootstrapBusinessCWProxy {
  const _$BootstrapBusinessCWProxyImpl(this._value);

  final BootstrapBusiness _value;

  @override
  BootstrapBusiness id(String id) => this(id: id);

  @override
  BootstrapBusiness name(String name) => this(name: name);

  @override
  BootstrapBusiness legalName(String legalName) => this(legalName: legalName);

  @override
  BootstrapBusiness currency(String currency) => this(currency: currency);

  @override
  BootstrapBusiness timezone(String timezone) => this(timezone: timezone);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BootstrapBusiness(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BootstrapBusiness(...).copyWith(id: 12, name: "My name")
  /// ````
  BootstrapBusiness call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? legalName = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
  }) {
    return BootstrapBusiness(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      legalName: legalName == const $CopyWithPlaceholder()
          ? _value.legalName
          // ignore: cast_nullable_to_non_nullable
          : legalName as String,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
    );
  }
}

extension $BootstrapBusinessCopyWith on BootstrapBusiness {
  /// Returns a callable class that can be used as follows: `instanceOfBootstrapBusiness.copyWith(...)` or like so:`instanceOfBootstrapBusiness.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BootstrapBusinessCWProxy get copyWith =>
      _$BootstrapBusinessCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BootstrapBusiness _$BootstrapBusinessFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BootstrapBusiness', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'name',
          'legal_name',
          'currency',
          'timezone',
        ],
      );
      final val = BootstrapBusiness(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        legalName: $checkedConvert('legal_name', (v) => v as String),
        currency: $checkedConvert('currency', (v) => v as String),
        timezone: $checkedConvert('timezone', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'legalName': 'legal_name'});

Map<String, dynamic> _$BootstrapBusinessToJson(BootstrapBusiness instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'legal_name': instance.legalName,
      'currency': instance.currency,
      'timezone': instance.timezone,
    };
