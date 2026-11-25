// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BusinessCWProxy {
  Business id(String id);

  Business name(String name);

  Business legalName(String? legalName);

  Business currency(String? currency);

  Business timezone(String? timezone);

  Business gstEnabled(bool? gstEnabled);

  Business negativeStockAllowed(bool? negativeStockAllowed);

  Business isActive(bool isActive);

  Business role(String? role);

  Business locations(List<Location> locations);

  Business locationName(String? locationName);

  Business stateCode(String? stateCode);

  Business gstin(String? gstin);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Business(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Business(...).copyWith(id: 12, name: "My name")
  /// ````
  Business call({
    String id,
    String name,
    String? legalName,
    String? currency,
    String? timezone,
    bool? gstEnabled,
    bool? negativeStockAllowed,
    bool isActive,
    String? role,
    List<Location> locations,
    String? locationName,
    String? stateCode,
    String? gstin,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBusiness.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBusiness.copyWith.fieldName(...)`
class _$BusinessCWProxyImpl implements _$BusinessCWProxy {
  const _$BusinessCWProxyImpl(this._value);

  final Business _value;

  @override
  Business id(String id) => this(id: id);

  @override
  Business name(String name) => this(name: name);

  @override
  Business legalName(String? legalName) => this(legalName: legalName);

  @override
  Business currency(String? currency) => this(currency: currency);

  @override
  Business timezone(String? timezone) => this(timezone: timezone);

  @override
  Business gstEnabled(bool? gstEnabled) => this(gstEnabled: gstEnabled);

  @override
  Business negativeStockAllowed(bool? negativeStockAllowed) =>
      this(negativeStockAllowed: negativeStockAllowed);

  @override
  Business isActive(bool isActive) => this(isActive: isActive);

  @override
  Business role(String? role) => this(role: role);

  @override
  Business locations(List<Location> locations) => this(locations: locations);

  @override
  Business locationName(String? locationName) =>
      this(locationName: locationName);

  @override
  Business stateCode(String? stateCode) => this(stateCode: stateCode);

  @override
  Business gstin(String? gstin) => this(gstin: gstin);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Business(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Business(...).copyWith(id: 12, name: "My name")
  /// ````
  Business call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? legalName = const $CopyWithPlaceholder(),
    Object? currency = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? gstEnabled = const $CopyWithPlaceholder(),
    Object? negativeStockAllowed = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
    Object? role = const $CopyWithPlaceholder(),
    Object? locations = const $CopyWithPlaceholder(),
    Object? locationName = const $CopyWithPlaceholder(),
    Object? stateCode = const $CopyWithPlaceholder(),
    Object? gstin = const $CopyWithPlaceholder(),
  }) {
    return Business(
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
          : legalName as String?,
      currency: currency == const $CopyWithPlaceholder()
          ? _value.currency
          // ignore: cast_nullable_to_non_nullable
          : currency as String?,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String?,
      gstEnabled: gstEnabled == const $CopyWithPlaceholder()
          ? _value.gstEnabled
          // ignore: cast_nullable_to_non_nullable
          : gstEnabled as bool?,
      negativeStockAllowed: negativeStockAllowed == const $CopyWithPlaceholder()
          ? _value.negativeStockAllowed
          // ignore: cast_nullable_to_non_nullable
          : negativeStockAllowed as bool?,
      isActive: isActive == const $CopyWithPlaceholder()
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool,
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as String?,
      locations: locations == const $CopyWithPlaceholder()
          ? _value.locations
          // ignore: cast_nullable_to_non_nullable
          : locations as List<Location>,
      locationName: locationName == const $CopyWithPlaceholder()
          ? _value.locationName
          // ignore: cast_nullable_to_non_nullable
          : locationName as String?,
      stateCode: stateCode == const $CopyWithPlaceholder()
          ? _value.stateCode
          // ignore: cast_nullable_to_non_nullable
          : stateCode as String?,
      gstin: gstin == const $CopyWithPlaceholder()
          ? _value.gstin
          // ignore: cast_nullable_to_non_nullable
          : gstin as String?,
    );
  }
}

extension $BusinessCopyWith on Business {
  /// Returns a callable class that can be used as follows: `instanceOfBusiness.copyWith(...)` or like so:`instanceOfBusiness.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BusinessCWProxy get copyWith => _$BusinessCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Business _$BusinessFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Business',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['id', 'name', 'is_active', 'role', 'locations'],
    );
    final val = Business(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      legalName: $checkedConvert('legal_name', (v) => v as String?),
      currency: $checkedConvert('currency', (v) => v as String?),
      timezone: $checkedConvert('timezone', (v) => v as String?),
      gstEnabled: $checkedConvert('gst_enabled', (v) => v as bool?),
      negativeStockAllowed: $checkedConvert(
        'negative_stock_allowed',
        (v) => v as bool?,
      ),
      isActive: $checkedConvert('is_active', (v) => v as bool),
      role: $checkedConvert('role', (v) => v as String?),
      locations: $checkedConvert(
        'locations',
        (v) => (v as List<dynamic>)
            .map((e) => Location.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      locationName: $checkedConvert('location_name', (v) => v as String?),
      stateCode: $checkedConvert('state_code', (v) => v as String?),
      gstin: $checkedConvert('gstin', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'legalName': 'legal_name',
    'gstEnabled': 'gst_enabled',
    'negativeStockAllowed': 'negative_stock_allowed',
    'isActive': 'is_active',
    'locationName': 'location_name',
    'stateCode': 'state_code',
  },
);

Map<String, dynamic> _$BusinessToJson(Business instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'legal_name': ?instance.legalName,
  'currency': ?instance.currency,
  'timezone': ?instance.timezone,
  'gst_enabled': ?instance.gstEnabled,
  'negative_stock_allowed': ?instance.negativeStockAllowed,
  'is_active': instance.isActive,
  'role': instance.role,
  'locations': instance.locations.map((e) => e.toJson()).toList(),
  'location_name': ?instance.locationName,
  'state_code': ?instance.stateCode,
  'gstin': ?instance.gstin,
};
